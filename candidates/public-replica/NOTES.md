# Public replica, round 1

Delivered `Strategy.sol` is a byte-for-byte copy of YQ at `3e9dc7d5a6192c88b562a0f8d9c172ca566ec94d`. No parameter tuning or semantic modifications were made. It is self-contained apart from the two challenge-provided imports.

SHA-256: `00fae418c49cd681ad0879c6f96ebed0163fab5a660b38030f11e6947a39afd4`

Seeds 0..999: **524.62711115** mean edge (1000 simulations).

Fresh seeds 100000..101999: candidate **524.19428705**, starter **369.50130144**; paired gain **154.69298562**, SE **0.94619106** (n=2000). This is also the gain over the previous best because the starter was this item's only inherited reference. Promotion requires gain > 2 SE and this comparison passes. No claim of a new overall leaderboard best is made.

## Mechanism

Replicate the strongest measured public implementation: jiayaoqijia YQ, unchanged. Eleven slots maintain bid/ask, timestamp, fair-price estimate, volatility, arrival rate, size, toxicity, activity, direction and per-step count. Reconstruct fee-band-implied price using the previous fee; blend first-in-step observations at 26% and later observations at 5%, behind a sigma-dependent outlier gate. Decay signals on elapsed steps. Fees combine a flow/volatility base, nonlinear toxicity and activity widening, directional pressure, asymmetric stale-price protection/discount, trade-aligned boosts, and tail compression. There is no direct fair-price observation or explicit arb label; these are estimators. Reject both Dipankar candidates on paired training results and freeze YQ before holdout evaluation.

The only loop in YQ is exponentiation by squaring, with exponent capped at eight (at most four iterations). It never traverses history. Persistent state occupies slots 0..10. Fees are clamped to 10%. The public code does not explicitly optimize an inventory target. Its stale-price skew responds to the pool's position relative to its inferred fair price.

The implied-price identity is exact for a profitable arbitrage fill ending at the band edge. For retail it is only a noisy observation; first trade in a timestamp is not guaranteed to be arbitrage. The strategy's 3% gate floor is much larger than nominal per-step sigma, and its activity/sigma values are proxies rather than unbiased environment estimates.

## Ranked promotions

| Rank | Strategy | SHA-256 | Score, seeds 0..999 | Fresh paired gain over predecessor | SE | n |
|---|---|---|---:|---:|---:|---:|
| 1 | YQ exact replica | 00fae418c49cd681ad0879c6f96ebed0163fab5a660b38030f11e6947a39afd4 | 524.62711115 | 154.69298562 | 0.94619106 | 2000 |

Only one promotion; no inherited dynamic best was supplied. Training rejected WinningV5 and SigmaAdaptive. Their comparisons and five worst per-seed differences follow.

## Scoreboard and paired comparisons

All differences are candidate minus named reference; SE uses sample standard deviation (ddof=1) / sqrt(n).

### YQ exact public replica

SHA-256: `00fae418c49cd681ad0879c6f96ebed0163fab5a660b38030f11e6947a39afd4`. selected; only promotion is starter to YQ on untouched holdout.

Reference: contracts/src/StarterStrategy.sol; seeds 100000..101999; n=2000; mean difference=154.6929856151; SE=0.9461910611.

| Seed | Difference |
|---:|---:|
| 101573 | 74.7824717467 |
| 100645 | 75.8107683305 |
| 100236 | 79.7912459245 |
| 100631 | 80.0246636410 |
| 100274 | 80.7654270337 |

### Dipankar WinningV5

SHA-256: `dc8dff6827ecc6aadecfe9936edd4fa8b48fc402dc2fa5257503f0feb822bd05`. rejected.

Reference: YQ replica; seeds 2000..3999; n=2000; mean difference=-232.8756693117; SE=1.1826898210.

| Seed | Difference |
|---:|---:|
| 3582 | -509.6713173770 |
| 2174 | -480.5693889498 |
| 3713 | -452.7082049225 |
| 2870 | -444.9147117610 |
| 2284 | -441.8432962912 |

### Dipankar SigmaAdaptive

SHA-256: `84da373d4ecc47b5ecaa96adfcc432ad62825a0c608e7529404fa8a0184cdf90`. rejected.

Reference: YQ replica; seeds 4000..5999; n=2000; mean difference=-5.0518059319; SE=0.0413874306.

