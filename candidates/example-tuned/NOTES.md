# Example tuned dynamic fee baseline

Simulator: `benedictbrady/amm-challenge` commit `6b6921f8d463314aa7c96234e1be25a25245f704`. The contract uses only slots 0–2 and no loops, external calls, or assembly. It widens the fee on the side a return arbitrage would use after a large trade. The boost decays by elapsed step count when the next swap callback occurs.

## Tuned parameters

| Parameter | Bid | Ask |
| --- | ---: | ---: |
| Base fee | 30 bps | 30 bps |
| Trigger, trade Y / post-trade reserve Y | 50 bps (0.50%) | 50 bps (0.50%) |
| Widening per trigger | 135 bps | 135 bps |
| Decay per elapsed observed step | 7 bps | 7 bps |
| Cap | 300 bps | 300 bps |

Best file SHA-256: `0b262897556896df7d0792f531096a0b730a0363a0ddd7b857cc635a23180c07`. Score on seeds 0–999: **435.1622** edge (n=1,000).

## Fresh-seed scoreboard

| Rank | Contract | SHA-256 | Mean edge, seeds 100000–101999 | Paired difference vs winner |
| ---: | --- | --- | ---: | ---: |
| 1 | Tuned challenger | `0b262897556896df7d0792f531096a0b730a0363a0ddd7b857cc635a23180c07` | 435.2136 | 0 |
| 2 | Previous symmetric dynamic best | `d4226fadfb03dcd28f9b412427fe12dc525882d41398bde153cf37ea683e577c` | 434.3990 | -0.8145 |
| 3 | 50 bps starter | `8f2cea337f6736105f58c6758da6c3ebf002951d34492bcd5b7101bef2d1e7f3` | 369.5013 | -65.7123 |

Promotion: challenger over previous best **0.8145 ± 0.0755 SE** (n=2,000); over starter **65.7123 ± 0.3472 SE** (n=2,000). The previous-best gain clears two standard errors on fresh seeds. The five worst per-seed differences appear in `result.json`.

## Search scoreboard

Each row below used the same seed block as the selected final Strategy. The difference column is its paired mean difference from that final file on the stage’s seed block; these short blocks screened settings and did not decide promotion. All 2,000 final seeds were untouched during tuning.

### fixed bases — seeds 0–99, n=100 per setting

| Parameters [baseBid, baseAsk, triggerBid, triggerAsk, bumpBid, bumpAsk, decayBid, decayAsk]; cap multiple | Mean edge | Paired mean vs selected file |
| --- | ---: | ---: |
| `[80,80,10000,10000,0,0,0,0]`; cap 3 | 391.7259 | -54.8514 |
| `[70,70,10000,10000,0,0,0,0]`; cap 3 | 390.9116 | -55.6657 |
| `[60,60,10000,10000,0,0,0,0]`; cap 3 | 387.1292 | -59.4481 |
| `[100,100,10000,10000,0,0,0,0]`; cap 3 | 386.4501 | -60.1271 |
| `[50,50,10000,10000,0,0,0,0]`; cap 3 | 379.8067 | -66.7705 |
| `[40,40,10000,10000,0,0,0,0]`; cap 3 | 368.1348 | -78.4425 |
| `[30,30,10000,10000,0,0,0,0]`; cap 3 | 351.9660 | -94.6113 |
| `[20,20,10000,10000,0,0,0,0]`; cap 3 | 289.0056 | -157.5716 |
| `[10,10,10000,10000,0,0,0,0]`; cap 3 | 162.9990 | -283.5782 |

### coarse dynamic — seeds 0–99, n=100 per setting

