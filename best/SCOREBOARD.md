# Scoreboard

Current best: `best/Strategy.sol` = the challenge's 50 bps starter
(`tools/amm-challenge/contracts/src/StarterStrategy.sol`, unchanged).

| field | value |
|---|---|
| sha256 | `8f2cea337f6736105f58c6758da6c3ebf002951d34492bcd5b7101bef2d1e7f3` |
| `amm-match validate` | passes |
| score, seeds 0..999 (n=1000) | **369.45** mean edge (`amm-match run --simulations 1000` and `pair.py --seed-start 0 --n 1000` agree: 369.4498) |
| fresh seeds 100000..101999 (n=2000) | mean edge 369.50 |

## Paired results

diff = edge(A) − edge(B) per seed; se = std(diff)/√n. Reference B is named per row.

| date | A (sha256 prefix) | B | seeds | n | mean_diff | se | 5 worst (seed: diff) | status |
|---|---|---|---|---|---|---|---|---|
| 2026-11-07 | starter 50 bps `8f2cea33` | vanilla 30 bps `62d40cce` | 100000..101999 | 2000 | **+25.879** | 0.208 | 100115: 3.38, 101126: 3.46, 101882: 4.01, 100571: 4.74, 100907: 4.87 | baseline (trunk) |
| 2026-11-07 | starter 50 bps `8f2cea33` | vanilla 30 bps `62d40cce` | 0..999 | 1000 | +25.849 | 0.278 | 669: 4.39, 448: 5.55, 520: 6.45, 907: 6.64, 184: 7.19 | baseline (tuning seeds) |

Vanilla 30 bps alone: 343.60 (seeds 0..999), 343.62 (100000..101999).

## Promotions

| rank | sha256 | paired gain vs previous best (mean ± se, n, seeds) | gain vs starter | promoted by |
|---|---|---|---|---|
| 0 | `8f2cea33…e7f3` | — (starter) | 0 | layout (r1) |

## Rules

- Promote only when a paired gain over the current best clears 2·se on fresh
  seeds (>= 100000) that no tuning used, n >= 2000.
- Record every candidate's paired difference here, promoted or not.
- Command: `python tools/pair.py cand.sol best/Strategy.sol --seed-start <fresh> --n 2000`.
