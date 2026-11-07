#!/usr/bin/env python3
"""Paired measurement of two AMM fee strategies on identical simulation seeds.

Usage:
    python tools/pair.py A.sol B.sol --seed-start S --n N [--workers W] [--csv F]

For every seed s in [S, S+N) both strategies are simulated against the fixed
30 bps normalizer with exactly the configuration `amm-match run` would build
for simulation index s (MatchRunner._build_configs: numpy default_rng(seed=s)
draws retail_mean_size, retail_arrival_rate, gbm_sigma in that order, and the
Rust engine is seeded with s).  So `--seed-start 0 --n 1000` reproduces the
per-simulation edges behind `amm-match run X.sol --simulations 1000`.

Prints one JSON object:
    {n, seed_start, a, b, mean_a, mean_b, mean_diff, se, worst,
     seconds_per_simulation, validate_ok}
where diff = edge(A) - edge(B) per seed, se = sample std(diff)/sqrt(n), and
worst = the 5 lowest per-seed differences as [{seed, diff, edge_a, edge_b}].
seconds_per_simulation is wall time of all simulations / (2*N) (one
simulation = one strategy on one seed, with the given worker count).

`--n` may be 0 to only validate/compile both files.  The module can also be
imported: build_configs(), compile_strategy(), edges(), paired().

Seed rules for this repository (see README.md): tune only on seeds 0..99999;
promotion comparisons use fresh seeds >= 100000 that no tuning touched.
"""

from __future__ import annotations

import argparse
import json
import math
import os
import re
import sys
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parent
SIM_DIR = HERE / "amm-challenge"

# Keep solc binaries inside the checkout unless the caller chose a location.
os.environ.setdefault("SOLCX_BINARY_PATH", str(REPO / ".deps" / "solcx"))
Path(os.environ["SOLCX_BINARY_PATH"]).mkdir(parents=True, exist_ok=True)

# Prefer the vendored simulator when it was not pip-installed.
if str(SIM_DIR) not in sys.path:
    sys.path.insert(0, str(SIM_DIR))

import numpy as np  # noqa: E402
import amm_sim_rs  # noqa: E402
from amm_competition.competition.config import (  # noqa: E402
    BASELINE_SETTINGS,
    BASELINE_VARIANCE,
)
from amm_competition.evm.baseline import get_vanilla_bytecode_and_abi  # noqa: E402
from amm_competition.evm.compiler import SolidityCompiler  # noqa: E402
from amm_competition.evm.validator import SolidityValidator  # noqa: E402

_CONTRACT_RE = re.compile(r"\bcontract\s+(\w+)\s+is\s+AMMStrategyBase\b")


def build_configs(seed_start: int, n: int) -> list:
    """Configs identical to MatchRunner._build_configs, for indices seed_start..seed_start+n-1."""
    base = BASELINE_SETTINGS
    var = BASELINE_VARIANCE
    configs = []
    for i in range(seed_start, seed_start + n):
        rng = np.random.default_rng(seed=i)
        retail_mean_size = (
            rng.uniform(var.retail_mean_size_min, var.retail_mean_size_max)
            if var.vary_retail_mean_size
            else (var.retail_mean_size_min + var.retail_mean_size_max) / 2
        )
        retail_arrival_rate = (
            rng.uniform(var.retail_arrival_rate_min, var.retail_arrival_rate_max)
            if var.vary_retail_arrival_rate
            else (var.retail_arrival_rate_min + var.retail_arrival_rate_max) / 2
        )
        gbm_sigma = (
            rng.uniform(var.gbm_sigma_min, var.gbm_sigma_max)
            if var.vary_gbm_sigma
            else (var.gbm_sigma_min + var.gbm_sigma_max) / 2
        )
        configs.append(
            amm_sim_rs.SimulationConfig(
                n_steps=base.n_steps,
                initial_price=base.initial_price,
                initial_x=base.initial_x,
                initial_y=base.initial_y,
                gbm_mu=base.gbm_mu,
                gbm_sigma=gbm_sigma,
                gbm_dt=base.gbm_dt,
                retail_arrival_rate=retail_arrival_rate,
                retail_mean_size=retail_mean_size,
                retail_size_sigma=base.retail_size_sigma,
                retail_buy_prob=base.retail_buy_prob,
                seed=i,
            )
        )
    return configs


