# Fair-centered, round 1

Selected source: `Strategy.sol`, SHA-256 `f6d066586941de5d92b3660e0ed969436cc7b08b8e4021112886cb35b74538d5`.

Exact fee-on-input quotes centered on a gated fair-price estimate. Only the first callback at a timestamp can update the estimate. The trade must move away from the previous estimate, and its old-fee band-implied price must pass a tolerance of 25 bps times sqrt(max(1, age)) plus the previous accepted relative price jump. Including that jump permits correction after a misclassified retail observation. Otherwise the last inferred price is retained. Bid and ask target spreads start at 10 and 10 bps, respectively, and each widens by 0.1 bps times sqrt(age) since the last accepted observation. Exact bid/ask equations are clamped to [0, 10%]. The policy uses seven of the 32 slots and no history scan, assembly or external calls.

Local score, seeds 0–999: **436.185402234** (n = 1,000). Fresh score, seeds 100000–101999: **434.560879022** (n = 2,000).

Fresh paired gain over Starter: **+65.059577585 ± 1.061849822 SE**. For this item, pinned Starter was the comparison incumbent and no intermediate candidate was promoted. The gain over this local previous best is therefore identical. The gain clears twice its SE; promoted locally.

## Mechanism and limitations

The post-trade reserve ratio is `spot = reserveY/reserveX`. An optimal arbitrage implies `p = spot*(1-oldBidFee)` when the AMM bought X, or `p = spot/(1-oldAskFee)` when it sold X. The **old** fee is essential. These identities alone cannot distinguish an arbitrage from retail.

The classifier therefore requires a first callback at that timestamp, a trade direction away from the stored estimate (`priorSpot <= p` for an AMM buy, `priorSpot >= p` for a sale), and a consistency check. Its tolerance is `25 bps * sqrt(max(1, elapsed)) + previousAcceptedRelativeJump`. A naive narrow gate can accept a retail trade and then reject the larger genuine correction. Remembering the accepted jump allows that correction to pass. The point estimate is replaced by the exact band-implied observation only after this test; all other callbacks retain it.

The spreads are `sBid = 10 bps + 0.1 bps*sqrt(age)` and `sAsk = 10 bps + 0.1 bps*sqrt(age)`, each capped at 10%. Quote algebra is `bidFee = 1 - p*(1-sBid)/spot` and `askFee = 1 - spot/(p*(1+sAsk))`, then clamp each fee to [0,10%]. For interior fees, the effective quotes equal `p*(1-sBid)` and `p*(1+sAsk)`. At the clamps, a target can be unreachable. The callback tests verify both equalities and the correct direction of each clamp.

| Slot | Meaning |
|---:|---|
| 0 | Last accepted inferred fair price |
| 1 | Last accepted observation timestamp plus one |
| 2 | Last callback timestamp plus one; zero denotes no callback yet |
| 3, 4 | Previously returned bid and ask fees |
| 5 | Previous post-trade spot price |
| 6 | Absolute relative jump of the most recently accepted observation |

The remaining 25 slots are unused. The simulator deploys a fresh contract for every run. Time-zero callbacks are handled using timestamp tags. Square roots use the supplied arithmetic helper; there is no loop over trade history. Spreads can change only on callbacks, so the strategy cannot actively reprice during silent steps.

The delivered file is copied byte-for-byte from the measured variant `b10_a10_wtenth_g25_away_jump`. No source change or tuning follows the final holdout run.

Controlled training ablation: at identical 20 bps bid/ask spreads, 2 bps age widening and a 25 bps gate, adding the previous accepted jump to the gate improved edge by **+170.347043 ± 1.472321 SE** on the same 2,000 seeds. This isolates the recovery mechanism from spread tuning.

- Trade identity is not observable exactly: retail can pass the gate and true arbitrage can fail it. A band-implied price is exact only conditional on correct classification.
- The square-root aging term is a tuned risk margin, not a calibrated confidence interval; it does not fully exploit the information in an interval without arb callbacks.
- Fee floors and the 10% cap can prevent exact centering when spot is far from the estimate.
- Results concern the pinned simulator. Public leaderboard scores were not independently replicated, and no leaderboard rank or submission is claimed.

## Ranked promotions