| Seed | Difference |
|---:|---:|
| 4124 | -17.4488069133 |
| 4750 | -16.8752965479 |
| 4057 | -13.2276116935 |
| 4967 | -12.8812737996 |
| 4543 | -12.7440333659 |

## Reproduction and checks

The simulator checkout is pinned to `6b6921f8d463314aa7c96234e1be25a25245f704`; the production engine source was not modified. Python 3.12, release Rust engine, Solidity 0.8.24, optimizer 200, viaIR, Paris EVM. Every strategy plays against the official fixed 30 bps normalizer, separately; this is not YQ versus starter in the same pool pair.

The runner below copies `_build_configs` with an absolute seed offset. It was audited field-for-field against canonical `_build_configs` for seeds 0..19. At each seed, NumPy draws mean size first, arrival rate second, sigma third, then the Rust config gets that same seed. Results are joined by their returned seed. Batches contain twenty configs, with eight Rust workers. Full trajectories are unnecessary.

Dependency/build files and executable scaffolding live only in disposable `test/scratch/public-replica/`, outside the deliverable. Recreate a checkout there, a venv, and the source files from the pinned citations to rerun. Local tool installations and all caches use scratch paths. `SOLCX_BINARY_PATH` points to scratch/solcx (0.8.24), and `TMPDIR` points to scratch/tmp. Commands below use the scratch venv's `python` and `amm-match`.

```text
Fetch each public contract at its recorded immutable GitHub commit and compare with the downloaded bytes
```

Result: "All three matched; the delivered YQ file matches its public source SHA-256 exactly"

```text
Compare the offset-zero config builder to MatchRunner._build_configs for seeds 0..19
```

Result: "All twelve config fields matched exactly for every seed"

```text
git clone https://github.com/benedictbrady/amm-challenge test/scratch/public-replica/simulator; git -C test/scratch/public-replica/simulator checkout 6b6921f8d463314aa7c96234e1be25a25245f704
```

Result: "Pinned checkout verified"

```text
uv venv test/scratch/public-replica/venv; uv pip install --python test/scratch/public-replica/venv/bin/python maturin numpy py-solc-x pyrevm -e test/scratch/public-replica/simulator
```

Result: "Installed checkout-local dependencies"

```text
maturin develop --uv --release --manifest-path test/scratch/public-replica/simulator/amm_sim_rs/Cargo.toml
```

Result: "Release engine built and installed"

```text
amm-match validate candidates/public-replica/Strategy.sol
```

Result: "Validating strategy...\nCompiling strategy...\nStrategy 'yq' validated successfully!"

```text
amm-match run candidates/public-replica/Strategy.sol --simulations 20
```

Result: "Validating strategy...\nCompiling strategy...\nStrategy: yq\n\nRunning 20 simulations...\n\nyq Edge: 560.15; matches first 20 seed results from the custom runner to printed precision"

```text
amm-match validate test/scratch/public-replica/sigma.sol; amm-match validate test/scratch/public-replica/dipankar.sol
```

Result: "SigmaAdaptive and WinningV5 validated successfully"

```text
python test/scratch/public-replica/check_calls.py candidates/public-replica/Strategy.sol
```

Result: {"calls": 10000, "seed": 7, "init_gas": 185532, "max_swap_gas": 92805, "max_gas_case": 0, "fee_bounds_ok": true, "all_calls_success": true}

```text
python test/scratch/public-replica/check_calls.py test/scratch/public-replica/sigma.sol; python test/scratch/public-replica/check_calls.py test/scratch/public-replica/dipankar.sol
```

Result: {"SigmaAdaptive": {"calls": 10000, "seed": 7, "init_gas": 176674, "max_swap_gas": 101182, "max_gas_case": 0, "fee_bounds_ok": true, "all_calls_success": true}, "WinningV5": {"calls": 10000, "seed": 7, "init_gas": 88125, "max_swap_gas": 46350, "max_gas_case": 0, "fee_bounds_ok": true, "all_calls_success": true}}

```text
python test/scratch/public-replica/measure.py --candidate candidates/public-replica/Strategy.sol --reference test/scratch/public-replica/simulator/contracts/src/StarterStrategy.sol --start 90000 --n 20 --out test/scratch/public-replica/pilot.json
```