| Parameters [baseBid, baseAsk, triggerBid, triggerAsk, bumpBid, bumpAsk, decayBid, decayAsk]; cap multiple | Mean edge | Paired mean vs selected file |
| --- | ---: | ---: |
| `[60,60,30,30,60,60,10,10]`; cap 3 | 426.6159 | -19.9614 |
| `[60,60,60,60,60,60,10,10]`; cap 3 | 423.4709 | -23.1063 |
| `[75,75,60,60,60,60,10,10]`; cap 3 | 420.4494 | -26.1279 |
| `[75,75,30,30,60,60,10,10]`; cap 3 | 419.6748 | -26.9025 |
| `[60,60,30,30,30,30,5,5]`; cap 3 | 413.2687 | -33.3085 |
| `[90,90,60,60,60,60,10,10]`; cap 3 | 413.1585 | -33.4187 |
| `[75,75,30,30,30,30,5,5]`; cap 3 | 410.8250 | -35.7523 |
| `[60,60,10,10,30,30,5,5]`; cap 3 | 410.6955 | -35.8818 |
| `[90,90,30,30,60,60,10,10]`; cap 3 | 410.3122 | -36.2651 |
| `[75,75,60,60,30,30,5,5]`; cap 3 | 408.4896 | -38.0876 |
| `[60,60,60,60,30,30,5,5]`; cap 3 | 408.1996 | -38.3777 |
| `[75,75,10,10,30,30,5,5]`; cap 3 | 405.8314 | -40.7459 |
| `[90,90,30,30,30,30,5,5]`; cap 3 | 404.2043 | -42.3730 |
| `[90,90,60,60,30,30,5,5]`; cap 3 | 403.6081 | -42.9692 |
| `[60,60,10,10,60,60,10,10]`; cap 3 | 403.3993 | -43.1779 |
| `[75,75,10,10,10,10,2,2]`; cap 3 | 399.9119 | -46.6654 |
| `[60,60,10,10,10,10,2,2]`; cap 3 | 399.6924 | -46.8849 |
| `[75,75,30,30,10,10,2,2]`; cap 3 | 399.2962 | -47.2810 |
| `[60,60,3,3,10,10,2,2]`; cap 3 | 398.3801 | -48.1972 |
| `[90,90,10,10,30,30,5,5]`; cap 3 | 397.7104 | -48.8669 |
| `[60,60,30,30,10,10,2,2]`; cap 3 | 397.4377 | -49.1396 |
| `[75,75,3,3,10,10,2,2]`; cap 3 | 397.1138 | -49.4635 |
| `[75,75,10,10,60,60,10,10]`; cap 3 | 396.7712 | -49.8061 |
| `[90,90,30,30,10,10,2,2]`; cap 3 | 395.7965 | -50.7807 |
| `[60,60,3,3,30,30,5,5]`; cap 3 | 395.7606 | -50.8166 |
| `[90,90,10,10,10,10,2,2]`; cap 3 | 395.3532 | -51.2241 |
| `[90,90,3,3,10,10,2,2]`; cap 3 | 392.1346 | -54.4426 |
| `[75,75,3,3,30,30,5,5]`; cap 3 | 390.2759 | -56.3013 |
| `[90,90,10,10,60,60,10,10]`; cap 3 | 387.7534 | -58.8238 |
| `[90,90,3,3,30,30,5,5]`; cap 3 | 383.0906 | -63.4867 |

### refined dynamic — seeds 0–99, n=100 per setting