| Rank | File | Fresh edge | Gain vs previous best | SE | n |
|---:|---|---:|---:|---:|---:|
| 1 | Strategy.sol | 434.560879 | +65.059578 | 1.061850 | 2000 |

## Complete tuning scoreboard

All comparisons below use seeds 0–1999, n = 2,000. Differences use per-seed pairing. These are exploratory comparisons, not promotions. Zero-widening policies are retained as ablations but are ineligible for the final source because the item calls for positive widening with elapsed time. Starter SHA-256: `8f2cea337f6736105f58c6758da6c3ebf002951d34492bcd5b7101bef2d1e7f3`; mean edge: 368.804420618. The selected final source has mean edge 435.641703710 on these seeds.

| Candidate | Mean edge | Δ vs Starter | SE | Δ vs selected | SE | SHA-256 |
|---|---:|---:|---:|---:|---:|---|
| b10_a10_wtenth_g25_away_jump | 435.641704 | +66.837283 | 0.949536 | +0.000000 | 0.000000 | `f6d066586941de5d92b3660e0ed969436cc7b08b8e4021112886cb35b74538d5` |
| b20_a20_w0_g25_away_jump | 435.423918 | +66.619498 | 0.995914 | -0.217785 | 0.602467 | `e0c9564ee1fc84a0b33d3b339e829ff7c53d165cb8d79cf0947e0ed569500da4` |
| b20_a20_wtenth_g25_away_jump | 434.787051 | +65.982631 | 0.993085 | -0.854652 | 0.597248 | `f0aa101fcbbbb31d0771a1901e2152638ce50c6411f9883443dd35e709dfcacf` |
| b10_a10_whalf_g25_away_jump | 433.311203 | +64.506782 | 0.973708 | -2.330501 | 0.347381 | `5acc23a321650c2190ec7ce97df476d77564f7200144c62f9f987b3645fce7bf` |
| b10_a10_w1_g25_away_jump | 430.895782 | +62.091362 | 0.999737 | -4.745921 | 0.482420 | `999d0bdfd790d25d8d876e673bb98ba10da030438216f41df19c489bcdc892b1` |
| b15_a5_w2_g25_away_jump | 426.788981 | +57.984561 | 1.006141 | -8.852722 | 0.578141 | `cb217981d3a0e8e576a68f808b697e2ce715d48b327d6a2e9d9f2153fcda578c` |
| b5_a15_w2_g25_away_jump | 426.063311 | +57.258891 | 1.002858 | -9.578392 | 0.559235 | `395a944512e9bb2b14d9f0889dab2182b811889b4c3c6ce153958f8f9d39d3ef` |
| b10_a10_w2_g40_away_jump | 425.059402 | +56.254982 | 0.767915 | -10.582302 | 0.540721 | `4a129eedc1ea4d909d85ed022deb5d514fc440ad095073e62f7f0d6366ab268e` |
| s10_w2_g25_away_jump | 424.215754 | +55.411334 | 1.029391 | -11.425949 | 0.558138 | `e3c39ec06446d90c3d1f143c2f077a9142c35ca462c47c0ed444402e7f334efc` |
| s20_w2_g25_away_jump | 418.362798 | +49.558377 | 1.057275 | -17.278906 | 0.728536 | `a33c0b5b1489a367db190815e7706f2c1d950d8bcd8d4ecf28c02a3dc40cb615` |
| s30_w2_g25_away_jump | 404.813537 | +36.009116 | 1.117459 | -30.828167 | 0.819467 | `03487ee9f73f99cf99198bfceb28c7bc562f6a34a966655933bab25d574ab3f3` |
| b40_a40_w2_g100_away | 397.809603 | +29.005183 | 0.804315 | -37.832100 | 0.764468 | `f515f7565a9222657b486abadd678d11de2c79306693c28e1aa2512ec28253f8` |
| b30_a30_w2_g100_away | 397.267331 | +28.462910 | 0.783968 | -38.374373 | 0.747639 | `60fd573767018293930df7347280a0c6b20571e35fa088a5971a862f59a1615c` |
| s20_w2_g100_away | 391.650761 | +22.846340 | 0.772642 | -43.990943 | 0.702721 | `2a41726901ce5701b2719abae4df3941d2a27f059beb064683cb22a8f2b9c532` |
| s45_w2_g1000_away | 390.336259 | +21.531838 | 0.646350 | -45.305445 | 0.713041 | `7babd275c44f40a63dc91506946f6e86679aa9ae0c8d5c07af1a7c5ac719673f` |
| s30_w2_g1000_away | 377.866949 | +9.062528 | 0.644582 | -57.774755 | 0.731236 | `5c9ca64575f7e2a3e59b49e1bcacd56b979dc57929d42f067a22a0c8a8123b36` |
| b60_a60_w2_g100_away | 375.161197 | +6.356776 | 0.832544 | -60.480507 | 0.812523 | `6d3a680d4889a0b115d1a561c6469f1f89c85aba3840d2f030c6525a515500ff` |
| s20_w2_g1000_away | 363.750293 | -5.054127 | 0.656312 | -71.891411 | 0.739939 | `18cbbf15a6bcf81701722d1da5789dd5b1113981cb9160c1bc690ab17df4d5cf` |
| s10_w2_g1000_away | 351.175360 | -17.629061 | 0.672570 | -84.466344 | 0.722781 | `1b0b7afe4af8bdc9762ccbedbf4acc454b7637d68b98ba6bb34a0d5029f51553` |
| s20_w1_small10 | 345.793842 | -23.010578 | 1.117030 | -89.847861 | 1.050256 | `e63537297e898a688ff387a84cc8f4b31486630cfee8a6b26f05e962fbe5e74e` |
| b80_a80_w2_g100_away | 344.291709 | -24.512712 | 0.848045 | -91.349995 | 0.842164 | `d6e785033578dd2a269f45d426e7d23f5bd37cc86681fe1acd43476743eda3bb` |
| s20_w2_tree70 | 331.640126 | -37.164295 | 1.761113 | -104.001578 | 1.582059 | `cb9c3a9d55891488b6abb7588aa5cccd2684ed69d6cddfea28d95760a042dd14` |
| b10_a10_w2_g15_away_jump | 327.929328 | -40.875093 | 1.751579 | -107.712376 | 1.563123 | `f19ddef2421a7104dea88a2687bd6a9b13df201f43e915d041c3d2135825bebe` |
| s20_w2_g50_away | 325.904869 | -42.899551 | 1.326289 | -109.736834 | 1.336186 | `7405da8fd9878f0b52fe007aa759fe7cda75171a8aefbbe063115bf8dd841bd0` |
| s20_w2_tree50 | 304.741383 | -64.063037 | 1.606060 | -130.900321 | 1.414357 | `4d93e3430f3027111d260382169e5db5d02de52a9183a83d85b69676870f99cf` |
| s30_w0_g10000 | 286.190120 | -82.614300 | 0.510886 | -149.451583 | 1.029028 | `b2e52ae3550d44f61049379350327ba49b5b57f9d260079410e13db62581fd14` |
| s20_w2_tree30 | 282.643409 | -86.161011 | 1.447199 | -152.998295 | 1.361918 | `b368c619684ef835b24fc8bb11ab62975dbd3dab7a669a25a3fdccef95fc5585` |
| s20_w2_g25_reset8 | 274.364600 | -94.439821 | 0.725656 | -161.277104 | 1.024430 | `3bba7546ea422b8f85925fabd0b71005d5eff4d5d41778fe0e85010045ec674b` |
| s20_w2_g25_reverse | 251.444902 | -117.359518 | 1.060362 | -184.196801 | 1.122671 | `80138cd12a9e0decd6107272da85ef2bfd65a481c16617b8c6af162730dddff1` |
| s20_w2_g25_away | 248.015755 | -120.788666 | 1.589254 | -187.625949 | 1.464655 | `8a99b90a0f84df0ee113c808e49c09e18c06ceca2892589471e4cc25468741e9` |
| s20_w1_g100 | 244.284895 | -124.519525 | 1.088522 | -191.356808 | 1.262548 | `c1d3aadf84f9a7a6384b7a879c6ee88b8476d0605aa572b61fcf92c2c6227095` |
| s20_w2_regret_absolute | 205.941425 | -162.862996 | 1.296847 | -229.700279 | 1.244261 | `764fb535be9339f8f27c8128f90a3c917e06c0eb42f15dbb47e881ca63359590` |
| s20_w2_regret_squared | 205.730172 | -163.074249 | 1.306022 | -229.911532 | 1.243883 | `ef5c2664ba186e7b1a3d576a1fdc17f6033d2b1374b6268256f874db6ab9f211` |
| s0_w0_g25 | 176.688439 | -192.115981 | 1.244690 | -258.953264 | 1.208747 | `edf63dba49886dfd404b041b132e3b0874bcffbdd8989d8f5d498bef43e31a20` |
| s5_w1_g25 | 171.531926 | -197.272495 | 1.241961 | -264.109778 | 1.207772 | `2dcd08e0de7ccb84be3aedd5934bacc9e9fb375c77e603237e6036c046faacbf` |
| s30_w2_g60 | 170.786201 | -198.018220 | 1.305341 | -264.855503 | 1.341889 | `fe110c58de0c5d252fbd36bda7c6c83bbe19dbd94d9fb625521e08872aae747e` |
| s10_w1_g25 | 169.148631 | -199.655790 | 1.237060 | -266.493073 | 1.208001 | `691ec80137d6adf72a0120ec5260c668f6b35001c96748d7012a64e14dc1e977` |
| s45_w2_g60 | 167.772102 | -201.032319 | 1.314263 | -267.869602 | 1.341203 | `179f234c2779523f80e6852ae4a0ce3616c7e0005968564c17cd47ccaf02a599` |
| s60_w2_g60 | 166.344602 | -202.459819 | 1.322102 | -269.297102 | 1.338905 | `2df3373caf48cce4d086198016597db8a1998d5698c48a18c0192618155db029` |
| initial_s20_w2_g25 | 165.582619 | -203.221802 | 1.247357 | -270.059085 | 1.212662 | `c2832627bab0eb34c781c581420ef0bea3f83b4541548b3b8651223baec932a4` |
| s30_w2_g30_aligned | 162.640307 | -206.164114 | 1.252340 | -273.001397 | 1.219062 | `646067fa9b5feba62a689780ac82069ba7e898033c12250113ac3088cd5a58e8` |

