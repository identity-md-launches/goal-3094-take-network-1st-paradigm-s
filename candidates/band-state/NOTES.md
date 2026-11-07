# Band-state — round 1 result

Selected variant **J**, with base/low/high fees **70/0/110 bps**, tolerance **20 bps**, and decay **8 steps**.

- Source: `candidates/band-state/Strategy.sol`
- SHA-256: `4316ab7e21a569832cdca6fd4db119f5b4f1615de43bb9d42a6a19bd94c57f7a`
- Requested score, seeds 0–999: **380.267912317**, n=1,000.
- Fresh score, seeds 100000–101999: **380.280204308**, n=2,000.
- Fresh gain over starter and previous established best: **+10.778902870 ± 0.140885027 SE**, n=2,000.
- Fresh gain over the fixed 70 bps ablation: **+0.705108149 ± 0.049304227 SE**, n=2,000; state contribution clears 2×SE: **yes**.
- Promotion: **yes**, using the predeclared gain > 2×SE rule. The selected state machine qualifies for promotion over the starter.
- `amm-match validate`: passed. Five targeted tests: passed. Peak measured swap gas in the 2,000-swap stress test: **52,658**.
- Final candidate wall time per simulation: **0.115829 s** with four workers. Candidate plus reference: **0.217608 s per pair**. Compilation excluded.
- Final 20-seed timing pilot projected **449.8 seconds** for 2,000 pairs, below the 25-minute allowance; no sample-size exception was needed.

The starter hash is `8f2cea337f6736105f58c6758da6c3ebf002951d34492bcd5b7101bef2d1e7f3`. Its 2,000-seed tuning score is 368.804420618. It is also the previous established best: no separately promoted incumbent was supplied, and no tuning leader was treated as a promotion. The final comparison was performed once after freezing the source; its seeds were never used for tuning.

## Tuning scoreboard

All entries have n=2,000 on seeds 0–1999. Rows are ranked by tuning mean; these are **not** held-out promotions. Each full hash, all five worst paired runs, and comparisons to the preceding training incumbent are recorded in `result.json`. Fee triples and tolerances are in basis points.

| Variant | Base/low/high | Tolerance | Decay | Mean edge | Δ starter | SE | SHA-256 prefix |
|---|---|---|---|---|---|---|---|
| J | 70/0/110 | 20 | 8 | 379.594326 | +10.789906 | 0.132964 | `4316ab7e21a5` |
| O | 75/74/76 | 40 | 4 | 379.539130 | +10.734710 | 0.150125 | `ae4904a699cf` |
| P | 75/65/95 | 40 | 4 | 379.291508 | +10.487088 | 0.153018 | `31bd35d7ed24` |
| G | 70/69/71 | 40 | 4 | 378.971228 | +10.166807 | 0.125618 | `824770903026` |
| N | 85/84/86 | 40 | 4 | 378.802892 | +9.998471 | 0.193717 | `658e8e2e373f` |
| Q | 75/65/95 | 40 | 4 | 378.706752 | +9.902332 | 0.154011 | `699b5fbd60dd` |
| K | 80/10/120 | 40 | 4 | 378.706724 | +9.902303 | 0.177274 | `17bab13d97d0` |
| L | 90/20/140 | 40 | 4 | 374.842096 | +6.037675 | 0.217561 | `1a99d873f2e8` |
| M | 100/99/101 | 40 | 4 | 373.970768 | +5.166348 | 0.249937 | `ba55300c5b60` |
| C | 50/40/70 | 40 | 4 | 368.209553 | -0.594868 | 0.029284 | `c279fac1c9f7` |
| B | 50/25/90 | 40 | 4 | 365.515911 | -3.288510 | 0.061047 | `16338152204d` |
| H | 45/0/75 | 40 | 4 | 359.655632 | -9.148789 | 0.092898 | `5049ea6fd463` |
| F | 40/39/41 | 40 | 4 | 358.004858 | -10.799562 | 0.086091 | `6dd509ab062e` |
| D | 40/20/70 | 40 | 4 | 357.982885 | -10.821535 | 0.095067 | `7a858df2aba9` |
| E | 50/10/140 | 40 | 8 | 349.704080 | -19.100340 | 0.135055 | `23b19b4957f3` |
| A | 30/10/60 | 20 | 4 | 333.557770 | -35.246651 | 0.215894 | `6fb505925b62` |
| I | 50/0/70 | 80 | 2 | 325.968260 | -42.836160 | 0.108837 | `8c7c1d711393` |

J was selected by the largest tuning mean. Its lead over runner-up O is +0.055195896 ± 0.057219406 SE, so superiority over O is not established. The fresh evaluation compares with the prescribed starter and with fixed 70 bps; it was not used to retune or reselect the source.

Variants differ only in BASE, LOW, HIGH, TOLERANCE, DECAY, and the pre-band predicate. Variant P uses `priorEdge + tolerance / 2 >= fair : priorEdge <= fair + tolerance / 2`; all others use `priorEdge + tolerance >= fair : priorEdge <= fair + tolerance`. Restore those expressions and the table constants in the delivered source to reproduce each full SHA-256. Q and P are the controlled classifier comparison.

