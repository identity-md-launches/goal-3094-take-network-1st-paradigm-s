# Volatility estimate — round 1

## Approach

`afterSwap` treats the first callback at a new timestamp as the possible
arbitrage callback.  Given the quote that was active before the callback, the
post-trade spot implies the fair price at the edge of the fee band.  Consecutive
inferred fair prices provide a squared relative move.  A 1/16-update EWMA is
stored in slot 5 and mapped linearly from the challenge's known volatility
interval (0.000882 to 0.001008) to 34–50 bps.  A 1% jump filter limits damage
when a timestamp has a retail trade but no arbitrage callback.

The current reserve ratio supplies a capped 2 bps bid/ask skew.  When the AMM
holds relatively more X, the bid (buy-X side) is widened and the ask narrowed;
the opposite happens when it holds relatively more Y.  All state is in the
base contract's slots and the callback has no loops, external calls, or
assembly.

## Tried and next

Tried: fixed 42 bps; symmetric volatility map; and the final map with the
reserve skew and timestamp gate.  The final version is the complete source in
`Strategy.sol` and in `result.json`.

Next follow-ups:

1. Compare EWMA rates 1/8 and 1/32 on fresh paired seeds.
2. Replace the hard 1% gate with a trade-size/price-consistency classifier.
3. Sweep the volatility map endpoints and the 0–2 bps inventory skew jointly.

## Measurement status

The checkout initially contained no challenge sources or Python environment.
I fetched the pinned challenge repository into `test/scratch/amm-challenge` and
inspected the Solidity interfaces and `MatchRunner` seed construction.  I did
not claim a score or paired estimate without compiling/running the full Rust
and Python stack; those fields in `result.json` are explicitly marked as not
run.  The source was checked with the repository's validator after installing
the pinned package dependencies if available; see the command and outcome in
the result JSON.