Experiment families:

- `away_jump`: First-event direction away from the stored price; consistency tolerance adds the last accepted relative price jump to the age-based gate.
- `first_event_gate`: First-event fee-band consistency gate; otherwise keep the last inferred price.
- `aligned`: First-event direction toward the stored price, combined with the consistency gate.
- `small`: First-event consistency gate plus amountY/reserveY below 5 bps (about 10 bps spot impact).
- `away`: First-event direction away from the stored price, combined with the age-based consistency gate.
- `reset8`: Consistency gate with an unconditional first-event reacquisition after eight steps without an accepted observation.
- `reverse`: Minimum-innovation gate: accept first-event implied-price changes exceeding the age-based threshold.
- `tree`: Shallow arb classifier fitted on 122461 labeled first callbacks from Python diagnostic seeds 0..23; runtime uses observable features only.
- `regret`: First-event decision tree fitted to expected reduction in absolute or squared price-estimation error; hold otherwise.

The JSON records the five worst paired runs for every row against both references. All candidate sources and native edge arrays were generated in scratch. The delivered source is the selected implementation.

## Fresh worst paired runs

| Seed | Candidate − Starter |
|---:|---:|
| 101235 | -180.068667952 |
| 100742 | -134.890030452 |
| 101437 | -133.674084316 |
| 101021 | -130.275493618 |
| 100040 | -127.127089090 |

