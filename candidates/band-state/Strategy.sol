// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AMMStrategyBase} from "./AMMStrategyBase.sol";
import {TradeInfo} from "./IAMMStrategy.sol";

/// @notice Three-state fee policy with a tolerant inferred-price band test.
contract Strategy is AMMStrategyBase {
    uint256 private constant BASE = 70 * BPS;
    uint256 private constant LOW = 0 * BPS;
    uint256 private constant HIGH = 110 * BPS;
    uint256 private constant TOLERANCE = 20 * BPS;
    uint256 private constant DECAY = 8;

    // 0: inferred fair price; 1: last timestamp plus one; 2/3: live bid/ask;
    // 4: state (0 retail, 1 arb buys X, 2 arb sells X);
    // 5: state-change timestamp; 6: previous post-trade spot.
    function afterInitialize(uint256 x, uint256 y)
        external override returns (uint256, uint256)
    {
        slots[0] = wdiv(y, x);
        slots[1] = 0;
        slots[2] = BASE;
        slots[3] = BASE;
        slots[4] = 0;
        slots[5] = 0;
        slots[6] = slots[0];
        return (BASE, BASE);
    }

    function afterSwap(TradeInfo calldata t)
        external override returns (uint256 bidFee, uint256 askFee)
    {
        uint256 spot = wdiv(t.reserveY, t.reserveX);
        bool first = t.timestamp + 1 > slots[1];
        uint256 state;
        if (first) {
            uint256 elapsed = slots[1] == 0 ? 1 : t.timestamp + 1 - slots[1];
            uint256 fee = t.isBuy ? slots[2] : slots[3];
            uint256 implied = t.isBuy ? wmul(spot, WAD - fee) : wdiv(spot, WAD - fee);
            uint256 priorEdge = t.isBuy
                ? wmul(slots[6], WAD - fee) : wdiv(slots[6], WAD - fee);
            uint256 fair = slots[0];
            // Linear uncertainty allowance, capped to avoid accepting huge retail moves.
            uint256 tolerance = wmul(fair, TOLERANCE + (elapsed > 10 ? 10 : elapsed) * 2 * BPS);
            bool towardBand = t.isBuy ? priorEdge + tolerance >= fair : priorEdge <= fair + tolerance;
            if (towardBand && absDiff(implied, fair) <= tolerance) {
                state = t.isBuy ? 2 : 1;
                slots[0] = implied;
            } else {
                // A noisy first trade still carries price information. Bound its influence.
                uint256 limit = wmul(fair, 100 * BPS);
                if (implied > fair) slots[0] = fair + (implied - fair > limit ? limit : implied - fair) / 4;
                else slots[0] = fair - (fair - implied > limit ? limit : fair - implied) / 4;
            }
        }
        if (state != slots[4]) {
            slots[4] = state;
            slots[5] = t.timestamp;
        }
        uint256 age = t.timestamp - slots[5];
        bidFee = BASE;
        askFee = BASE;
        if (state != 0 && age < DECAY) {
            uint256 low = BASE - (BASE - LOW) * (DECAY - age) / DECAY;
            uint256 high = BASE + (HIGH - BASE) * (DECAY - age) / DECAY;
            bidFee = state == 1 ? low : high;
            askFee = state == 1 ? high : low;
        }
        slots[1] = t.timestamp + 1;
        slots[2] = bidFee;
        slots[3] = askFee;
        slots[6] = spot;
    }

    function getName() external pure override returns (string memory) {
        return "BandState";
    }
}