## Ranked promotions

| Rank | Variant | Gain over previous best | SE | Fresh n |
|---|---|---|---|---|
| 1 | J | +10.778902870 | 0.140885027 | 2000 |

## Controlled tuning comparisons

These are tuning diagnostics, not independent validation.

- D minus F: -0.021973138 ± 0.052130520 SE, n=2000.
- P minus Q: +0.584756053 ± 0.014683135 SE, n=2000.
- J minus G: +0.623098492 ± 0.049809672 SE, n=2000.

D/F compare wider versus narrow fees at base 40; P/Q change only the pre-band tolerance; J/G compare the selected state response with nearly symmetric fees at base 70. These diagnostics did not change the frozen selection after fresh evaluation began.

## Five worst fresh paired runs

| Seed | Candidate minus starter |
|---|---|
| 100855 | -6.475187146 |
| 101071 | -5.938331960 |
| 100621 | -5.231054380 |
| 100710 | -4.437485219 |
| 101621 | -4.049341015 |


This item implements the assigned discrete state machine from first principles. All simulations use upstream commit `6b6921f8d463314aa7c96234e1be25a25245f704`, with the unmodified Rust engine and its reported `edges['submission']` objective. The brief specifies upstream `contracts/src/StarterStrategy.sol` (fixed 50 bps) as the reference and supplies no separately promoted previous-best source; that file is both reference labels for this item.

## Mechanism

The policy has three states: retail, arbitrageur buys X from the pool, and arbitrageur sells X to the pool. Only the first observed trade at a new timestamp can be arbitrage. Its post-trade spot and the fee actually charged imply a fair price: `spot / (1 - ask)` when the pool sells X; `spot * (1 - bid)` when the pool buys X. A tolerance around the prior fair-price estimate supplies the band-edge classification. This is a heuristic, not an observation of the trader's identity. Large first retail orders can be misclassified, and a genuine arb can miss the tolerance.

Accepted arbitrage updates the price estimate to its implied band edge. A rejected first trade updates it by one quarter of a price innovation capped at 100 bps. Later trades in the same step do not update the estimate because the fair price has not moved. Tolerance increases by 2 bps per elapsed step, up to ten steps.

After an arb buys X, bid is low and ask high; after an arb sells X, the pair is reversed. Retail immediately returns to the symmetric pair. The state-change timestamp is preserved across repeated observations of the same state; fees interpolate linearly back to the symmetric pair over the decay horizon. Decay is evaluated only on callbacks: there is no mechanism to change an already quoted fee between trades.

Slots 0–6 hold the fair-price estimate, last timestamp plus one, current bid, current ask, state, state-change timestamp, and previous spot. All remaining slots are unused. There are no history loops, external calls, assembly, or storage outside the inherited slots array.

## Measurement protocol

The harness copies the exact `_build_configs` draw order: for each seed, `numpy.random.default_rng(seed)` draws mean retail size U(19,21), arrival rate U(0.6,1.0), then volatility U(0.000882,0.001008). All remaining fields come from upstream `build_config`. Each strategy competes against upstream VanillaStrategy at 30 bps. Candidate and reference run separately with identical seeds/configurations. `run_batch` results are checked for matching seed order. Batches contain at most 20 simulations because the upstream engine retains full step histories; this does not change simulation parameters or random streams.

Tuning uses seeds 0–1999, 2,000 simulations per candidate. The requested displayed score is the first 1,000 of those seeds. Final evaluation is reserved for seeds 100000–101999, with no tuning after it. Standard error is sample standard deviation of per-seed differences divided by sqrt(n); worst runs are the five smallest paired differences. No leaderboard equivalence is inferred from local scores.

## Sources

