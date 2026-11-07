# Flow estimation — round 1

Delivered mode: **flat**. SHA-256: `7024d164e7dd1b347b7ec9d5339587e21938c71426bd2454d146806911809f48`.

Score on seeds 0–999: **493.978671** edge. Fresh required subset versus Starter: **124.422222 ± 0.859334 SE (n=2000)**. Pooled fresh comparison versus Starter: **124.106242 ± 0.490993 SE (n=6000)**. Paired gain over the previous promoted best: **124.106242 ± 0.490993 SE (n=6000)**.

The tested adaptive table versus the constant control earned **-0.001239 ± 0.035151 SE (n=6000)**. Adaptive promotion: **no**. The primary 2000-seed subset and the predeclared 4000-seed replication are both included in the JSON. No tuning used either holdout.

Timing: 0.160705 mean wall seconds per simulation over the 6000 fresh runs, eight workers, compilation excluded. The initial 20-simulation probe measured 0.118126 seconds/simulation.

## Mechanism and identification

This item studies an online estimate of simulation-level retail arrival rate and size. It uses only trades received by its own AMM. A trade after another trade at the same timestamp is certainly retail: the Rust engine performs at most one arbitrage against this AMM before routing that step's retail orders. First trades are excluded from the retail training sample. Elapsed exposure includes timestamps at which the AMM received no trade; a timestamp gap contributes its full duration.

These observations are selected samples. Routing can send an order entirely to the normalizer, orders that reach both pools are split, and excluding the first trade also excludes some retail orders. Multiplying the observed count by a guessed inclusion factor and doubling the observed size does not identify the latent parameters without calibration. The submitted mechanism therefore uses a training-calibrated affine estimate, shrinks early observations with a 512-step prior, clamps estimates to the simulator's parameter support, and selects a spread from a small rate/size table. The estimates are policy-dependent; changing the underlying pricing rule warrants recalibration.

The pricing layer estimates fair price from the first trade's terminal fee-band edge, filters that observation, and holds the estimate fixed during later trades at that timestamp. Fees are asymmetric around that estimate: a retail displacement increases the fee in the direction in which arbitrage would restore fair price. This is a probabilistic inference, not a perfect arbitrage label. In particular, a first trade can be retail.

## Measurement protocol

Simulator source: https://github.com/benedictbrady/amm-challenge/tree/6b6921f8d463314aa7c96234e1be25a25245f704 . The repository supplied for this item was empty; that exact revision was cloned into `test/scratch/amm`. Dependencies, toolchains, tests and measurement scripts are scratch only and are not part of the submission.

Configurations copy `MatchRunner._build_configs`, replacing the loop index by the requested seed offset. For each seed, NumPy's `default_rng(seed)` draws mean size U(19,21), arrival rate U(0.6,1.0), then sigma U(0.000882,0.001008), in that order. Every simulation has 10,000 steps, initial reserves (100,10000), price 100, zero drift, dt=1, lognormal size sigma=1.2, and buy probability 0.5. Each strategy is run separately against the compiled fixed-30-bps normalizer, never directly against the reference strategy. Differences are then paired by seed.

For differences d_i = candidate edge_i - reference edge_i, SE = sample_std(d, ddof=1)/sqrt(n). The five worst runs mean the five smallest differences, including the seed. Parameter exploration uses only seeds below 100000. Final seed offsets are reserved before tuning and are not used to select table entries. Training comparisons are not promotions. A promotion requires mean difference > 2*SE on a fresh comparison.

Diagnostic instrumentation in scratch adds final storage values to extra keys of the returned PnL map, after all trades and edge scoring. It does not modify routing, randomness, fees, or edge accumulation. Its edge results were checked bit-for-bit against the unmodified engine on the initial 20 seeds. The final comparison is run with unmodified simulator source.

## Checks and build notes

The scratch Python installation initially lacked `ensurepip`, so the environment was bootstrapped with `get-pip.py`. Rust was installed locally; the first pyrevm installation attempt preceded Rust and failed, then succeeded. A diagnostic engine rebuild initially lacked `maturin` on PATH and succeeded after adding the virtual environment's bin directory. No requester input or account credentials were needed.

`SolidityCompiler` uses solc 0.8.24, optimizer runs=200, viaIR, and Paris EVM. Its checks restrict state to the inherited 32-slot array and reject forbidden opcodes. Direct pyrevm calls exercise initialization, timestamp zero, multiple same-step trades, a 99-step gap, both sides, and large displacements; all calls run under the 250000-gas limit. Separate storage assertions verify that only later same-step trades increment the retail counter and that exposure increases by elapsed steps.

## Sources

