# Paradigm AMM fee challenge — network trunk

Goal: a `contract Strategy is AMMStrategyBase` that maximises average edge in
https://github.com/benedictbrady/amm-challenge (commit `6b6921f8`), the
simulator behind https://www.paradigm.xyz/puzzles/amm.

## Layout

| path | what |
|---|---|
| `best/Strategy.sol` | current best strategy, ready to submit (starts as the 50 bps starter) |
| `best/SCOREBOARD.md` | best file's sha256 and score, every paired result, promotion table |
| `tools/amm-challenge/` | the simulator at commit `6b6921f8d463314aa7c96234e1be25a25245f704`, plain files |
| `tools/pair.py` | paired measurement CLI: `pair.py A.sol B.sol --seed-start S --n N [--workers W] [--csv F]` |
| `tools/README.md` | install and usage |
| `artifacts/goal/…` | per-item results (uploaded separately, not committed) |
| `test/scratch/` | worker scratch, never committed |
| `.deps/` | local toolchains (Rust, venv, solc, build output), git-ignored |

## Seed rules

Seed `s` = simulation index `s` of `amm-match run` (numpy `default_rng(s)`
draws the per-sim parameters, the Rust engine is seeded with `s`).

- **0 .. 999** — the public score seeds (`amm-match run --simulations 1000`).
  Report every candidate's mean edge here.
- **0 .. 99,999** — tuning seeds. Tune, sweep and search only here.
- **100,000 and up** — fresh evaluation seeds. Use them only for paired
  comparisons against `best/Strategy.sol`; do not tune on a block once it has
  decided something. The first block, 100,000..101,999, is the standard
  round-1 comparison against the starter; promotions should use a block not
  used before (record which block in the scoreboard).
- Every comparison is paired (same seeds for A and B), n >= 2,000, reporting
  n, mean_diff, se and the 5 worst seeds.
- Promote only if mean_diff > 2·se on fresh seeds.

## Strategy constraints

Only imports `./AMMStrategyBase.sol` and `./IAMMStrategy.sol`; state only in
`slots[0..31]`; fees in WAD (`30 * BPS` = 30 bps, max 10%); 250,000 gas per
call; no assembly, external calls or loops over history; must pass
`amm-match validate`.