| Parameters [baseBid, baseAsk, triggerBid, triggerAsk, bumpBid, bumpAsk, decayBid, decayAsk]; cap multiple | Mean edge | Paired mean vs selected file |
| --- | ---: | ---: |
| `[45,45,45,45,100,100,15,15]`; cap 3 | 439.8856 | -6.6917 |
| `[55,55,45,45,100,100,15,15]`; cap 3 | 437.4046 | -9.1727 |
| `[45,45,45,45,150,150,25,25]`; cap 3 | 436.2858 | -10.2915 |
| `[45,45,30,30,100,100,15,15]`; cap 3 | 434.3882 | -12.1890 |
| `[65,65,45,45,100,100,15,15]`; cap 3 | 433.4429 | -13.1343 |
| `[55,55,45,45,150,150,25,25]`; cap 3 | 433.3898 | -13.1874 |
| `[55,55,30,30,100,100,15,15]`; cap 3 | 431.1611 | -15.4162 |
| `[45,45,30,30,60,60,10,10]`; cap 3 | 429.5970 | -16.9803 |
| `[65,65,45,45,150,150,25,25]`; cap 3 | 428.8138 | -17.7634 |
| `[55,55,30,30,60,60,10,10]`; cap 3 | 428.1423 | -18.4349 |
| `[75,75,45,45,100,100,15,15]`; cap 3 | 427.8992 | -18.6781 |
| `[55,55,45,45,60,60,10,10]`; cap 3 | 426.9014 | -19.6758 |
| `[45,45,45,45,60,60,10,10]`; cap 3 | 426.2503 | -20.3269 |
| `[65,65,30,30,100,100,15,15]`; cap 3 | 425.9846 | -20.5927 |
| `[65,65,45,45,60,60,10,10]`; cap 3 | 425.3619 | -21.2154 |
| `[65,65,30,30,60,60,10,10]`; cap 3 | 424.7105 | -21.8668 |
| `[75,75,45,45,150,150,25,25]`; cap 3 | 422.8782 | -23.6991 |
| `[45,45,15,15,60,60,10,10]`; cap 3 | 421.8017 | -24.7755 |
| `[75,75,45,45,60,60,10,10]`; cap 3 | 421.5075 | -25.0698 |
| `[75,75,30,30,60,60,10,10]`; cap 3 | 419.6748 | -26.9025 |
| `[75,75,30,30,100,100,15,15]`; cap 3 | 419.4310 | -27.1463 |
| `[55,55,15,15,60,60,10,10]`; cap 3 | 419.2527 | -27.3246 |
| `[45,45,30,30,150,150,25,25]`; cap 3 | 417.5955 | -28.9817 |
| `[55,55,30,30,150,150,25,25]`; cap 3 | 415.3250 | -31.2522 |
| `[65,65,15,15,60,60,10,10]`; cap 3 | 415.1117 | -31.4656 |
| `[65,65,30,30,150,150,25,25]`; cap 3 | 410.8562 | -35.7211 |
| `[75,75,15,15,60,60,10,10]`; cap 3 | 409.3427 | -37.2346 |
| `[75,75,30,30,150,150,25,25]`; cap 3 | 404.2773 | -42.3000 |
| `[45,45,15,15,100,100,15,15]`; cap 3 | 403.8226 | -42.7547 |
| `[55,55,15,15,100,100,15,15]`; cap 3 | 401.4227 | -45.1546 |
| `[65,65,15,15,100,100,15,15]`; cap 3 | 396.6138 | -49.9634 |
| `[75,75,15,15,100,100,15,15]`; cap 3 | 391.3133 | -55.2639 |

### coordinate pass 1 — seeds 100–299, n=200 per setting

| Parameters [baseBid, baseAsk, triggerBid, triggerAsk, bumpBid, bumpAsk, decayBid, decayAsk]; cap multiple | Mean edge | Paired mean vs selected file |
| --- | ---: | ---: |
| `[40,40,40,40,120,120,10,10]`; cap 2 | 431.5139 | -4.6736 |
| `[40,40,40,40,120,120,10,10]`; cap 3 | 431.4342 | -4.7532 |
| `[40,40,40,40,120,120,10,10]`; cap 1 | 430.1621 | -6.0254 |
| `[40,40,40,40,120,120,15,15]`; cap 3 | 429.8381 | -6.3493 |
| `[40,40,40,40,100,100,15,15]`; cap 3 | 429.3990 | -6.7885 |
| `[40,40,45,45,100,100,15,15]`; cap 3 | 429.3636 | -6.8238 |
| `[30,30,45,45,100,100,15,15]`; cap 3 | 429.1655 | -7.0220 |
| `[45,45,45,45,100,100,15,15]`; cap 3 | 428.9846 | -7.2029 |
| `[40,40,50,50,100,100,15,15]`; cap 3 | 428.8570 | -7.3304 |
| `[40,40,40,40,120,120,5,5]`; cap 3 | 428.6876 | -7.4998 |
| `[40,40,40,40,120,120,20,20]`; cap 3 | 428.2520 | -7.9355 |
| `[50,50,45,45,100,100,15,15]`; cap 3 | 428.0596 | -8.1278 |
| `[40,40,60,60,100,100,15,15]`; cap 3 | 425.8036 | -10.3838 |
| `[40,40,40,40,120,120,30,30]`; cap 3 | 424.9885 | -11.1990 |
| `[60,60,45,45,100,100,15,15]`; cap 3 | 424.8468 | -11.3407 |
| `[40,40,30,30,100,100,15,15]`; cap 3 | 424.8247 | -11.3627 |
| `[40,40,40,40,150,150,15,15]`; cap 3 | 424.8234 | -11.3640 |
| `[40,40,40,40,80,80,15,15]`; cap 3 | 424.7315 | -11.4560 |
| `[40,40,40,40,120,120,50,50]`; cap 3 | 420.3840 | -15.8035 |
| `[40,40,80,80,100,100,15,15]`; cap 3 | 416.3115 | -19.8760 |
| `[40,40,40,40,60,60,15,15]`; cap 3 | 415.7348 | -20.4526 |
| `[40,40,40,40,200,200,15,15]`; cap 3 | 404.7202 | -31.4672 |
| `[20,20,45,45,100,100,15,15]`; cap 3 | 395.9139 | -40.2735 |

