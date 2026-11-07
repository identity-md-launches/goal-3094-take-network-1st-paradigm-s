// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AMMStrategyBase} from "./AMMStrategyBase.sol";
import {TradeInfo} from "./IAMMStrategy.sol";

/// @notice Center fee-adjusted quotes on a price inferred from likely arbitrage.
contract Strategy is AMMStrategyBase {
    uint256 private constant BID_SPREAD = 10 * BPS;
    uint256 private constant ASK_SPREAD = 10 * BPS;
    uint256 private constant AGE_WIDTH = 10000000000000;
    uint256 private constant READ_TOLERANCE = 25 * BPS;

    // 0: inferred fair price; 1: last accepted observation timestamp + 1;
    // 2: last callback timestamp + 1; 3/4: previously quoted bid/ask fees.
    function afterInitialize(uint256 initialX, uint256 initialY)
        external override returns (uint256 bidFee, uint256 askFee)
    {
        slots[0] = wdiv(initialY, initialX);
        slots[1] = 1;
        slots[2] = 0;
        slots[5] = slots[0];
        bidFee = BID_SPREAD;
        askFee = wdiv(ASK_SPREAD, WAD + ASK_SPREAD);
        slots[3] = bidFee;
        slots[4] = askFee;
    }

    function afterSwap(TradeInfo calldata trade)
        external override returns (uint256 bidFee, uint256 askFee)
    {
        uint256 spot = wdiv(trade.reserveY, trade.reserveX);
        uint256 fair = slots[0];
        uint256 nowTag = trade.timestamp + 1;
        uint256 age = nowTag > slots[1] ? nowTag - slots[1] : 0;

        // Only the first callback of a step can be arbitrage. Its old-fee band
        // edge is an exact price observation IF it was arbitrage; consistency
        // with the last estimate is a heuristic, not proof of trade identity.
        uint256 priorSpot = slots[5];
        slots[5] = spot;
        if (nowTag != slots[2] && (trade.isBuy ? priorSpot <= fair : priorSpot >= fair)) {
            uint256 implied = trade.isBuy
                ? wmul(spot, WAD - slots[3])
                : wdiv(spot, WAD - slots[4]);
            uint256 root = sqrt((age == 0 ? 1 : age) * 1e6);
            uint256 tolerance = READ_TOLERANCE * root / 1000 + slots[6];
            if (absDiff(implied, fair) <= wmul(fair, tolerance)) {
                slots[6] = wdiv(absDiff(implied, fair), fair);
                fair = implied;
                slots[0] = fair;
                slots[1] = nowTag;
                age = 0;
            }
        }
        slots[2] = nowTag;

        uint256 widening = AGE_WIDTH * sqrt(age * 1e6) / 1000;
        uint256 sBid = clampFee(BID_SPREAD + widening);
        uint256 sAsk = clampFee(ASK_SPREAD + widening);

        // Solve spot*(1-bid) = fair*(1-sBid) and
        // spot/(1-ask) = fair*(1+sAsk), with exact fee-on-input algebra.
        uint256 targetBid = wmul(fair, WAD - sBid);
        uint256 targetAsk = wmul(fair, WAD + sAsk);
        bidFee = spot > targetBid ? clampFee(wdiv(spot - targetBid, spot)) : 0;
        askFee = targetAsk > spot ? clampFee(wdiv(targetAsk - spot, targetAsk)) : 0;
        slots[3] = bidFee;
        slots[4] = askFee;
    }

    function getName() external pure override returns (string memory) {
        return "Fair Centered";
    }
}
