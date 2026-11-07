# Inventory and depth: completed round 1

Selected `inventory_low_spread` using only seeds 0–1999. All candidate comparisons used 2,000 paired seeds against the current best, the supplied 50 bps starter. No training result was promoted. Source selection was frozen before accessing seeds 100000–101999.

Final SHA-256: `f7e00f5098e73c1e4b82436290684a6149bbaeee2e8b1af0af1698c1170bcbd7`.
Canonical score (seeds 0–999): **474.06384169**, n=1000.

## Mechanism

A filtered fee-adjusted price estimate centers asymmetric fees. The filter updates faster on the first observed trade of a timestamp. Value imbalance `(X * fair - Y)/(X * fair + Y)` is measured relative to initialization; its bounded skew raises the fee on the imbalance-worsening side and lowers the opposite side. The depth term is bounded initial/current Y reserves. Only slots 0–5 are used, with no history loops, assembly or external calls. All fees clamp to 0–10%.

The imbalance equals `(fair/spot - 1)/(fair/spot + 1)`, so it overlaps algebraically with price misalignment. The ablation tests whether this specific nonlinear adjustment helps, not whether an independent inventory signal exists. Initial fair is initial spot, making initial value imbalance zero apart from integer rounding. The selected model opens at 30 bps; after a swap its symmetric component is 15 bps plus 5 bps times depth, before price and inventory adjustments.

## Ranked measured candidates (selection, not promotions)

| Rank | Candidate | SHA-256 | Mean edge | Paired gain vs starter | SE |
|---:|---|---|---:|---:|---:|
| 1 | inventory_low_spread | `f7e00f5098e73c1e4b82436290684a6149bbaeee2e8b1af0af1698c1170bcbd7` | 473.39895945 | 104.59453883 | 1.05271492 |
| 2 | inventory_half | `8cab12c0db22d635818397d5bc09b9306250ccabfb25f439ee783607df1efd2e` | 462.71722794 | 93.91280733 | 1.10729884 |
| 3 | no_depth | `eaa876d16305ff61f9e69a28cc53ec8642336cb2bbb31ad09f334a561e30afca` | 459.99624678 | 91.19182616 | 1.11425076 |
| 4 | inventory_v1 | `d71b3c63b3149df23db985841aad51873a7b1001a12b75713640133970d144d8` | 459.92038953 | 91.11596892 | 1.11894657 |
| 5 | inventory_balance | `12cc2ddadd0be5fc68c59b7a293d34c0a780c17901b354d2bc9d419d79d62679` | 448.74864672 | 79.94422610 | 0.71683054 |
| 6 | no_inventory | `9d264d7db724e612f440bf1d3ae09614bd68cf2a30319e1aa4cc9f1534c5c4e8` | 440.85938487 | 72.05496426 | 1.14154752 |
| 7 | inventory_fast | `67eaa8671d4e31f56153552edd4998e76cb9880833498a564e484211102a2303` | 403.25795796 | 34.45353735 | 1.17349674 |
| 8 | fixed30 | `9bf61770e9049d495ea17cc8051f3c21ec3d04140734aa509edc8987b23e89f9` | 342.94218249 | -25.86223812 | 0.19765281 |
| 9 | inventory_widen | `cbf30e46305f3d1e07a7c70ff156ed3d66062e96e7d62a21231a13fdb1f97219` | 218.08815364 | -150.71626698 | 1.43364505 |

## Ranked promotions

| Rank | Candidate | Holdout n | Gain over starter / previous best | SE |
|---:|---|---:|---:|---:|
| 1 | inventory_low_spread | 2000 | 104.48994039 | 1.10413921 |

The starter and previous best are the same file: SHA-256 `8f2cea337f6736105f58c6758da6c3ebf002951d34492bcd5b7101bef2d1e7f3`. No external network-best source was present. All holdout comparisons use seeds 100000–101999.

Inventory contribution: **15.15035358 ± 0.38002231 SE**, n=2000. This is diagnostic; the holdout did not change selection.
Depth contribution in the initial model (training seeds 0–1999): **-0.07585725 ± 0.11918972 SE**, n=2000. This term did not earn a gain there. Its contribution was not separately tested in the selected lower-spread model; the frozen source was retained without tuning on the holdout.

Gain versus initial inventory candidate: **12.98841229 ± 0.42977828 SE**, n=2000. This is diagnostic; the holdout did not change selection.

## Worst held-out differences vs starter

