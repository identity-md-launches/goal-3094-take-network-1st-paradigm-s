# Interval tracker notes

## Strategy

The contract stores an independent fair-price interval midpoint and width in slots 11–12 and the prior observed spot in slot 13. A timestamp gap widens the interval by the volatility estimate times the square root of elapsed steps. If the first observed trade moves spot in the arbitrage direction, its fee-adjusted implied price collapses the interval to a point. Otherwise, the expanded interval is intersected with the no-arbitrage band implied by the prior spot and quoted fees. The interval bounds constrain the adaptive implied-price estimate used by the asymmetric toxicity and flow fee model.

This implementation builds on the publicly reported adaptive implied-price estimator because the basic interval-only fee drafts were substantially weaker. The reference code reports a 523.21 score and explains the gated fair-price estimate, toxicity response, and asymmetric fee schedule. The interval state is the addition tested here.

## Scoreboard

All tuning entries below use the same seeds 0–1999 against the fixed 30 bps normalizer. The table reports each strategy's mean edge and its paired difference from that normalizer, including SE.

| Candidate | Mean edge | Mean difference vs normalizer | SE |
|---|---:|---:|---:|
| Low-base interval draft (18 bps) | 320.370 | -65.901 | 0.207 |
| Interval draft (30 bps base) | 347.613 | -141.555 | 0.420 |
| Interval draft (40 bps base) | 352.426 | -185.869 | 0.568 |
| 10 bps base, no width premium | 201.887 | -92.248 | 0.381 |
| Public adaptive estimator control | 523.711 | 159.957 | 0.892 |
| Interval width centered on filtered price | 521.825 | 160.714 | 0.870 |
| 25% bounded-price blend | 523.621 | 161.229 | 0.892 |
| Selected interval midpoint and width | 523.677 | 160.778 | 0.891 |
| 50% interval-midpoint blend + width fee | 488.737 | 122.327 | 0.775 |
| 10% interval-midpoint blend + width fee | 519.908 | 162.962 | 0.882 |

The first interval-only attempt scored 406.579, a paired -22.897 (SE 0.338) against StarterStrategy on seeds 0–1999.

Best submitted file SHA-256: `d03323243163a8a0e4f83ef444438b65cf1867b068520986bf90daae3d749801`. The selected interval variant differs from the public estimator's tuning mean by -0.034 edge on seeds 0–1999. On fresh seeds 100000–101999 it beat the public reference head-to-head by 6.403 (SE 0.115), so the fresh paired comparison supports promotion. Against StarterStrategy on the same fresh seeds the paired gain was 246.691 (SE 0.910).

## Checks

- `amm-match validate candidates/interval-tracker/Strategy.sol`: passed.
- 1000-seed candidate score on 0–999: 524.129 mean edge; 0.1388 seconds/simulation.
- Fresh paired comparison against `StarterStrategy.sol`: n=2000, seeds 100000–101999, mean difference 246.691, SE 0.910; lowest differences: 100068 (163.088), 100631 (164.519), 100818 (168.333), 101120 (170.948), 100645 (171.389).
- Fresh paired head-to-head against the public YQ reference: n=2000, seeds 100000–101999, mean difference 6.403, SE 0.115; lowest differences: 100432 (-106.153), 101389 (-10.053), 101635 (-8.233), 101159 (-7.821), 101004 (-5.632).

## References

- [Challenge source at the requested commit](https://github.com/benedictbrady/amm-challenge/tree/6b6921f8d463314aa7c96234e1be25a25245f704)
- [YQ public strategy](https://github.com/jiayaoqijia/amm-challenge-yq)
- [Public analysis of fair-price estimation](https://github.com/dipankar/amm-challenge/blob/main/ANALYSIS.md)
- [Algebra write-up](https://www.linkedin.com/pulse/amm-fee-challenge-notes-from-our-run-optimization-arena-qe3ff)