Result: {"n": 20, "seconds": {"candidate": 2.0752567388117313, "reference": 0.9979317300021648}, "projected_2000_pair_seconds": 307.3188468813896}

```text
python test/scratch/public-replica/measure.py --candidate candidates/public-replica/Strategy.sol --reference test/scratch/public-replica/dipankar.sol --start 2000 --n 2000 --out test/scratch/public-replica/yq-vs-dip.json
```

Result: {"reference": "WinningV5", "seed_start": 2000, "n": 2000, "mean_diff": 232.87566931165858, "se": 1.1826898210430972, "worst": [{"seed": 2505, "diff": 122.98384106711953}, {"seed": 3010, "diff": 124.96769052474102}, {"seed": 2504, "diff": 126.73546533039524}, {"seed": 2951, "diff": 127.66119225362115}, {"seed": 3083, "diff": 128.4113517865482}]}

```text
python test/scratch/public-replica/measure.py --candidate test/scratch/public-replica/sigma.sol --reference candidates/public-replica/Strategy.sol --start 4000 --n 2000 --out test/scratch/public-replica/sigma-vs-yq.json
```

Result: {"reference": "YQ replica", "seed_start": 4000, "n": 2000, "mean_diff": -5.051805931911498, "se": 0.04138743061523041, "worst": [{"seed": 4124, "diff": -17.44880691331548}, {"seed": 4750, "diff": -16.87529654792621}, {"seed": 4057, "diff": -13.22761169353521}, {"seed": 4967, "diff": -12.881273799611108}, {"seed": 4543, "diff": -12.744033365881478}]}

```text
python test/scratch/public-replica/measure.py --candidate candidates/public-replica/Strategy.sol --start 0 --n 1000 --out test/scratch/public-replica/score.json
```

Result: {"n": 1000, "mean_edge": 524.6271111458843}

```text
python test/scratch/public-replica/measure.py --candidate candidates/public-replica/Strategy.sol --reference test/scratch/public-replica/simulator/contracts/src/StarterStrategy.sol --start 100000 --n 2000 --out test/scratch/public-replica/final.json
```

Result: {"reference": "contracts/src/StarterStrategy.sol", "seed_start": 100000, "n": 2000, "mean_diff": 154.69298561513727, "se": 0.9461910610703154, "worst": [{"seed": 101573, "diff": 74.78247174667234}, {"seed": 100645, "diff": 75.81076833047553}, {"seed": 100236, "diff": 79.79124592449145}, {"seed": 100631, "diff": 80.0246636409841}, {"seed": 100274, "diff": 80.76542703368204}]}

### Measurement runner

