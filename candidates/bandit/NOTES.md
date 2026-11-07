# Edge Bandit

## Strategy

The contract maintains five symmetric fee arms at 70, 75, 80, 85, and 90 bps. It starts at 80 bps, samples every arm once, then selects the arm with the best recent mean realized trade edge. One in sixteen decisions explores a deterministic arm chosen from a hash of the observed trade and call count. The per-arm mean has a 1/32 update weight, so it can respond to changing flow.

For each trade, it estimates fair price from the post-trade spot and the fee that was active during that trade: `spot * (1 - fee)` when the AMM bought X and `spot / (1 - fee)` when it sold X. It filters plausible implied prices with a 3% gate, using more weight on the first trade at a timestamp. The bandit reward is signed trade edge in Y units using this fair-price estimate, capped at ±100 Y.

The contract uses slots 0–14, has no external calls or assembly, and loops only over the fixed five arms.

## Tuning scoreboard

The formal tuning comparisons use paired seeds 0–1999 against `StarterStrategy.sol` (fixed 50 bps). Candidate-to-candidate differences use the same seed set and are computed per seed.

| Candidate | Arms / reward | Mean edge | Paired difference vs starter ± SE | Difference from selected ± SE |
|---|---|---:|---:|---:|
| **Selected candidate** | **70, 75, 80, 85, 90 bps; raw signed edge** | **378.8613** | **+10.0569 ± 0.1709** | — |
| Wide bandit | 60, 70, 80, 90, 100 bps; raw signed edge | 376.7927 | +7.9883 ± 0.1656 | +2.0686 ± 0.0657 |
| Lower bandit | 50, 60, 70, 80, 90 bps; raw signed edge | 375.0344 | +6.2299 ± 0.1186 | +3.8270 ± 0.0894 |
| Initial bandit | 10, 20, 30, 40, 50 bps; edge / notional | 186.3455 | −182.4589 ± 0.6958 | +192.5159 ± 0.8139 |

An early 100-seed narrow screen had accidentally repeated the 75 bps arm; it was corrected before the formal comparisons and was not retained. A 20-seed fixed-fee sweep suggested edge increased from 394.83 at 50 bps to 408.74 at 80 bps, then eased to 403.90 at 100 bps. This motivated moving the arm range upward.

## Final measurements

- Source SHA-256: `29dd2e064d7f618be7bf6c54b18e293568a98fe44561ad1d7515807c6e42b5a7`.
- Score on seeds 0–999: 379.4554 mean edge.
- Paired comparison against the 50 bps starter on fresh seeds 100000–101999: candidate mean edge 379.4141; starter mean edge 369.5013; paired gain +9.9128 with SE 0.1823.
- Runtime on the 1,000-seed score run: 0.1905 seconds per simulation.
- Final paired runtime: 0.10995 seconds per individual candidate or reference simulation (439.78 seconds for 4,000 simulations).

Five worst fresh per-seed differences (candidate minus starter): seed 101882, −11.2054; 101071, −10.9890; 101221, −10.1848; 100004, −9.7950; 101489, −9.1917.

## Fee-level convergence

In the 1,000-seed score run, the modal fee in the final 1,000 step-end quotes matched the final fee in 62.0% of seeds. The modal fee occupied 77.3% of those quotes on average. A stricter definition of convergence (one fee at ≥80% of step ends) held in 52.8% of seeds; those seeds averaged 377.50 edge, versus 381.65 for the others. Thus the bandit often settles on a dominant level, but that convergence did not predict higher edge. Modal counts and mean edge by modal fee were: 70 bps, 223 seeds / 385.08 edge; 75 bps, 248 / 376.54; 80 bps, 194 / 382.34; 85 bps, 174 / 372.54; and 90 bps, 161 / 380.15.

## Checks

- `amm-match validate candidates/bandit/Strategy.sol` — passed validation, compilation, and EVM initialization.
- Paired simulation harness copied `MatchRunner._build_configs` at upstream commit `6b6921f8d463314aa7c96234e1be25a25245f704`; seeds 0–1999 were used for candidate comparisons, seeds 0–999 for the reported score, and 100000–101999 for the final comparison.

## References

- [Pinned AMM challenge repository](https://github.com/benedictbrady/amm-challenge/tree/6b6921f8d463314aa7c96234e1be25a25245f704) for the simulator, strategy ABI, and fee mechanics.
- [Public AMM strategy analysis](https://github.com/dipankar/amm-challenge/blob/main/ANALYSIS.md) discusses fair-price inference from the reserve/fee implied price and low-memory state tracking; the selected implementation uses the implied-price signal for realized-edge rewards.
- [Algebra Finance challenge write-up](https://www.linkedin.com/pulse/amm-fee-challenge-notes-from-our-run-optimization-arena-qe3ff) describes asymmetric fees and adapting to arbitrage versus retail flow, which remain possible follow-ups beyond this symmetric fee-bandit item.
