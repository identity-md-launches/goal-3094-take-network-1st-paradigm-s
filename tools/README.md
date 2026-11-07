# tools/

- `amm-challenge/` — the simulator, vendored as plain files from
  https://github.com/benedictbrady/amm-challenge at commit
  `6b6921f8d463314aa7c96234e1be25a25245f704` (no `.git`, no submodule).
  Omitted from the vendored copy, because this repository's submission rules
  forbid those file names: `.gitignore`, `contracts/foundry.toml`,
  `contracts/remappings.txt`, `contracts/foundry.lock` (Foundry config only;
  the Python/Rust simulator never reads them). Everything else is byte-identical.
- `pair.py` — paired measurement of two strategies on identical seeds.

## Install (everything stays inside the checkout, under the git-ignored `.deps/`)

Needs Python >= 3.10 and a C toolchain; tested with Python 3.12, Rust 1.9x stable.

```bash
cd <repo root>
# Rust (skip if cargo is already on PATH)
export RUSTUP_HOME=$PWD/.deps/rustup CARGO_HOME=$PWD/.deps/cargo
curl -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path --profile minimal
export PATH=$PWD/.deps/cargo/bin:$PATH

# Python venv (if `python3 -m venv` lacks ensurepip, use --without-pip + get-pip.py)
python3 -m venv .deps/venv
export PATH=$PWD/.deps/venv/bin:$PATH VIRTUAL_ENV=$PWD/.deps/venv
pip install maturin numpy py-solc-x pyrevm

# Rust engine + the amm-match CLI
export CARGO_TARGET_DIR=$PWD/.deps/target
(cd tools/amm-challenge/amm_sim_rs && maturin develop --release)
pip install -e tools/amm-challenge

# keep solc 0.8.24 inside the checkout (pair.py sets this default itself)
export SOLCX_BINARY_PATH=$PWD/.deps/solcx
```

The first compile downloads solc 0.8.24 from binaries.soliditylang.org.

## Use

```bash
amm-match validate best/Strategy.sol           # must pass before anything is promoted
amm-match run best/Strategy.sol --simulations 1000   # = mean edge on seeds 0..999

# paired comparison: candidate vs current best on fresh seeds
python tools/pair.py cand.sol best/Strategy.sol --seed-start 100000 --n 2000 \
    [--workers 32] [--csv per_seed.csv]

# against the fixed 30 bps normalizer
python tools/pair.py best/Strategy.sol tools/amm-challenge/contracts/src/VanillaStrategy.sol \
    --seed-start 100000 --n 2000
```

Output (JSON on stdout):

| field | meaning |
|---|---|
| `n`, `seed_start` | seeds `seed_start .. seed_start+n-1` |
| `mean_a`, `mean_b` | mean edge of A and of B (each vs the 30 bps normalizer) |
| `mean_diff` | mean of per-seed `edge(A) - edge(B)` |
| `se` | `std(diff, ddof=1)/sqrt(n)` |
| `worst` | 5 lowest per-seed diffs: `{seed, diff, edge_a, edge_b}` |
| `seconds_per_simulation` | sim wall time / (2n) at the given `--workers` |
| `validate_ok` | `amm-match validate` rules per file (false for `VanillaStrategy.sol` only because of its contract name; it still runs) |

`--n 0` only validates and compiles both files.

How the seeds work: simulation index `s` uses `numpy.random.default_rng(seed=s)`
to draw `retail_mean_size`, `retail_arrival_rate`, `gbm_sigma` (in that order)
and passes `seed=s` to the Rust engine — a copy of
`MatchRunner._build_configs` with an offset. So `--seed-start 0 --n 1000`
gives exactly the per-simulation edges behind `amm-match run --simulations 1000`
(checked: both give 369.45 for the starter). Runs are deterministic: A vs A
gives `mean_diff = 0.0` exactly.

Speed on a 32-core machine: ~0.011 s per simulation with `--workers 32`, so
a 2,000-seed paired comparison (4,000 sims) takes ~45 s plus compile time.

Python use: `from pair import build_configs, compile_strategy, edges, paired`
(with `tools/` on `sys.path`).
