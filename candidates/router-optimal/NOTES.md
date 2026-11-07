Router-optimal, round 1. Selected `combo60_shadow100_r025`.

Best file: `Strategy.sol`. SHA-256: `8b6afc7a21c7941e48163b07bd5a1ad5c3364c77c2269ec131d95aa9744dddd1`.
Score on seeds 0–999: **519.287087** (n=1000). Fresh score on seeds 100000–101999: **518.963572** (n=2000).
Fresh paired gain over the starter: **+149.462270 ± 0.918792 SE**. Twice the SE is 1.837584; promotion criterion passed.

The previous approved best for this first-round item was the prescribed 50 bps StarterStrategy. The gain over the previous best is therefore the same paired comparison. No hidden leaderboard rank is claimed. Training leaders were not promoted.

The exact router uses gamma_i=1−f_i, r=sqrt(x1*gamma1*y1/(x0*gamma0*y0)), q=clip((r*(y0+gamma0*Q)−y1)/(gamma1+r*gamma0),0,Q). For a buy of X, pool edge is q−F*x1*gamma1*q/(y1+gamma1*q). The sell side follows by exchanging the input/output assets. [Pinned router source](https://github.com/benedictbrady/amm-challenge/blob/6b6921f8d463314aa7c96234e1be25a25245f704/amm_sim_rs/src/market/router.rs)

For small fees and equal fair-value depth L, let m be the effective quote margin from estimated fair and c0 the competitor margin (30 bps when its spot is fair). Then q≈Q/2+L*(c0−m)/4 and retail edge≈q*m+q²/L. Differentiating gives m0=(c0+2*Q/L)/3. With Q=20 and L=10000, this is 23.3333 bps. For unequal depths D=L*L0/(2*(L+L0)), rho=2D/L and m0=(1−rho)*(c0+2*Q/L0)/(2−rho). The implementation uses the equal-depth approximation, since both pools preserve the same initial k and remain near the same fair price.

The arb-loss proxy is h*L*E[(Z−m)+²]/4 with Z uniform on [−a,a]. For 0≤m<a it equals h*L*(a−m)^3/(24*a). With total retail rate lambda=0.8 and equal side probabilities, the per-side objective is (lambda/2)*retail edge−arb loss. One Newton step adds 2*h*(a−m0)^2/(3*lambda*a+4*h*(a−m0)). This support represents estimation error as well as the next GBM move; it is not a claim that the simulator uses uniform returns. The mean-order formula ignores clipping in its derivative. The table variants instead integrate the exact clipped split over 32768 deterministic lognormal quantiles (mean 20, log-sigma 1.2) at Q/L knots 10,15,20,25,30,40 bps. [Arbitrage endpoint source](https://github.com/benedictbrady/amm-challenge/blob/6b6921f8d463314aa7c96234e1be25a25245f704/amm_sim_rs/src/market/arbitrageur.rs)

The normalizer fair-value reserve is sqrt(k*F), approximated by (reserveY+reserveX*F)/2 with second-order spot error. Target bid/ask prices are converted exactly into input fees. Fair-price observations use spot_post*(1−oldBid) for AMM buys of X and spot_post/(1−oldAsk) for AMM sales. These identify fair price only for arbitrage; retail endpoints are noisy. The bounded filter and partial spot offset keep that noise from trapping the pool away from the market.

Selected parameters: `{"arb_support_bps": 60, "arb_weight": 0.25, "fair_weight": 0.75, "first_retail_blend": 1, "first_update": 0.26, "innovation_clip_bps": 60, "normalizer_endpoint_unclipped": true, "normalizer_price": "infer marginal equality on retail; clamp to estimated arb band on new steps", "objective": "mean-order quadratic + one Newton step", "same_step_update": 0.05}`.

The unbounded variants exposed a real failure: a hard 300 bps rejection gate can stop updating fair price after a dislocation while full skew leaves one fee near zero and the other very high. Clipped updates plus partial fair-price offset fixed this. The extra shadow variants inferred the competitor spot from equal post-trade marginal prices on retail and modeled an unchanged competitor when all flow went to our pool.
For a pool purchase of X the inferred normalizer spot is spot_post*(1−oldBid)/0.997; for a pool sale it is spot_post*0.997/(1−oldAsk). On an arbitrage fill the same expressions give the corresponding normalizer arbitrage-band boundary. The final endpoint experiment therefore applies the monotone update to every callback. Unknown normalizer-only fills remain a source of estimation error. [Router](https://github.com/benedictbrady/amm-challenge/blob/6b6921f8d463314aa7c96234e1be25a25245f704/amm_sim_rs/src/market/router.rs), [arbitrageur](https://github.com/benedictbrady/amm-challenge/blob/6b6921f8d463314aa7c96234e1be25a25245f704/amm_sim_rs/src/market/arbitrageur.rs).

The README and assignment prose reverse the retail edge signs. The pinned engine actually credits amountY−amountX*fair for AMM sales of X and amountX*fair−amountY for AMM purchases, and subtracts arbitrageur profit. All reported measurements use the unmodified engine’s `edges["submission"]`. [Pinned scoring source](https://github.com/benedictbrady/amm-challenge/blob/6b6921f8d463314aa7c96234e1be25a25245f704/amm_sim_rs/src/simulation/engine.rs)

Ranked promotions:

| Rank | Candidate | Fresh n | Gain over previous best | SE |
|---:|---|---:|---:|---:|
| 1 | combo60_shadow100_r025 | 2000 | +149.462270 | 0.918792 |

Training scoreboard (all seeds 0–1999; each candidate against the same frozen starter; full SHA-256 values and five worst paired runs are in result.json). The selected candidate is also a common paired comparator for all rows:

| Rank | Candidate | Mean edge | Δ starter | SE | Δ selected | SE | SHA-256 prefix |
|---:|---|---:|---:|---:|---:|---:|---|
| 1 | combo60_shadow100_r025 | 518.010973 | +149.206553 | 0.838397 | +0.000000 | 0.000000 | 8b6afc7a21c7 |
| 2 | gate60_r025 | 517.185752 | +148.381332 | 0.825390 | -0.825221 | 0.025701 | ba75ab4e5fe7 |
| 3 | combo60_shadow0_r025 | 515.513243 | +146.708822 | 0.842471 | -2.497730 | 0.034510 | 9689cafcb9f6 |
| 4 | gate120_r1 | 514.580539 | +145.776118 | 0.829554 | -3.430434 | 0.031177 | 2c3b30fbbfe3 |
| 5 | gate60_r1 | 514.174201 | +145.369781 | 0.838746 | -3.836772 | 0.037910 | 8fd6ef86330f |
| 6 | combo60_shadow0_r1 | 513.190775 | +144.386354 | 0.856462 | -4.820198 | 0.051390 | b3f65853ad5f |
| 7 | shadow25_r025 | 511.093796 | +142.289375 | 0.810943 | -6.917177 | 0.049746 | 43b8efa62687 |
| 8 | shadow0_r1 | 510.996611 | +142.192191 | 0.827110 | -7.014362 | 0.036757 | f8a571b803c7 |
| 9 | shadow0_r025 | 510.986465 | +142.182044 | 0.811842 | -7.024508 | 0.049786 | 485b89362255 |
| 10 | shrink_r025 | 510.875635 | +142.071214 | 0.797962 | -7.135338 | 0.056548 | e69043f5baad |
| 11 | shadow25_r1 | 510.615724 | +141.811303 | 0.826085 | -7.395249 | 0.036547 | 9a6d1e9945ae |
| 12 | table_r0 | 509.984523 | +141.180103 | 0.792434 | -8.026450 | 0.063062 | 95f80e239831 |
| 13 | shrink_r1 | 509.509263 | +140.704842 | 0.811244 | -8.501710 | 0.046075 | 4575892e55b8 |
| 14 | gate30_r025 | 509.304089 | +140.499668 | 0.837956 | -8.706884 | 0.097320 | 92e7d0d0947f |
| 15 | shrink_r0 | 507.834211 | +139.029790 | 0.786515 | -10.176762 | 0.070941 | 27ded69e1a51 |
| 16 | shrink_r4 | 505.705268 | +136.900847 | 0.822248 | -12.305705 | 0.050640 | 6516e720b8f4 |
| 17 | gate30_r1 | 503.022805 | +134.218385 | 0.861979 | -14.988168 | 0.156695 | a47edb8e8e4e |
| 18 | table_r2 | 502.160724 | +133.356303 | 0.830575 | -15.850249 | 0.061424 | e12bebeb7c66 |
| 19 | half_r1 | 478.568259 | +109.763838 | 0.648489 | -39.442714 | 0.210799 | 63e5445b9af8 |
| 20 | combo60_risk_size05 | 471.973853 | +103.169433 | 1.030706 | -46.037120 | 0.569370 | 9a517ee5a26d |
| 21 | softfull_r1 | 468.531523 | +99.727102 | 0.765259 | -49.479450 | 0.511459 | 63fbcc0c4df0 |
| 22 | risk_size1 | 411.883375 | +43.078954 | 1.110403 | -106.127599 | 1.133329 | 29312d16446b |
| 23 | mean_r0 | 262.955226 | -105.849195 | 1.894009 | -255.055747 | 1.979486 | b49012befddd |
| 24 | mean_r025 | 252.134801 | -116.669620 | 1.808364 | -265.876173 | 1.894138 | 05904eb57d52 |
| 25 | mean_r1 | 237.274727 | -131.529694 | 1.683942 | -280.736246 | 1.748876 | f46d1d5780f0 |
| 26 | mean_r4 | 227.176125 | -141.628296 | 1.590199 | -290.834848 | 1.641474 | 1cf15b650c2f |

Five worst fresh paired runs:

| Seed | Candidate − starter |
|---:|---:|
| 101573 | +72.312479 |
| 100645 | +73.251492 |
| 100236 | +77.903602 |
| 100631 | +78.451577 |
| 100818 | +78.995839 |

Unmeasured prototypes deferred before any simulation: risk_size025, risk_size05, risk_size05_low, ninety_r1, table_r1, table_r025, gate60_fast, combo60_risk_size1. These were neither compared nor eligible for selection. Every measured candidate in the scoreboard completed all 2000 training seeds.

Measurement protocol: copy MatchRunner._build_configs with the seed offset applied to BOTH numpy.default_rng(seed) and the Rust config seed. Draw mean size, arrival rate, then sigma in that exact order. Run each candidate and the 50 bps reference separately against VanillaStrategy’s fixed 30 bps bytecode. Pair by seed; SE is sample standard deviation of differences (ddof=1) divided by sqrt(n). The official engine source was not patched. Chunks of at most 20 bound retained step-history memory; later training used chunks of eight and shared worker allocation. A 40-seed check gave bit-identical edges at batch sizes eight and twenty. The final fresh run used batches of eight and eight fixed workers. [Canonical config construction](https://github.com/benedictbrady/amm-challenge/blob/6b6921f8d463314aa7c96234e1be25a25245f704/amm_competition/competition/match.py)

The initial 20-simulation timing was 0.215928 seconds/simulation. The frozen candidate took 0.175895 seconds/simulation across eight workers, and the reference took 0.112106. The fresh two-strategy run used 9.600 summed batch minutes. The full n=2000 fit; no sample reduction was needed. Config construction, Rust simulation, result extraction and collection are timed. Compilation and report writing are excluded.

Checks run:

* `amm-match validate candidates/router-optimal/Strategy.sol`: passed static policy, compilation and deployment/initialization.
* Direct pyrevm checks: 3078 valid and boundary callbacks at a stricter 100000 gas cap; three reserve scales, repeated timestamps, long gaps and 25% reserve trades. Initialization succeeded within 250000 gas. These are tested limits, not the adapter’s approximate gas estimates.
* Runtime size: 2265 bytes. No external calls, assembly or loops over history; all persistent state is in inherited slots.
* Canonical configuration parity: all fields on seeds 0–19 matched MatchRunner._build_configs exactly.
* Independent router math: 10000 KKT cases, 1000 analytic derivative cases, 24 table knots checked against a grid; all passed.
* Source/result SHA-256 equality, duplicated JSON equality, required fields, fresh seed ranges and the 64000-byte artifact cap were checked.

Build/runtime: CPython 3.12.12, solc 0.8.24 with optimizer 200/viaIR/Paris, pyrevm 0.3.7, numpy 2.5.4, Rust 1.99.1, revm 18.0.0. All dependencies, caches, harnesses and experimental sources were kept in disposable test/scratch/router-optimal. No configuration or shared repository source was changed.

Recovered setup failures: system venv lacked ensurepip; a local uv-managed environment resolved it. The first maturin call lacked pip; installing pip resolved it. A pre-build CLI call failed at amm_competition/competition/match.py:7 because amm_sim_rs was not installed yet; all subsequent final validations passed.

Public write-ups were read as technical background. [Algebra](https://medium.com/@crypto_algebra/amm-fee-challenge-notes-from-our-run-on-optimization-arena-4e980dbbd699) emphasizes asymmetric fees and the uncertainty of remaining retail flow; [Dipankar’s retrospective](https://github.com/dipankar/amm-challenge/blob/main/ANALYSIS.md) emphasizes state estimation. The [public YQ implementation](https://github.com/jiayaoqijia/amm-challenge-yq/blob/main/contracts/src/Strategy.sol) suggested the initial endpoint-filter weights. No complete public strategy was copied; the router objective, table integration, shadow estimate experiments and local comparisons are this item’s work.


Minimal independent reproduction after installing the pinned framework and its release Rust bindings. Run from the checkout root. This retains only 20 simulations of engine history at a time:

```python
from pathlib import Path
import json
import numpy as np
import amm_sim_rs
from amm_competition.competition.config import build_config
from amm_competition.evm.compiler import SolidityCompiler
from amm_competition.evm.baseline import get_vanilla_bytecode_and_abi

compiler = SolidityCompiler()
def compile_source(text):
    result = compiler.compile(text)
    assert result.success, result.errors
    return list(result.bytecode)
candidate = compile_source(Path("candidates/router-optimal/Strategy.sol").read_text())
starter = compile_source((compiler.CONTRACTS_SRC_DIR / "StarterStrategy.sol").read_text())
normalizer = list(get_vanilla_bytecode_and_abi()[0])
def config(seed):
    rng = np.random.default_rng(seed)
    size = rng.uniform(19, 21)
    rate = rng.uniform(.6, 1)
    sigma = rng.uniform(.000882, .001008)
    return build_config(seed=seed, gbm_sigma=sigma,
                        retail_arrival_rate=rate, retail_mean_size=size)
def edges(bytecode, start, n):
    out = {}
    for first in range(start, start+n, 20):
        cfgs = [config(s) for s in range(first, min(first+20, start+n))]
        batch = amm_sim_rs.run_batch(bytecode, normalizer, cfgs, 8)
        out.update((r.seed, r.edges["submission"]) for r in batch.results)
        del batch
    return out
score = edges(candidate, 0, 1000)
a = edges(candidate, 100000, 2000)
b = edges(starter, 100000, 2000)
seeds = list(range(100000, 102000))
diff = np.array([a[s]-b[s] for s in seeds])
print(json.dumps({"score": float(np.mean(list(score.values()))),
    "n": len(diff), "mean_diff": float(diff.mean()),
    "se": float(diff.std(ddof=1)/np.sqrt(len(diff))),
    "worst": [{"seed": seeds[int(i)], "diff": float(diff[i])}
              for i in np.argsort(diff)[:5]]}, indent=2))
```

Next steps:

1. Include the post-retail price displacement and subsequent fee update in the expected arbitrage loss, then solve a small joint transition table.
2. Condition the risk horizon on within-step retail count using the Poisson residual-arrival distribution; validate on newly reserved seeds.
3. Track uncertainty in the normalizer estimate when orders route only to the normalizer, and compare an uncertainty-weighted router quote against this frozen baseline.
