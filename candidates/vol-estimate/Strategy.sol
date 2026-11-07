// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AMMStrategyBase} from "./AMMStrategyBase.sol";
import {IAMMStrategy, TradeInfo} from "./IAMMStrategy.sol";

/// @notice A volatility-adaptive fee with a deliberately small inventory skew.
///
/// The first trade observed at a new timestamp is normally the arbitrage
/// trade.  At the edge of the fee band its post-trade spot and the fee quote
/// reveal the fair price.  The EWMA below is intentionally slow: a retail
/// trade at a timestamp without an arbitrage trade cannot move the estimate
/// very much, while the fixed per-simulation sigma is accumulated over many
/// timestamps.
contract Strategy is AMMStrategyBase {
    // variance is stored as (relative_price_change^2 / WAD), so the expected
    // values for sigma=.000882..001008 are approximately 777e9..1016e9.
    uint256 private constant LOW_VARIANCE = 777_924_000_000;
    uint256 private constant HIGH_VARIANCE = 1_016_064_000_000;
    uint256 private constant BASE_LOW = 34 * BPS;
    uint256 private constant BASE_HIGH = 50 * BPS;
    uint256 private constant INITIAL_FEE = 42 * BPS;
    uint256 private constant MAX_SKEW = 2 * BPS;

    function afterInitialize(uint256 initialX, uint256 initialY)
        external
        override
        returns (uint256 bidFee, uint256 askFee)
    {
        slots[0] = initialX;
        slots[1] = initialY;
        slots[2] = INITIAL_FEE;
        slots[3] = INITIAL_FEE;
        slots[4] = 0; // last inferred fair price
        slots[5] = 0; // EWMA variance
        slots[6] = type(uint256).max; // no previous timestamp
        slots[7] = 0; // number of accepted observations
        return (INITIAL_FEE, INITIAL_FEE);
    }

    function afterSwap(TradeInfo calldata trade)
        external
        override
        returns (uint256 bidFee, uint256 askFee)
    {
        uint256 bid = slots[2];
        uint256 ask = slots[3];

        // Only one observation is taken per timestamp.  This prevents the
        // retail trades following an arb from being counted as new prices.
        if (trade.timestamp != slots[6]) {
            slots[6] = trade.timestamp;

            uint256 fair;
            if (trade.isBuy) {
                // p = spot_post * (1 - bidFee)
                fair = (trade.reserveY * (WAD - bid)) / trade.reserveX;
            } else {
                // p = spot_post / (1 - askFee)
                fair = (trade.reserveY * WAD) / (trade.reserveX * (WAD - ask));
            }

            uint256 previous = slots[4];
            if (previous != 0 && fair != 0) {
                uint256 delta = absDiff(fair, previous);
                // Ignore impossible jumps, which are characteristic of a
                // retail-only first trade rather than an edge-setting arb.
                if (delta <= previous / 100) {
                    uint256 relative = (delta * WAD) / previous;
                    uint256 observation = (relative * relative) / WAD;
                    uint256 variance = slots[5];
                    if (variance == 0) variance = observation;
                    else variance = (variance * 15 + observation) / 16;
                    slots[5] = variance;
                    slots[7] += 1;
                }
            }
            if (fair != 0) slots[4] = fair;
        }

        uint256 varianceNow = slots[5];
        uint256 base;
        if (varianceNow <= LOW_VARIANCE) {
            base = BASE_LOW;
        } else if (varianceNow >= HIGH_VARIANCE) {
            base = BASE_HIGH;
        } else {
            base = BASE_LOW + ((varianceNow - LOW_VARIANCE) * (BASE_HIGH - BASE_LOW))
                / (HIGH_VARIANCE - LOW_VARIANCE);
        }

        // Compare normalized reserves with the starting inventory.  This is
        // intentionally capped: volatility is the primary signal, inventory
        // only breaks ties between otherwise similar quotes.
        uint256 lhs = trade.reserveX * slots[1];
        uint256 rhs = trade.reserveY * slots[0];
        if (lhs > rhs) {
            bid = base + MAX_SKEW;
            ask = base > MAX_SKEW ? base - MAX_SKEW : 0;
        } else if (rhs > lhs) {
            bid = base > MAX_SKEW ? base - MAX_SKEW : 0;
            ask = base + MAX_SKEW;
        } else {
            bid = base;
            ask = base;
        }

        slots[2] = clampFee(bid);
        slots[3] = clampFee(ask);
        return (slots[2], slots[3]);
    }

    function getName() external pure override returns (string memory) {
        return "Volatility Estimate";
    }
}
