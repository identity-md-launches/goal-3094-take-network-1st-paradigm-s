# Round 1: trade-size toxicity

The source is an independent starting-point implementation. It estimates fair value from the fee-adjusted post-trade spot on the first observed trade of each new step. Quotes offset the spot/fair discrepancy asymmetrically. Each side additionally accumulates a bounded quadratic trade-size impulse and a quadratic consecutive-direction impulse. Both signals decay with elapsed simulation steps, without a history loop. Pressure is capped before the final 10% fee clamp.

The trade-size signal uses amountY/reserveY, with the ratio capped at 5%. The streak tracks the AMM's direction, not the trader's. A change in direction resets the streak; elapsed steps fractionally decay it. No update is possible without a callback: decay is applied at the next trade, and the previously returned quote remains live until then.

Eight slots hold fair price, prior fees, timestamp, two side pressures, last direction, and streak length. All other values are constants or local variables. No external calls, extra state, or history loops.

## Sources consulted

- Official simulator and starter, pinned at [6b6921f8d463314aa7c96234e1be25a25245f704](https://github.com/benedictbrady/amm-challenge/tree/6b6921f8d463314aa7c96234e1be25a25245f704). Simulation math and scoring are taken from this source, not from reported public scores.
- [YQ public write-up](https://github.com/jiayaoqijia/amm-challenge-yq): describes fair-price filtering, asymmetric fees, and cubic toxicity. Its reported scores use its own environment and are not used as measurements here.
- [Dipankar research post-mortem](https://github.com/dipankar/amm-challenge/blob/main/ANALYSIS.md): motivates retaining a fair-price estimator rather than relying solely on large-trade classification. This item specifically tests additional per-side quadratic size and streak pressure. No public Solidity implementation was copied.

## Measurement protocol

The unmodified Rust engine is built in release mode using maturin. Scratch Python code reproduces MatchRunner._build_configs, including the order of numpy uniform draws (retail mean size, arrival rate, sigma) and assigning the seed to both the parameter RNG and Rust config. Both reference and candidate independently compete with the identical fixed 30 bps normalizer on each seed. The paired difference is candidate submission edge minus reference submission edge, never candidate edge minus the normalizer's edge from the same simulation.

Standard error is the sample standard deviation of paired differences divided by sqrt(n). The five worst differences include their simulation seeds. Tuning is confined to seeds 0..1999. Seeds 100000..101999 are reserved for the final comparison with the pinned 50 bps StarterStrategy. No leaderboard submission is made.

## Reproduction details

Build commands (all dependencies and downloaded source are disposable scratch content):

```sh
git clone https://github.com/benedictbrady/amm-challenge.git test/scratch/simulator
git -C test/scratch/simulator checkout 6b6921f8d463314aa7c96234e1be25a25245f704
python3 -m venv test/scratch/venv
test/scratch/venv/bin/pip install maturin numpy py-solc-x pyrevm
test/scratch/venv/bin/pip install -e test/scratch/simulator
# With a Rust toolchain and the virtual environment active:
maturin develop --release --manifest-path test/scratch/simulator/amm_sim_rs/Cargo.toml
amm-match validate candidates/size-toxicity/Strategy.sol
```

The custom measurement harness uses the following config construction, matching the official CLI defaults. The seed offset changes both the parameter draw and the engine seed; merely changing the Rust seed would not reproduce the specified randomized configurations.

```python
from amm_competition.competition.config import build_config
import numpy as np

def make_configs(start, n):
    configs = []
    for seed in range(start, start + n):
        rng = np.random.default_rng(seed)
        mean_size = rng.uniform(19.0, 21.0)
        rate = rng.uniform(0.6, 1.0)
        sigma = rng.uniform(0.000882, 0.001008)
        configs.append(build_config(
            seed=seed, gbm_sigma=sigma,
            retail_arrival_rate=rate, retail_mean_size=mean_size))
    return configs
```

Compile each source with `SolidityCompiler().compile(source)` and get the 30 bps opponent from `get_vanilla_bytecode_and_abi()`. Pass creation bytecode as `list(bytecode)` to `amm_sim_rs.run_batch(candidate, vanilla, configs, workers)`. Collect `result.edges['submission']` in config order. Batches contain 20 simulations to bound memory, since the unmodified engine retains all 10,000 step records. Batch boundaries do not affect individual seeded simulations. No Rust source is modified.

For differences `d = candidate_edges - reference_edges`, report `d.mean()` and `d.std(ddof=1)/sqrt(len(d))`. The score on seeds 0..999 is the mean of the first 1,000 candidate edges from the 2,000-seed training run. SHA-256 hashes always cover the exact full Solidity source bytes, including comments.

## Check notes

The initial implementation compiled without warnings. `amm-match validate` passed, including deployment and initialization. The official 20-seed CLI smoke run returned 516.59, matching the custom harness (516.5867031359468).

A direct pyrevm test executed 2,000 callbacks with the executor's 250,000 gas limit. It exercised buy/sell direction changes, repeated same-direction trades, zero/tiny/large amounts, and timestamp gaps up to 100. All calls succeeded and fees stayed within [0, 10%]. A separate mechanism test confirmed a doubled size yields a fourfold size impulse, pressure stays side-specific, repeated trades increase pressure, and elapsed steps reduce stored pressure.

One initial scratch assertion compared the final bid fee before/after a timestamp gap and failed: the gap also updates fair value, so final fees need not decline even when pressure decays. The assertion was repaired to compare the stored pressure directly; no source change was necessary. This is a test correction, not a suppressed strategy failure.

## Final scoreboard

Delivered configuration: **L**. Source SHA-256: `8f4f86fa6911e58125fd4c95683015cb84a615813ff2aaf9d1d64bd05e6a889e`. Seeds 0..999 mean edge: **484.98904446**. Holdout mean edge: **484.69760452**. Holdout wall seconds/simulation: 0.237774.

The frozen final L source also passed `amm-match validate`, 2,000 direct gas-limited callbacks, and the mechanism checks. Its measured fresh candidate-plus-starter comparison took 721.02 seconds, below the 1,500-second allowance.

All coefficient comparisons below use 2000 paired training seeds 0..1999. None of these rows alone constitutes a promotion. BASE and STREAK_GAIN literals are multiplied by 1e12; ALPHA and SKEW use a denominator of 1000. DECAY=1000 throughout; SKEW=1000 except L=500 and M=1500. The final source reconstructs every tested variant by replacing only these constants.

| ID | Base bps | Alpha | Size gain | Streak bps | Mean edge (2000) | Difference vs A | SE | SHA-256 |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| L | 25 | 0.26 | 30 | 0.1 | 483.771718 | +4.351256 | 0.406592 | `8f4f86fa6911e58125fd4c95683015cb84a615813ff2aaf9d1d64bd05e6a889e` |
| E | 25 | 0.26 | 0 | 0 | 480.573098 | +1.152636 | 0.185157 | `bed6efa78b24c0941c4a209cdcc1113bd6442680233a19c588f642c28a7db983` |
| A | 25 | 0.26 | 30 | 0.1 | 479.420462 | +0.000000 | 0.000000 | `301844e4e51ecd53db5e0cff90a669a5ad3ed65d1156499615ffb43befdfd32e` |
| C | 30 | 0.26 | 30 | 0.1 | 474.015961 | -5.404501 | 0.236848 | `7f06e747579a62f2a881481363c5759ea0c5873458c039b2b7fcfc9c84abb8ec` |
| I | 25 | 0.1 | 30 | 0.1 | 472.361533 | -7.058929 | 0.386702 | `a8a73fcec10548f226bb9b0b2884310d3740acc567f4c2d99736814c0f6b51cc` |
| J | 30 | 0.1 | 30 | 0.1 | 466.804018 | -12.616445 | 0.401397 | `785fb4fa539b56d64b979418f6b4bf50ddfe3dbfe106e6a6ea937dff170cfb57` |
| K | 35 | 0.1 | 30 | 0.1 | 460.589196 | -18.831267 | 0.406595 | `fb5d18d8567e5887c9105ee39db0c97ce32913d21617d758973f44e8d0fc4d45` |
| G | 40 | 0.26 | 30 | 0.1 | 459.196994 | -20.223468 | 0.314813 | `afe8253dd70278b94a8f274e1aec0551de9f2e604f2b73cfda0e67d31574a62c` |
| D | 25 | 0.26 | 300 | 0.5 | 459.072257 | -20.348205 | 0.365466 | `d3d4ba7557352a064ca9a5763883b69709e71eab81c82ee8f0b8b54b853f6a8d` |
| B | 25 | 0.6 | 30 | 0.1 | 426.553962 | -52.866500 | 0.452563 | `c22645615e226ce4e28fd42895b3c98c5116fdff99e7daf5da4ea604cf70125f` |
| F | 40 | 0.6 | 30 | 0.1 | 413.701283 | -65.719179 | 0.464017 | `3995166e51b97669e75f304362e7c68a3f9f1b698448221bfc37f24eeeeb5667` |
| H | 50 | 0.6 | 30 | 0.1 | 400.828924 | -78.591538 | 0.483106 | `2a98241b63c1d4552e7d14d7ee5357412e4a5ebb965118f502750a06ae826e30` |
| M | 25 | 0.26 | 30 | 0.1 | 242.947475 | -236.472987 | 1.261546 | `8970f9a5b1f342b3a36426d096dab9b2b6aa913939a81b1fbd674569e6251f79` |

E is a mechanism ablation, not a deliverable candidate. The initial A gain over the starter is +110.259367 on the holdout; see the independent training paired result in JSON. Every row's five worst training runs are in `result.json`.

### Fresh-seed promotion decisions

| Rank | Promoted source | Holdout mean edge | Previous source | Paired gain | SE | n |
|---:|---|---:|---|---:|---:|---:|
| 1 | L | 484.697605 | A | +4.936936 | 0.440317 | 2000 |
| 2 | A | 479.760668 | StarterStrategy | +110.259367 | 0.859142 | 2000 |

Clean A minus E toxicity ablation on 2000 training seeds: **-1.152636 ± 0.185157 SE**. This isolates adding the initial size and streak signals, rather than changes to the fair-value filter or quote skew.
At the initial settings, adding toxicity reduced edge. The selected improvement comes from quote-skew calibration; an isolated toxicity gain for the final configuration has not been established. The final source retains the requested nonzero size and streak mechanism.

Final gain over starter: **+115.196303 ± 0.733774 SE**. Gain over the local previous best: **+4.936936 ± 0.440317 SE**. Both use seeds 100000..101999, n=2000. The holdout was used only for the stated promotion test, not coefficient selection.

Five worst final paired differences versus starter:

| Seed | Difference |
|---:|---:|
| 101573 | +59.69740816 |
| 100645 | +60.28773231 |
| 100818 | +60.39195821 |
| 100274 | +62.54208611 |
| 100068 | +62.70602643 |

The final JSON includes the complete source, exact hash, every training comparison and worst-five list, fresh comparisons, three follow-ups, validation evidence, and citations. The required artifact JSON is byte-identical to the candidate JSON. No network leaderboard submission was attempted.