### coordinate pass 2 — seeds 300–799, n=500 per setting

| Parameters [baseBid, baseAsk, triggerBid, triggerAsk, bumpBid, bumpAsk, decayBid, decayAsk]; cap multiple | Mean edge | Paired mean vs selected file |
| --- | ---: | ---: |
| `[30,30,45,45,135,135,7,7]`; cap 3 | 434.5840 | -0.5838 |
| `[30,30,45,45,135,135,10,10]`; cap 3 | 434.1574 | -1.0104 |
| `[30,30,45,45,120,120,10,10]`; cap 3 | 433.2645 | -1.9033 |
| `[30,30,45,45,150,150,10,10]`; cap 3 | 432.9119 | -2.2559 |
| `[30,30,45,45,135,135,5,5]`; cap 3 | 432.7514 | -2.4165 |
| `[30,30,45,45,135,135,13,13]`; cap 3 | 432.5466 | -2.6212 |
| `[30,30,50,50,120,120,10,10]`; cap 3 | 432.5435 | -2.6244 |
| `[30,30,40,40,120,120,10,10]`; cap 3 | 432.4280 | -2.7399 |
| `[35,35,40,40,120,120,10,10]`; cap 3 | 431.3618 | -3.8060 |
| `[30,30,45,45,135,135,16,16]`; cap 3 | 430.9181 | -4.2497 |
| `[30,30,45,45,105,105,10,10]`; cap 3 | 430.6172 | -4.5506 |
| `[40,40,40,40,120,120,10,10]`; cap 3 | 429.9611 | -5.2067 |
| `[30,30,35,35,120,120,10,10]`; cap 3 | 429.7024 | -5.4655 |
| `[45,45,40,40,120,120,10,10]`; cap 3 | 428.5827 | -6.5851 |
| `[30,30,60,60,120,120,10,10]`; cap 3 | 428.4414 | -6.7264 |
| `[50,50,40,40,120,120,10,10]`; cap 3 | 426.4747 | -8.6931 |
| `[30,30,45,45,90,90,10,10]`; cap 3 | 425.9943 | -9.1735 |
| `[30,30,30,30,120,120,10,10]`; cap 3 | 423.7529 | -11.4150 |

### bid/ask sweeps — seeds 800–1199, n=400 per setting