def compile_strategy(path: str | Path) -> tuple[bytes, bool, list[str]]:
    """Compile a strategy file. Returns (bytecode, validate_ok, messages).

    validate_ok runs the same validator + compiler as `amm-match validate`
    (it is False for files whose contract is not named Strategy, e.g. the
    vendored VanillaStrategy.sol, which is still compiled and runnable).
    """
    source = Path(path).read_text()
    m = _CONTRACT_RE.search(source)
    name = m.group(1) if m else "Strategy"
    msgs: list[str] = []
    validation = SolidityValidator().validate(source)
    validate_ok = bool(validation.valid)
    if not validation.valid:
        msgs += [f"validate: {e}" for e in validation.errors]
    comp = SolidityCompiler().compile(source, contract_name=name)
    if not comp.success:
        raise SystemExit(f"compile failed for {path}: {comp.errors}")
    return bytes(comp.bytecode), validate_ok, msgs


def edges(bytecode: bytes, configs: list, workers: int) -> list[float]:
    """Per-config edge of `bytecode` against the 30 bps normalizer, in config order."""
    vanilla, _ = get_vanilla_bytecode_and_abi()
    batch = amm_sim_rs.run_batch(list(bytecode), list(vanilla), configs, workers)
    by_seed = {r.seed: float(r.edges["submission"]) for r in batch.results}
    return [by_seed[c.seed] for c in configs]


def paired(a: str, b: str, seed_start: int, n: int, workers: int, csv: str | None = None) -> dict:
    code_a, ok_a, msg_a = compile_strategy(a)
    code_b, ok_b, msg_b = compile_strategy(b)
    out: dict = {
        "a": str(a),
        "b": str(b),
        "seed_start": seed_start,
        "n": n,
        "validate_ok": {"a": ok_a, "b": ok_b},
    }
    if msg_a or msg_b:
        out["validate_messages"] = {"a": msg_a, "b": msg_b}
    if n <= 0:
        return out

    configs = build_configs(seed_start, n)
    t0 = time.perf_counter()
    ea = edges(code_a, configs, workers)
    eb = edges(code_b, configs, workers)
    secs = time.perf_counter() - t0

    da = np.asarray(ea)
    db = np.asarray(eb)
    d = da - db
    se = float(d.std(ddof=1) / math.sqrt(n)) if n > 1 else float("nan")
    order = np.argsort(d, kind="stable")[:5]
    seeds = [c.seed for c in configs]
    out.update(
        {
            "mean_a": float(da.mean()),
            "mean_b": float(db.mean()),
            "mean_diff": float(d.mean()),
            "se": se,
            "worst": [
                {"seed": int(seeds[k]), "diff": float(d[k]), "edge_a": float(da[k]), "edge_b": float(db[k])}
                for k in order
            ],
            "seconds_per_simulation": secs / (2 * n),
            "workers": workers,
        }
    )
    if csv:
        with open(csv, "w") as fh:
            fh.write("seed,edge_a,edge_b,diff\n")
            for s, x, y in zip(seeds, ea, eb):
                fh.write(f"{s},{x!r},{y!r},{x - y!r}\n")
    return out


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description="Paired edge comparison of two strategies on the same seeds.")
    p.add_argument("a", help="candidate .sol (A)")
    p.add_argument("b", help="reference .sol (B), e.g. best/Strategy.sol")
    p.add_argument("--seed-start", type=int, required=True)
    p.add_argument("--n", type=int, required=True)
    p.add_argument("--workers", type=int, default=os.cpu_count() or 8)
    p.add_argument("--csv", default=None, help="write per-seed edges and differences here")
    args = p.parse_args(argv)
    if args.seed_start < 0:
        p.error("--seed-start must be >= 0")
    res = paired(args.a, args.b, args.seed_start, args.n, args.workers, args.csv)
    print(json.dumps(res, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