```python
import argparse, hashlib, json, time
from pathlib import Path
import numpy as np
import amm_sim_rs
from amm_competition.evm.compiler import SolidityCompiler
from amm_competition.evm.baseline import get_vanilla_bytecode_and_abi
from amm_competition.competition.config import build_config, build_base_config, BASELINE_VARIANCE
from amm_competition.competition.match import MatchRunner
p=argparse.ArgumentParser(); p.add_argument('--start',type=int,default=0); p.add_argument('--n',type=int,default=20); p.add_argument('--candidate',required=True); p.add_argument('--reference'); p.add_argument('--out',required=True); p.add_argument('--workers',type=int,default=8); a=p.parse_args()
c=SolidityCompiler()
def compile_file(path):
    src=Path(path).read_text(); r=c.compile(src)
    assert r.success, r.errors
    print('compiled',path,hashlib.sha256(src.encode()).hexdigest(),flush=True)
    return list(r.bytecode)
candidate=compile_file(a.candidate)
reference=compile_file(a.reference) if a.reference else None
vanilla=list(get_vanilla_bytecode_and_abi()[0])
def configs(start,n):
    out=[]
    for seed in range(start,start+n):
        rng=np.random.default_rng(seed=seed)
        out.append(build_config(seed=seed,retail_mean_size=rng.uniform(19,21),retail_arrival_rate=rng.uniform(.6,1),gbm_sigma=rng.uniform(.000882,.001008)))
    return out
# Audit the offset-zero copy against the canonical runner, field for field.
orig=MatchRunner(n_simulations=20,config=build_base_config(seed=None),n_workers=a.workers,variance=BASELINE_VARIANCE)._build_configs()
copy=configs(0,20)
for x,y in zip(orig,copy):
    for field in ('n_steps','initial_price','initial_x','initial_y','gbm_mu','gbm_sigma','gbm_dt','retail_arrival_rate','retail_mean_size','retail_size_sigma','retail_buy_prob','seed'):
        assert getattr(x,field)==getattr(y,field),(field,getattr(x,field),getattr(y,field))
rows=[]; times={'candidate':0.,'reference':0.}
for offset in range(0,a.n,20):
    cfg=configs(a.start+offset,min(20,a.n-offset))
    t=time.perf_counter(); results=amm_sim_rs.run_batch(candidate,vanilla,cfg,a.workers).results; times['candidate']+=time.perf_counter()-t
    ca={r.seed:float(r.edges['submission']) for r in results}
    re={}
    if reference:
        t=time.perf_counter(); results=amm_sim_rs.run_batch(reference,vanilla,cfg,a.workers).results; times['reference']+=time.perf_counter()-t
        re={r.seed:float(r.edges['submission']) for r in results}
    assert len(ca)==len(cfg)
    if reference: assert ca.keys()==re.keys()
    for seed in sorted(ca):
        row={'seed':seed,'candidate':ca[seed]}
        if reference: row.update(reference=re[seed],diff=ca[seed]-re[seed])
        rows.append(row)
    out={'candidate':a.candidate,'reference':a.reference,'seed_start':a.start,'n':len(rows),'mean_edge':float(np.mean([r['candidate'] for r in rows])),'seconds':times,'seconds_per_simulation':times['candidate']/len(rows),'rows':rows}
    if reference:
        ds=np.array([r['diff'] for r in rows]); out.update(mean_diff=float(ds.mean()),se=float(ds.std(ddof=1)/np.sqrt(len(ds))),worst=sorted(rows,key=lambda r:r['diff'])[:5],mean_reference=float(np.mean([r['reference'] for r in rows])))
    Path(a.out).write_text(json.dumps(out,indent=2)+'\n')
    print(json.dumps({k:v for k,v in out.items() if k not in ('rows','worst')}),flush=True)
```

### Gas and fee stress check

```python
import json, math, random, sys
from pathlib import Path
from decimal import Decimal
from amm_competition.evm.compiler import SolidityCompiler
from amm_competition.evm.executor import EVMStrategyExecutor
from amm_competition.core.trade import TradeInfo
r=SolidityCompiler().compile(Path(sys.argv[1]).read_text()); assert r.success,r.errors
e=EVMStrategyExecutor(r.bytecode,r.abi)
result=e.after_initialize(Decimal(100),Decimal(10000)); assert result.success,result
init_gas=e.evm.result.gas_used
x,y,t=100.,10000.,0; rng=random.Random(7); maxgas=0; maxcase=None; bid=ask=Decimal('.0003')
for i in range(10000):
    # Stress repeated timestamps, long idle gaps, large moves and trade ratios.
    t+=rng.choice([0,0,0,1,1,2,8,9,100])
    buy=bool(rng.randrange(2)); ratio=math.exp(rng.uniform(math.log(1e-8),math.log(.5)))
    if buy:
        ax=x*ratio; net=ax*(1-float(bid)); ay=y-y*x/(x+net); x+=net; y-=ay
    else:
        ay=y*ratio; net=ay*(1-float(ask)); ax=x-x*y/(y+net); y+=net; x-=ax
    tr=TradeInfo('buy' if buy else 'sell',Decimal(str(ax)),Decimal(str(ay)),t,Decimal(str(x)),Decimal(str(y)))
    b,a=e.after_swap_fast(tr); bid,ask=Decimal(b)/10**18,Decimal(a)/10**18
    assert 0<=b<=10**17 and 0<=a<=10**17,(i,b,a)
    gas=e.evm.result.gas_used
    assert gas<=250000,(i,gas)
    if gas>maxgas: maxgas=gas;maxcase=i
out={'calls':10000,'seed':7,'init_gas':init_gas,'max_swap_gas':maxgas,'max_gas_case':maxcase,'fee_bounds_ok':True,'all_calls_success':True}
print(json.dumps(out,indent=2))
```

Pilot candidate seconds/seed: 0.103763; projected 2000 pairs: 307.32 seconds, below the 25-minute cap. Full 2000 pairs therefore used. Final candidate seconds/seed: 0.102991; candidate-plus-reference seconds/seed: 0.147097. Timing excludes compilation and is batch wall time, not single-core CPU time.