| Parameters [baseBid, baseAsk, triggerBid, triggerAsk, bumpBid, bumpAsk, decayBid, decayAsk]; cap multiple | Mean edge | Paired mean vs selected file |
| --- | ---: | ---: |
| `[30,30,50,50,135,135,7,7]`; cap 3 | 429.5022 | +0.0000 |
| `[30,30,50,45,135,135,7,8]`; cap 3 | 429.3330 | -0.1692 |
| `[30,30,50,45,135,135,6,7]`; cap 3 | 429.3329 | -0.1693 |
| `[30,30,50,45,135,135,7,7]`; cap 3 | 429.3319 | -0.1703 |
| `[30,30,50,45,135,135,8,7]`; cap 3 | 429.3196 | -0.1826 |
| `[30,30,50,45,135,120,7,7]`; cap 3 | 429.2990 | -0.2031 |
| `[30,30,50,45,150,135,7,7]`; cap 3 | 429.2633 | -0.2389 |
| `[30,30,50,45,135,135,7,6]`; cap 3 | 429.0735 | -0.4286 |
| `[30,30,45,45,135,135,7,7]`; cap 3 | 428.9084 | -0.5937 |
| `[30,30,50,45,120,135,7,7]`; cap 3 | 428.7257 | -0.7765 |
| `[30,30,50,45,135,150,7,7]`; cap 3 | 428.4632 | -1.0390 |
| `[30,35,45,45,135,135,7,7]`; cap 3 | 428.2540 | -1.2482 |
| `[35,30,45,45,135,135,7,7]`; cap 3 | 428.2506 | -1.2516 |
| `[30,30,50,40,135,135,7,7]`; cap 3 | 427.9349 | -1.5673 |
| `[30,25,45,45,135,135,7,7]`; cap 3 | 427.8635 | -1.6387 |
| `[25,30,45,45,135,135,7,7]`; cap 3 | 427.8547 | -1.6475 |
| `[30,30,40,45,135,135,7,7]`; cap 3 | 427.4223 | -2.0798 |

### confirmation — seeds 1200–1999, n=800 per setting

| Parameters [baseBid, baseAsk, triggerBid, triggerAsk, bumpBid, bumpAsk, decayBid, decayAsk]; cap multiple | Mean edge | Paired mean vs selected file |
| --- | ---: | ---: |
| both50 `[30,30,50,50,135,135,7,7]`; cap 2 | 434.6063 | +0.0000 |
| bid50 `[30,30,50,45,135,135,7,7]`; cap 2 | 434.1355 | -0.4708 |
| bid48 `[30,30,48,45,135,135,7,7]`; cap 2 | 434.1156 | -0.4907 |
| cap3 `[30,30,50,45,135,135,7,7]`; cap 3 | 434.0819 | -0.5244 |
| bid52 `[30,30,52,45,135,135,7,7]`; cap 2 | 433.9584 | -0.6479 |
| decay8 `[30,30,50,45,135,135,8,8]`; cap 2 | 433.9170 | -0.6893 |
| base32 `[32,32,50,45,135,135,7,7]`; cap 2 | 433.8431 | -0.7632 |
| bump145 `[30,30,50,45,145,145,7,7]`; cap 2 | 433.7913 | -0.8150 |
| symmetric `[30,30,45,45,135,135,7,7]`; cap 2 | 433.7657 | -0.8406 |
| bump125 `[30,30,50,45,125,125,7,7]`; cap 2 | 433.5585 | -1.0478 |
| base28 `[28,28,50,45,135,135,7,7]`; cap 2 | 433.2330 | -1.3733 |
| cap1 `[30,30,50,45,135,135,7,7]`; cap 1 | 432.0017 | -2.6046 |

## Checks and interpretation

`amm-match validate` compiled and deployed the contract successfully. `amm-match run --simulations 20` returned 463.66 edge; the short score is noisy. The official 1,000-simulation CLI run returned 435.16 edge, matching the custom seeded runner. The Rust runner was called with the README configuration and NumPy-seeded parameters; fresh paired comparisons ran seeds 100000–101999. Wall-clock candidate time was 0.05096 seconds per simulation.

The public [Algebra Finance write-up](https://www.linkedin.com/pulse/amm-fee-challenge-notes-from-our-run-optimization-arena-qe3ff) describes asymmetric fees in the direction of the external price after retail moves. This contract tests that narrow idea without an external-price estimator. The [challenge README at the pinned commit](https://github.com/benedictbrady/amm-challenge/blob/6b6921f8d463314aa7c96234e1be25a25245f704/README.md) supplies the starter and spike-and-decay example. A public [research post-mortem](https://github.com/dipankar/amm-challenge/blob/main/ANALYSIS.md) reports that size-triggered spike-and-decay policies plateau below fair-price estimation, making a fair-price estimator the next mechanism to test.

The simulator calls the strategy only after trades. Elapsed-step decay therefore updates the posted fee at the next swap callback; it cannot lower a fee before that triggering trade.