## Measurement and reproduction

The simulator was checked out at `6b6921f8d463314aa7c96234e1be25a25245f704`. Its source was not modified. Rust 1.90.0, Python 3.12, maturin, NumPy, py-solc-x, pyrevm and pytest were installed inside scratch. Solidity used the pinned compiler wrapper (0.8.24, optimizer 200 runs, viaIR, Paris). Each strategy runs separately against the official 30 bps normalizer. The native `edges['submission']` is authoritative; the prose sign conventions in the task/README were not used to recompute edge.

Configuration construction copies `MatchRunner._build_configs` with a seed offset: for each seed, instantiate `np.random.default_rng(seed)` and draw mean retail size from [19,21], arrival rate from [0.6,1.0], and sigma from [0.000882,0.001008], in that order. All other parameters use the pinned baseline defaults, including 10,000 steps. A parity check matched all 12 fields on seeds 0–19. The same configurations feed `amm_sim_rs.run_batch(candidate_bytecode, vanilla_bytecode, configs, workers)` for candidate and Starter. Batches of 20 bound memory; no simulation path or step count is shortened.

Compile each source with `amm_competition.evm.compiler.SolidityCompiler`; obtain the normalizer with `amm_competition.evm.baseline.get_vanilla_bytecode_and_abi`. Extract each result's seed and `edges['submission']`. Calculate paired differences by matching seeds, with SE = `std(diff, ddof=1) / sqrt(n)`. The worst five runs are the lowest differences. The 1,000-seed score is the first 1,000 entries of the final 2,000-seed training run.

