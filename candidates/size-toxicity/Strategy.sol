// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {AMMStrategyBase} from "./AMMStrategyBase.sol";
import {TradeInfo} from "./IAMMStrategy.sol";

/// @notice Fair-value quotes with bounded, per-side quadratic flow toxicity.
contract Strategy is AMMStrategyBase {
    uint256 constant BASE = 2500 * 1e12;
    uint256 constant ALPHA = 260;
    uint256 constant SIZE_GAIN = 30;
    uint256 constant STREAK_GAIN = 10 * 1e12;
    uint256 constant DECAY = 1000;
    uint256 constant SKEW = 500;
    // 0 fair price; 1/2 previous bid/ask; 3 last timestamp;
    // 4/5 buy/sell size pressure; 6 direction (1 buy, 2 sell); 7 streak.
    function afterInitialize(uint256 x, uint256 y) external override returns (uint256, uint256) {
        slots[0] = wdiv(y, x);
        slots[1] = BASE;
        slots[2] = BASE;
        slots[3] = 0;
        slots[4] = 0;
        slots[5] = 0;
        slots[6] = 0;
        slots[7] = 0;
        return (BASE, BASE);
    }
    function afterSwap(TradeInfo calldata t) external override returns (uint256 bid, uint256 ask) {
        uint256 spot = wdiv(t.reserveY, t.reserveX);
        uint256 dt = t.timestamp > slots[3] ? t.timestamp - slots[3] : 0;
        uint256 fair = slots[0];
        uint256 oldFee = t.isBuy ? slots[1] : slots[2];
        uint256 implied = t.isBuy ? wmul(spot, WAD - oldFee) : wdiv(spot, WAD - oldFee);
        // Only the first trade in a step can be the price-revealing arb.
        if (dt > 0) {
            fair = (fair * (1000 - ALPHA) + implied * ALPHA) / 1000;
            slots[0] = fair;
        }
        uint256 buyPressure = slots[4];
        uint256 sellPressure = slots[5];
        uint256 streak = slots[7];
        if (dt > 0) {
            uint256 divisor = 1000 + DECAY * (dt > 64 ? 64 : dt);
            buyPressure = buyPressure * 1000 / divisor;
            sellPressure = sellPressure * 1000 / divisor;
            streak = streak * 1000 / divisor;
        }
        uint256 ratio = wdiv(t.amountY, t.reserveY);
        if (ratio > WAD / 20) ratio = WAD / 20;
        uint256 impulse = wmul(ratio, ratio) * SIZE_GAIN;
        uint256 direction = t.isBuy ? 1 : 2;
        streak = slots[6] == direction ? streak + WAD : WAD;
        if (streak > 6 * WAD) streak = 6 * WAD;
        uint256 repeatFee = wmul(wmul(streak - WAD, streak - WAD), STREAK_GAIN);
        if (t.isBuy) buyPressure += impulse + repeatFee;
        else sellPressure += impulse + repeatFee;
        buyPressure = clamp(buyPressure, 0, 200 * BPS);
        sellPressure = clamp(sellPressure, 0, 200 * BPS);
        slots[4] = buyPressure;
        slots[5] = sellPressure;
        slots[6] = direction;
        slots[7] = streak;
        slots[3] = t.timestamp;
        uint256 divergence = wdiv(absDiff(spot, fair), fair) * SKEW / 1000;
        if (spot > fair) {
            bid = BASE + divergence + buyPressure;
            ask = BASE + sellPressure;
            ask = ask > divergence ? ask - divergence : 0;
        } else {
            ask = BASE + divergence + sellPressure;
            bid = BASE + buyPressure;
            bid = bid > divergence ? bid - divergence : 0;
        }
        bid = clampFee(bid);
        ask = clampFee(ask);
        slots[1] = bid;
        slots[2] = ask;
    }
    function getName() external pure override returns (string memory) {
        return "Size Toxicity";
    }
}