## Public sources and interpretation

- [Delivered source, byte-for-byte replication; SPDX MIT](https://github.com/jiayaoqijia/amm-challenge-yq/blob/3e9dc7d5a6192c88b562a0f8d9c172ca566ec94d/contracts/src/Strategy.sol)
- [Public mechanism write-up and self-reported 523.21 board score, not independently verified](https://github.com/jiayaoqijia/amm-challenge-yq/blob/3e9dc7d5a6192c88b562a0f8d9c172ca566ec94d/README.md)
- [Historical WinningV1-V5 lineage index](https://github.com/dipankar/amm-challenge/blob/c588ae6c47fc9af2063c9bb1f2efbeb0dd276dab/contracts/README.md)
- [Newer public candidate, measured and rejected](https://github.com/dipankar/amm-challenge/blob/c588ae6c47fc9af2063c9bb1f2efbeb0dd276dab/contracts/src/SigmaAdaptiveStrategy.sol)
- [Public post-mortem on state estimation versus trade classification](https://github.com/dipankar/amm-challenge/blob/c588ae6c47fc9af2063c9bb1f2efbeb0dd276dab/ANALYSIS.md)
- [Public first-party write-up: latent environment estimation, asymmetric fees, and first-trade ordering; no Solidity source supplied](https://medium.com/@crypto_algebra/amm-fee-challenge-notes-from-our-run-on-optimization-arena-4e980dbbd699)
- [Pinned compiler, validator, simulator, starter and normalizer](https://github.com/benedictbrady/amm-challenge/tree/6b6921f8d463314aa7c96234e1be25a25245f704)

The public YQ README claims 523.21 and a 495-simulation cross-seed experiment; the public Dipankar README claims 526.54 for SigmaAdaptive on 500 simulations. These claims were not used to promote a candidate: YQ won our paired evaluation. In particular, a README's number labeled baseline is not evidence that the actual fixed-30-bps normalizer has that score under this pinned engine.

Algebra's write-up describes combining hidden-environment estimates with immediate pool signals, asymmetric fees after retail displacement, and probabilistic use of first-trade ordering. It supplies architectural context, not executable code or a directly comparable score. Dipankar's post-mortem advocates state reconstruction over pure trade-size classification. Our measurements compare their actual source.

## Failures, repairs, and limits

- `UV_INSTALL_DIR=... sh uv-install.sh; RUSTUP_HOME=... CARGO_HOME=... sh rust-install.sh`: Installers initially failed: mktemp could not create /tmp/tmp.XXXXXXXXXX. Repair: Set TMPDIR to checkout-local scratch/tmp and reran successfully. No Solidity source error or file/line diagnostic was emitted.
- `maturin develop --release --manifest-path test/scratch/public-replica/simulator/amm_sim_rs/Cargo.toml`: UV venv has no pip; maturin failed to find pip. Repair: Reran with --uv; release build succeeded. No Solidity source error or file/line diagnostic was emitted.

Initial discovery also tried unavailable `python` (replaced with Python 3.12), and looked for three incorrect source filenames (correct locations were immediately found with `rg --files`). The Paradigm puzzle page was inaccessible through the web tool; the pinned simulator and both named GitHub repositories were accessible. No build was killed, no quota/account failed, and no requester input was needed.

The simulator silently retains old fees on callback error; the separate gas-limited stress run reduces this concern but is not an exhaustive proof. No hidden seeds were used for tuning; final seeds 100000..101999 were opened only after selection was frozen. No source changes followed that evaluation. The output is a starting point, not a claim to beat the supplied leaderboard.

## Three follow-ups

1. Ablate YQ flow/activity terms with 2000 paired tuning seeds and a separate fresh confirmation set.
2. Replace the generic first-trade implied-price blend with a probabilistic arb/retail mixture constrained by the fee band.
3. Estimate normalizer-relative spot and retail arrival conditional on idle gaps to adapt the attract-side discount.

## Delivery audit

Passed JSON parsing and the 64,000-byte artifact limit. Both result JSON copies are identical; embedded code and SHA-256 match the frozen source. Independently recomputed the final paired mean, SE and five worst runs, checked all 2000 unique contiguous holdout seeds, and confirmed the promotion exceeds twice its SE. Git status contains only allowed deliverable paths and all four deliverables remain untracked.