Tuning used only seeds 0–1999. Final code was fixed and tested before evaluating seeds 100000–101999. No final confirmation seed was used for a parameter or mechanism decision. The initial 20-pair timing pilot projected 275.6 seconds for 2,000 pairs, below the 25-minute exception threshold. The full required sample was completed.

Final native candidate throughput: **0.101625 wall seconds per simulation**, including batching and extraction. It depends on worker concurrency and is not CPU-seconds.

Commands and outcomes:

- `git checkout 6b6921f8d463314aa7c96234e1be25a25245f704 (scratch simulator clone)`: Exact pinned checkout.
- `maturin develop --release --manifest-path test/scratch/fair-centered/amm-challenge/amm_sim_rs/Cargo.toml`: Release Rust engine built and installed with Rust 1.90.0.
- `amm-match validate candidates/fair-centered/Strategy.sol`: Validating strategy...
Compiling strategy...
Strategy 'Fair Centered' validated successfully!
- `python test/scratch/fair-centered/check_strategy.py candidates/fair-centered/Strategy.sol`: {"source_sha256": "f6d066586941de5d92b3660e0ed969436cc7b08b8e4021112886cb35b74538d5", "callbacks": 6629, "same_timestamp_checks": 1683, "accepted_observation_identities": 458, "unchanged_observations": 6170, "initialization_gas": 134664, "max_after_swap_gas": 70615, "fee_bounds_ok": true, "state_slots_ok": true, "fee_band_geometry_checks": 6632, "long_gap_stress_callbacks": 3, "maximum_fee_clamp_hits": 3, "gas_limit": 250000}
- `python test/scratch/fair-centered/sweep.py test/scratch/fair-centered/plan<N>.json (N = 1, 2, 4, 5, 6, 7, 8, 9, 10; individual runs)`: 41 distinct candidates, 2000 paired training seeds each; full statistics in tried.
- `python test/scratch/fair-centered/measure.py candidates/fair-centered/Strategy.sol --reference test/scratch/fair-centered/amm-challenge/contracts/src/StarterStrategy.sol --start 100000 --n 2000 --workers 8`: Full fresh comparison completed; n, standard error and worst five differences in paired.

The callback check uses actual `pyrevm` execution gas, not the adapter’s approximate gas counter. It checks step zero, repeated timestamps, gaps, retained estimates, accepted observations reconstructed with the **old** fee, exact fee-band price geometry up to integer rounding, both clamping directions, fee bounds, and storage bounds across thousands of valid constant-product trades.

Scratch diagnostics with true trade labels used the Python engine only to investigate classification and fit shallow decision trees, not to report scores. The fitted experiments used 122,461 first callbacks from seeds 0–23 and scikit-learn in scratch; the learned classifiers and price-error regressors were evaluated with the same 2,000-seed native protocol as every other candidate. The Python RNG differs from Rust. Fair prices were visible to the diagnostic monitor, never to the submitted strategy.

Repaired setup/check failures:

- Initial Rust 1.85.1 build failed because ruint 1.21.1 requires Rust 1.90. Installed Rust 1.90.0 inside scratch and rebuilt successfully.
- Inline configuration-parity and result-size checks initially could not import the scratch measure module (ModuleNotFoundError); setting PYTHONPATH to the scratch harness directory fixed both checks.
- The diagnostic classifier fit summary initially failed to serialize NumPy int64 leaf/depth counts; converting these counts to Python int fixed the report. No strategy or score data was affected.