- [Simulator and rules at the requested revision](https://github.com/benedictbrady/amm-challenge/tree/6b6921f8d463314aa7c96234e1be25a25245f704).
- [Algebra, “AMM fee challenge: notes from our run on Optimization Arena”](https://www.linkedin.com/pulse/amm-fee-challenge-notes-from-our-run-optimization-arena-qe3ff), March 27, 2026. This public write-up describes long-term flow/volatility reconstruction, asymmetric fees and first-in-block arbitrage. It supplies conceptual context, not code or numerical parameters used here.

## Table fitting

Two response surfaces were fit to paired per-seed differences, with linear interactions in true lambda and true mean size: spread response from 14, 18, nominal 22, and 26 bps; first-trade observation gain response from 0.10, 0.25, and 0.50. The response models are quadratic in the tuned parameter. True parameters are used only offline to fit a table; the contract sees only its online estimates. For table entries, the estimated-parameter bins use their conditional calibrated prediction means, retaining shrinkage instead of treating noisy estimates as exact latent values.

The nominal-22-bps point uses the earlier naive table with gain 0.25, rather than an exactly constant fee: the censored estimates drive it almost always to 22 bps after warm-up. Thus the response fit is approximate; the complete fitted policies are subsequently measured directly.

The constant control uses the global fitted optimum, 17.6 bps and gain 0.227. Adaptive variants change both spread and gain by row/column; rate-only and size-only versions hold the other dimension at its middle bin. This control prevents global parameter retuning from being attributed to flow estimation. Interactions between spread and gain were not fit jointly, so this is a starting point rather than a claim of a globally optimal policy.

Rows are estimated lambda <0.733333, <0.866667, and the remaining values. Columns are estimated mean size <19.6667 Y, <20.3333 Y, and the remaining values.

Joint spread table, in bps:

| lambda bin | low size | middle size | high size |
|---|---:|---:|---:|
| low | 17.7 | 17.9 | 18.3 |
| middle | 17.4 | 17.7 | 18.0 |
| high | 17.1 | 17.3 | 17.7 |

Joint first-trade observation gains:

| lambda bin | low size | middle size | high size |
|---|---:|---:|---:|
| low | 0.240 | 0.236 | 0.233 |
| middle | 0.230 | 0.227 | 0.224 |
| high | 0.221 | 0.218 | 0.215 |

Calibration uses seeds 5000–5199 under the 18-bps/quarter-gain policy. Independent estimator diagnostics use seeds 6000–6199 and are not performance promotion tests. The raw proxies are count/exposure and classified Y sum/count. Calibration is lambda_hat = clamp(0.190170 + 2.341162 * count/exposure, 0.6, 1.0) and size_hat = clamp(11.787378084440381440 + 0.690642 * Y_sum/count, 19, 21). The 512-step prior contains 133 observations with a Y sum of about 1581.54. Coefficients are quantized to integer arithmetic in the contract.

The initial uncalibrated table was a failed experiment: guessed inclusion/share corrections drove estimated lambda far below its true support and mean size above it, largely collapsing the lookup onto one cell. A bounded price-update experiment also failed badly; its low score is consistent with stale price estimates. Neither is promoted.

Final holdout plan, declared before observing any fresh-seed results: first report seeds 100000–101999, then replicate on 102000–105999, and gate promotion on the pooled 6000 paired differences. No table changes are allowed after this point. All reported edge values are the Rust result's `edges['submission']`, not a separate scoring reimplementation.

## Ranked promotions on pooled fresh seeds

| Rank | Policy | SHA-256 | Fresh mean edge | Gain over prior | SE | n |
|---|---|---|---:|---:|---:|---:|
| 1 | fitted_flat | `7024d164e7dd1b347b7ec9d5339587e21938c71426bd2454d146806911809f48` | 491.857420 | 124.106242 | 0.490993 | 6000 |

## Training scoreboard (not promotions)

Every row uses the same 2000 seeds 0–1999 against Starter; each policy separately competes against the fixed 30-bps normalizer. Full hashes and five worst paired runs are in result.json.

| Candidate | SHA-256 | Mean edge | Paired gain vs Starter | SE |
|---|---|---:|---:|---:|
| fitted_joint | `e522b7653f37b078bc80a46bbaa42548604683576cd391a4e418b4f879c07fc0` | 493.013044 | 124.208623 | 0.785340 |
| fitted_rate | `bd07cda9e5ff1bc0ca48ba5c63b1825f2f1ef1b023bf9c7d798ebf0889b75ebd` | 492.946086 | 124.141666 | 0.783701 |
| fitted_size | `88077777131cf62131995aea38d9246270e81f425eee963c76a0edf1149a7d2d` | 492.944014 | 124.139593 | 0.781636 |
| fitted_flat | `7024d164e7dd1b347b7ec9d5339587e21938c71426bd2454d146806911809f48` | 492.849856 | 124.045435 | 0.780294 |
| a25flat18 | `fea471b374bfcb76008714b843003cc58802f38622191e507c69fa79c29c32c5` | 491.509408 | 122.704987 | 0.768603 |
| a25flat14 | `7e7bd8ecb3a218ee2a9908d7f817d84122e46ae4eeb771138d6be798948cf53f` | 490.777061 | 121.972640 | 0.766012 |
| alpha25 | `6d3d0b792631a031089df3575c0b40ae57b348b58f8a406a07aeba3fc9efd729` | 490.508379 | 121.703959 | 0.773920 |
| a25flat26 | `4551de65b9a719d9db62bee468ccc7e63fdeec50cb6109e22ea604f4205cf2f1` | 488.022306 | 119.217885 | 0.779190 |
| alpha10 | `9fcc1905e34605ec2d8fccd69d47c1193aa0f4eb0273f707f1e31c6dfff4f268` | 483.521210 | 114.716790 | 0.840001 |
| alpha50 | `7ebb90ffbfa59a04aa3559ad9665568cd1842a8eaa9c9238afc1c2a9b10e83de` | 456.908434 | 88.104013 | 0.668634 |
| soft | `66cc37a2e237f0c4d36c52df85b965b1c4394dba93ac0052dee803b6b85ef130` | 444.941540 | 76.137119 | 0.832266 |
| flat26 | `359756485ed92e0132c4821ccf034ffff87c75412d3490ca81286f417c1f73c0` | 391.389121 | 22.584700 | 0.511820 |
| flat22 | `39085c6ffabf641940d9295e78c277b9804f756c4568cfd37d250b2baf6c48e1` | 389.673056 | 20.868635 | 0.500800 |
| flow22 | `f5c06d250904870c31f1776ca436baf297d49453dc5ffd0d949e4909ca5d1e52` | 389.668819 | 20.864398 | 0.501043 |
| flat18 | `ddf4e615fd6a72d662d745c31de45014068a5313cc00bce15604c0d872bae1ed` | 387.060147 | 18.255726 | 0.500508 |
| alpha100 | `4b1fd5b26fd57c2b890fc8d795088a7d0e748bb759e8478c0fc1437a35722806` | 273.554663 | -95.249758 | 0.517106 |
| robust20 | `0c8f41b19d52ee32c860f13bc14ec5b0110bdc91c5c13d255405983066b64865` | 223.164575 | -145.639846 | 1.399094 |

## Component ablations (training only)

| Comparison | Paired mean gain | SE | n |
|---|---:|---:|---:|
| rate_only vs fitted_flat | 0.096230 | 0.053138 | 2000 |
| size_only vs fitted_flat | 0.094158 | 0.043771 | 2000 |
| incremental_size vs fitted_rate | 0.066958 | 0.036079 | 2000 |
| incremental_rate vs fitted_size | 0.069030 | 0.052867 | 2000 |

These component comparisons are exploratory. Only the selected joint/one-dimensional policy is compared to the constant control on the fresh promotion seeds.

## Independent estimator diagnostics

Calibration seeds 5000–5199; diagnostic seeds 6000–6199. These 200 diagnostics measure parameter separation, not promotion. Metrics below use the actual finite-prior online estimates under the selected adaptive policy.

| Parameter | Correlation | RMSE | Population SD | Bias | Estimate in bottom true quartile | Estimate in top true quartile |
|---|---:|---:|---:|---:|---:|---:|
| rate | 0.956126 | 0.033111 | 0.112530 | 0.001142 | 0.667651 | 0.942012 |
| size | 0.708284 | 0.397787 | 0.556702 | 0.034842 | 19.762925 | 20.372392 |

The score on seeds 0–999 is a training score and is not a leaderboard prediction. No global best contract beyond Starter was supplied in the initially empty checkout. The flow experiment is compared to the stronger constant-table control after population parameter tuning; the JSON identifies the previous promoted reference for the delivered source. The JSON contains the full constant-control and tested adaptive sources for replication.

The full tested flow-table contract is also delivered as `FlowStrategy.sol`. It was not promoted. Load it independently (it also defines `contract Strategy`) to reproduce the adaptive experiment; `Strategy.sol` retains the promoted constant control.

## Final validation commands

- `test/scratch/venv/bin/amm-match validate candidates/flow-estimate/Strategy.sol` — passed.
- `test/scratch/venv/bin/python test/scratch/test_contract.py` — passed.
- `test/scratch/venv/bin/python test/scratch/test_accounting.py` — passed.
- `git -C test/scratch/amm diff --exit-code` — passed.
- `test/scratch/venv/bin/amm-match validate candidates/flow-estimate/FlowStrategy.sol` — passed.
- `test/scratch/venv/bin/python test/scratch/test_contract.py candidates/flow-estimate/FlowStrategy.sol` — passed.
- `test/scratch/venv/bin/python test/scratch/test_accounting.py candidates/flow-estimate/FlowStrategy.sol` — passed.

The final checks used the exact delivered sources. Initialization, both swap directions, timestamp zero, same-step trades, long gaps and large reserve displacements passed. The 3000-swap randomized test also matched integer counts, Y sums and exposure exactly at every call, under 250000 gas per call. The final simulator checkout has no tracked source diff from the requested commit. The two result JSON files are byte-identical and each is below 64000 bytes.