| Seed | Candidate minus starter |
|---:|---:|
| 101110 | -172.27562479 |
| 100241 | -150.21665743 |
| 100385 | -138.67544953 |
| 101140 | -133.02482632 |
| 100030 | -112.95871135 |

Every candidate’s five worst paired differences and complete statistics are in result.json.

## Reproduction and checks

Pinned upstream: `6b6921f8d463314aa7c96234e1be25a25245f704`. Build with Python 3.12, maturin, numpy, py-solc-x, pyrevm and local Rust. Compilation uses upstream SolidityCompiler (solc 0.8.24, optimizer 200, viaIR, Paris). The simulator source was not modified.

Commands executed successfully (the final two CLI invocations reused cached measurements from the same harness):

```sh
maturin develop --release --manifest-path test/scratch/amm/amm_sim_rs/Cargo.toml
amm-match validate candidates/inventory/Strategy.sol
python test/scratch/checks.py
python test/scratch/bench.py candidates/inventory/Strategy.sol --reference test/scratch/amm/contracts/src/StarterStrategy.sol --start 100000 --n 2000
python test/scratch/bench.py candidates/inventory/Strategy.sol --n 1000
```

The stress check makes 501 calls including repeated timestamps, both directions and reserves spanning X=30..300 at constant k. Calls succeeded with fees in [0,0.1] under the enforced 250,000 gas cap. The adapter reports a fixed gas estimate, so no actual maximum-gas claim is made. An additional two-direction ablation check passed for the initial candidate: inventory raises the imbalance-worsening side and lowers the opposite side.

Harness configuration: for each absolute seed, `rng=np.random.default_rng(seed)`, draw retail size U(19,21), arrival rate U(.6,1), and sigma U(.000882,.001008), in that order. Pass them to upstream build_config with the same seed and the default 10,000 steps. Use upstream SolidityCompiler and get_vanilla_bytecode_and_abi; call amm_sim_rs.run_batch(candidate, normalizer, configs, 8), in 100-simulation chunks. Subtract result.edges["submission"] per seed. SE is sample standard deviation of differences divided by sqrt(n). The harness matched upstream _build_configs exactly on all 12 configuration fields for seeds 0..19.

20-seed timing: candidate 0.07803 s/simulation, starter 0.05199; projected 2,000-pair wall time about 260 seconds, below the 25-minute allowance. Final candidate measured 0.100804 s/simulation with 8 workers. Times exclude compilation and depend on concurrent load.

Setup failures repaired locally: unavailable ensurepip was resolved with get-pip in the local venv; absent Rust was installed locally; unavailable /tmp was handled with TMPDIR inside scratch. Exploratory reads of nonexistent source filenames were corrected using file discovery; no source or build change was needed. No requester input was needed. Test scaffold and build output are under test/scratch and are not delivered.

## Variant definitions

All variants start from inventory_v1: first/same-timestamp filter alpha 0.26/0.05; inventory coefficient 0.1 capped at ±10 bps; base 25 bps + 5 bps times bounded depth. no_inventory sets skew to zero; no_depth fixes depth contribution at 5 bps; inventory_half uses inventory coefficient 0.5; inventory_widen adds half absolute spot/fair deviation to both fees; inventory_fast uses alpha 0.6/0; inventory_low_spread lowers constant base from 25 to 15 bps; inventory_balance uses coefficient 2 capped at ±100 bps. fixed30 is the starter with 30 rather than 50 bps. Full final source is embedded in both result JSONs.

## Sources and limits

- [Pinned simulator, fee equations, baseline and compiler.](https://github.com/benedictbrady/amm-challenge/tree/6b6921f8d463314aa7c96234e1be25a25245f704)
- [Public post-mortem: state estimation and ablation; reported scores not treated as comparable measurements.](https://github.com/dipankar/amm-challenge/blob/main/ANALYSIS.md)
- [Public description of implied-price filtering; no public strategy source copied.](https://github.com/jiayaoqijia/amm-challenge-yq/blob/main/README.md)

Public write-up scores did not match this pinned engine’s measured fixed-30 control and are not used as evidence of relative performance. This is one round-1 starting point, not a claim of leaderboard rank. Public strategy code was not copied. The Paradigm page could not be opened through the web tool; pinned simulator source was available.

## Next

1. Test inventory skew on an independently improved fair-price estimator, with paired ablation.
2. Separate X-value and Y depth terms to account for order-side liquidity; test on unused tuning seeds.
3. Test time-gap-dependent filtering and a no-arbitrage price interval, then confirm on a new holdout.