## Standalone reproduction

With the pinned simulator installed, save the following as a Python file and run it from the goal checkout. It reconstructs the final paired comparison without the scratch harness. To reproduce the public-style 1,000-seed score, set `SEED_START, N = 0, 1000`.

```python
"""Run from the goal checkout with the pinned simulator installed."""
import gc
import hashlib
import json
from pathlib import Path

import amm_sim_rs
import numpy as np
from amm_competition.competition.config import build_config
from amm_competition.evm.baseline import get_vanilla_bytecode_and_abi
from amm_competition.evm.compiler import SolidityCompiler

SEED_START, N, WORKERS = 100000, 2000, 8
compiler = SolidityCompiler()
source = Path('candidates/fair-centered/Strategy.sol').read_text()
reference = (compiler.CONTRACTS_SRC_DIR / 'StarterStrategy.sol').read_text()
normalizer, _ = get_vanilla_bytecode_and_abi()

def configs(start, n):
    result = []
    for seed in range(start, start + n):
        rng = np.random.default_rng(seed)
        size = rng.uniform(19.0, 21.0)
        arrival = rng.uniform(0.6, 1.0)
        sigma = rng.uniform(0.000882, 0.001008)
        result.append(build_config(seed=seed, retail_mean_size=size,
                                   retail_arrival_rate=arrival, gbm_sigma=sigma))
    return result

def edges(code):
    compiled = compiler.compile(code)
    assert compiled.success, compiled.errors
    output = {}
    for offset in range(0, N, 20):
        batch = amm_sim_rs.run_batch(list(compiled.bytecode), list(normalizer),
                                    configs(SEED_START + offset, min(20, N-offset)),
                                    WORKERS)
        output.update({r.seed: r.edges['submission'] for r in batch.results})
        del batch
        gc.collect()
    assert sorted(output) == list(range(SEED_START, SEED_START + N))
    return np.array([output[seed] for seed in sorted(output)])

candidate_edges, reference_edges = edges(source), edges(reference)
diff = candidate_edges - reference_edges
worst = np.argsort(diff)[:5]
print(json.dumps({
    'code_sha256': hashlib.sha256(source.encode()).hexdigest(),
    'seed_start': SEED_START, 'n': N,
    'mean_edge': float(candidate_edges.mean()),
    'reference_mean_edge': float(reference_edges.mean()),
    'mean_diff': float(diff.mean()),
    'se': float(diff.std(ddof=1) / np.sqrt(N)),
    'worst': [{'seed': SEED_START + int(i), 'difference': float(diff[i])}
              for i in worst]
}, indent=2))
```

## Public sources

- [Pinned AMM challenge simulator](https://github.com/benedictbrady/amm-challenge/tree/6b6921f8d463314aa7c96234e1be25a25245f704): Authoritative engine, compiler, validation, parameter draws and seed semantics.
- [Algebra Finance: AMM fee challenge notes](https://www.linkedin.com/pulse/amm-fee-challenge-notes-from-our-run-optimization-arena-qe3ff): Asymmetric fees, environmental inference and first-trade-only arbitrage ordering.
- [Dipankar: Research Methodology Post-Mortem](https://github.com/dipankar/amm-challenge/blob/main/ANALYSIS.md): Motivated evaluating state estimation; reported external scores were not replicated.
- [Public SigmaAdaptive implementation](https://github.com/dipankar/amm-challenge/blob/main/contracts/src/SigmaAdaptiveStrategy.sol): Read to understand the public filtered-estimation approach; no source copied.

The [Paradigm puzzle page](https://www.paradigm.xyz/puzzles/amm) could not be retrieved by the web tool; the pinned simulator supplied implementation details. Public rankings and claimed scores were not used as local evidence.

## Next experiments

1. Test a two-hypothesis fair-price filter that retains the previous trusted price alongside the latest observation, allowing rejection of suspected retail reads without blocking later arb corrections.
2. Condition age uncertainty on the absence of earlier arb callbacks and the quoted no-arbitrage interval; compare that model with the small positive sqrt(age) widening and the zero-width ablation.
3. Combine this estimator with the strongest independently measured round-one spread/flow policy, then measure its incremental gain over that incumbent on at least 2000 new paired seeds.
