// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AMMStrategyBase} from "./AMMStrategyBase.sol";
import {TradeInfo} from "./IAMMStrategy.sol";

/// @notice Fair-value quotes with bounded inventory and depth adjustments.
contract Strategy is AMMStrategyBase {
    // slots: 0 fair price, 1 timestamp, 2 bid, 3 ask, 4 initial Y,
    // 5 initial value imbalance (encoded with a WAD offset).
    function afterInitialize(uint256 initialX, uint256 initialY)
        external override returns (uint256, uint256)
    {
        slots[0] = wdiv(initialY, initialX);
        slots[1] = 0;
        slots[2] = 30 * BPS;
        slots[3] = 30 * BPS;
        slots[4] = initialY;
        uint256 xValue = wmul(initialX, slots[0]);
        slots[5] = uint256(int256(WAD) +
            (int256(xValue) - int256(initialY)) * int256(WAD) / int256(xValue + initialY));
        return (slots[2], slots[3]);
    }

    function afterSwap(TradeInfo calldata t)
        external override returns (uint256 bidFee, uint256 askFee)
    {
        uint256 spot = wdiv(t.reserveY, t.reserveX);
        uint256 implied = t.isBuy
            ? wmul(spot, WAD - slots[2])
            : wdiv(spot, WAD - slots[3]);
        uint256 fair = slots[0];
        // First trade can be arbitrage; later trades share the same fair price.
        uint256 alpha = t.timestamp > slots[1] ? 2600 : 500;
        implied = clamp(implied, fair * 97 / 100, fair * 103 / 100);
        fair = (fair * (10000 - alpha) + implied * alpha) / 10000;
        slots[0] = fair;
        slots[1] = t.timestamp;

        uint256 xValue = wmul(t.reserveX, fair);
        int256 inventory = (int256(xValue) - int256(t.reserveY)) * int256(WAD)
            / int256(xValue + t.reserveY) - (int256(slots[5]) - int256(WAD));
        // A long X balance raises the buying fee and lowers the selling fee.
        int256 skew = inventory / 10;
        int256 cap = int256(10 * BPS);
        if (skew > cap) skew = cap;
        if (skew < -cap) skew = -cap;
        // Shallower reserves increase adverse-selection cost per unit of flow.
        uint256 depth = clamp(wdiv(slots[4], t.reserveY), WAD / 2, 2 * WAD);
        int256 spread = int256(15 * BPS + wmul(5 * BPS, depth));
        int256 deviation = (int256(spot) - int256(fair)) * int256(WAD) / int256(fair);
        bidFee = bounded(spread + deviation + skew);
        askFee = bounded(spread - deviation - skew);
        slots[2] = bidFee;
        slots[3] = askFee;
    }

    function bounded(int256 fee) internal pure returns (uint256) {
        return fee <= 0 ? 0 : clampFee(uint256(fee));
    }

    function getName() external pure override returns (string memory) {
        return "InventoryDepthR1";
    }
}