- [Official simulator and rules](https://github.com/benedictbrady/amm-challenge/tree/6b6921f8d463314aa7c96234e1be25a25245f704): contract API, fee accounting, arbitrage math, randomized configurations and scoring.
- [Algebra's public write-up](https://www.linkedin.com/pulse/amm-fee-challenge-notes-from-our-run-optimization-arena-qe3ff): supports asymmetric fees and using first-in-block ordering as an informative signal. Its performance claims were not independently reproduced here.
- [Public methodology post-mortem](https://github.com/dipankar/amm-challenge/blob/main/ANALYSIS.md): warns that classification-only policies may plateau below continuous state estimators. This item deliberately retains the assigned discrete mechanism; public strategy code was not copied.

## Local setup and checks

Dependencies and test scaffolding live only under `test/scratch/band-state/`, which is excluded from delivery. Python 3.12 lacked ensurepip; the virtual environment was bootstrapped using get-pip. Rust and a Zig C linker were installed locally because the system had neither Rust nor a C compiler. The first rustup invocation failed because `/tmp` was unavailable; rerunning with a scratch-local TMPDIR succeeded. An exploratory read of `src/arbitrageur.rs` failed because the actual file is `src/market/arbitrageur.rs`; it was then read successfully. None of these setup failures required changes to upstream source or repository configuration.

Commands executed include: `git clone ... simulator`, `git -C simulator checkout 6b6921f8d463314aa7c96234e1be25a25245f704`; local pip installation of maturin/numpy/py-solc-x/pyrevm/pytest and the simulator; `maturin develop --release --manifest-path .../amm_sim_rs/Cargo.toml`; `amm-match validate candidates/band-state/Strategy.sol`; paired measurement with the scratch harness; and `pytest -q test/scratch/band-state/test_state.py`.

The five targeted tests cover timestamp zero, same-timestamp retail reset, both directional states, repeated-state decay, long gaps, large trades, and 2,000 physically consistent randomized swaps. The official EVM adapter enforces 250,000 gas per initialization and swap. Its aggregate gas metric is an estimate, so it is not reported as a measured gas cost.

The configuration-copy check matched all 12 fields of upstream `_build_configs` for all 2,000 tuning seeds. Its first interactive import lacked the scratch harness on `sys.path` (`<stdin>:1`, `ModuleNotFoundError: measure`); rerunning with the explicit scratch path passed.

## Reproduction harness

After installing the pinned simulator and setting `SOLCX_BINARY_PATH` to a local Solidity 0.8.24 installation, save the following as `test/scratch/band-state/measure.py`. Run `python3 test/scratch/band-state/measure.py candidates/band-state/Strategy.sol --start 100000 --n 2000 --reference test/scratch/band-state/simulator/contracts/src/StarterStrategy.sol`. The normalizer is compiled from the same pinned checkout.

```python
import argparse, hashlib, json, time
from pathlib import Path
import numpy as np
import amm_sim_rs
from amm_competition.evm.compiler import SolidityCompiler
from amm_competition.evm.baseline import get_vanilla_bytecode_and_abi
from amm_competition.competition.config import build_config

ROOT=Path(__file__).resolve().parent

def configs(start,n):
    result=[]
    for seed in range(start,start+n):
        rng=np.random.default_rng(seed=seed)
        size=rng.uniform(19.,21.)
        rate=rng.uniform(.6,1.)
        sigma=rng.uniform(.000882,.001008)
        result.append(build_config(seed=seed,gbm_sigma=sigma,retail_arrival_rate=rate,retail_mean_size=size))
    return result

def run(path,start,n,workers=4):
    source=Path(path).read_text()
    digest=hashlib.sha256(source.encode()).hexdigest()
    out=ROOT/'runs'/f'{digest}_{start}_{n}.json'
    if out.exists(): return json.loads(out.read_text())
    compiled=SolidityCompiler().compile(source)
    assert compiled.success, compiled.errors
    vanilla,_=get_vanilla_bytecode_and_abi()
    cfg=configs(start,n)
    t=time.monotonic()
    edges=[]
    for offset in range(0,n,20):
        batch=amm_sim_rs.run_batch(list(compiled.bytecode),list(vanilla),cfg[offset:offset+20],workers)
        results=batch.results
        assert [r.seed for r in results] == list(range(start+offset,start+min(offset+20,n)))
        edges.extend(float(r.edges['submission']) for r in results)
        del results, batch
        if (offset+20)%200==0: print(f'progress {Path(path).name}: {offset+20}/{n}, {time.monotonic()-t:.1f}s',flush=True)
    seconds=time.monotonic()-t
    data=dict(path=str(path),sha256=digest,seed_start=start,n=n,mean_edge=float(np.mean(edges)),seconds=seconds,seconds_per_simulation=seconds/n,edges=edges)
    out.parent.mkdir(exist_ok=True)
    out.write_text(json.dumps(data))
    print(json.dumps({k:v for k,v in data.items() if k!='edges'}),flush=True)
    return data

def paired(a,b):
    d=np.array(a['edges'])-np.array(b['edges'])
    return dict(reference=b['path'],reference_sha256=b['sha256'],seed_start=a['seed_start'],n=len(d),mean_diff=float(d.mean()),se=float(d.std(ddof=1)/np.sqrt(len(d))),worst=[dict(seed=int(a['seed_start']+i),difference=float(d[i])) for i in np.argsort(d)[:5]])

if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('path');p.add_argument('--start',type=int,default=0);p.add_argument('--n',type=int,default=20);p.add_argument('--workers',type=int,default=4);p.add_argument('--reference')
    a=p.parse_args();r=run(a.path,a.start,a.n,a.workers)
    if a.reference:
        ref=run(a.reference,a.start,a.n,a.workers)
        print(json.dumps(paired(r,ref)),flush=True)
```

The measured peak swap gas comes from the raw pyrevm `ExecutionResult.gas_used`, not the adapter's estimated aggregate counter. Upstream HEAD and its tracked-file diff were checked again after building; the simulator source remained unchanged.

The decay test seeds an ongoing arb state in the EVM database, then checks every intermediate quote along consistent arbitrage swaps. This isolates the conditional decay branch from classifier reachability; it does not claim that every parameter set naturally produces long runs of the same classification. The other transition tests and the 2,000-swap stress test use normal initialization.

Final artifact audit: the two JSON copies are identical, below the 64,000-byte limit, and contain the exact delivered source and its matching SHA-256. The named output remains untracked. All delivered files are inside the two assigned path prefixes.
