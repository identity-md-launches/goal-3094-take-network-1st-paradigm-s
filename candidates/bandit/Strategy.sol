// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AMMStrategyBase} from "./AMMStrategyBase.sol";
import {TradeInfo} from "./IAMMStrategy.sol";

/// @notice Epsilon-greedy fee selection driven by trade edge against an
///         online estimate of the fair price.
contract Strategy is AMMStrategyBase {
    uint256 private constant ARM_COUNT = 5;
    uint256 private constant MEAN_OFFSET = 100 * WAD;
    int256 private constant EDGE_LIMIT = int256(100 * WAD);
    uint256 private constant PRICE_GATE = 3e16; // reject implied-price jumps over 3%

    function afterInitialize(uint256 initialX, uint256 initialY)
        external
        override
        returns (uint256 bidFee, uint256 askFee)
    {
        // Start in the center of the tested high-fee range; subsequent
        // trades sample each arm before the policy exploits its estimates.
        slots[0] = 2;
        for (uint256 i = 0; i < ARM_COUNT; ++i) {
            slots[1 + i] = 0; // observations for arm i
            slots[6 + i] = MEAN_OFFSET; // zero signed-edge estimate
        }
        slots[11] = wdiv(initialY, initialX); // fair-price estimate, WAD
        slots[12] = 0; // last timestamp observed
        slots[13] = 0; // whether a trade has been observed yet
        slots[14] = 0; // total observations, used to decorrelate exploration

        uint256 fee = _feeFor(2);
        return (fee, fee);
    }

    function afterSwap(TradeInfo calldata trade)
        external
        override
        returns (uint256 bidFee, uint256 askFee)
    {
        uint256 arm = slots[0];
        if (arm >= ARM_COUNT) arm = 2;

        uint256 currentFee = _feeFor(arm);
        uint256 fairPrice = _updateFairPrice(trade, currentFee);

        uint256 valueX = wmul(trade.amountX, fairPrice);
        uint256 notional = valueX + trade.amountY;
        if (notional != 0) {
            int256 signedEdge;
            if (trade.isBuy) {
                signedEdge = int256(trade.amountY) - int256(valueX);
            } else {
                signedEdge = int256(valueX) - int256(trade.amountY);
            }
            int256 reward = signedEdge;
            if (reward > EDGE_LIMIT) reward = EDGE_LIMIT;
            if (reward < -EDGE_LIMIT) reward = -EDGE_LIMIT;
            _recordReward(arm, reward);
        }

        uint256 total = slots[14] + 1;
        slots[14] = total;
        uint256 nextArm = _chooseArm(trade, total);
        slots[0] = nextArm;

        uint256 nextFee = _feeFor(nextArm);
        return (nextFee, nextFee);
    }

    function _updateFairPrice(TradeInfo calldata trade, uint256 fee)
        private
        returns (uint256 fairPrice)
    {
        uint256 gamma = WAD - fee;
        uint256 spot = wdiv(trade.reserveY, trade.reserveX);
        uint256 implied = trade.isBuy ? wmul(spot, gamma) : wdiv(spot, gamma);

        uint256 oldFair = slots[11];
        if (oldFair == 0) oldFair = implied;
        uint256 difference = absDiff(implied, oldFair);
        bool plausible = difference <= wmul(oldFair, PRICE_GATE);
        bool firstTrade = slots[13] == 0 || trade.timestamp != slots[12];

        slots[13] = 1;
        slots[12] = trade.timestamp;

        if (plausible) {
            // First trade of a step is more likely to include the arbitrage
            // reset; later trades are retail and receive a smaller weight.
            uint256 alpha = firstTrade ? 26e16 : 5e16;
            if (implied >= oldFair) {
                oldFair += wmul(implied - oldFair, alpha);
            } else {
                oldFair -= wmul(oldFair - implied, alpha);
            }
            slots[11] = oldFair;
        }
        return slots[11];
    }

    function _recordReward(uint256 arm, int256 reward) private {
        uint256 count = slots[1 + arm] + 1;
        slots[1 + arm] = count;

        int256 previous = int256(slots[6 + arm]) - int256(MEAN_OFFSET);
        int256 nextMean;
        if (count == 1) {
            nextMean = reward;
        } else {
            // A short-memory mean follows changing market conditions while
            // retaining all-time counters for diagnostics.
            nextMean = previous + (reward - previous) / 32;
        }
        slots[6 + arm] = uint256(int256(MEAN_OFFSET) + nextMean);
    }

    function _chooseArm(TradeInfo calldata trade, uint256 total)
        private
        view
        returns (uint256)
    {
        // Give every fee level an initial observation before exploiting.
        for (uint256 i = 0; i < ARM_COUNT; ++i) {
            if (slots[1 + i] == 0) return i;
        }

        uint256 bestArm = 0;
        int256 bestMean = int256(slots[6]) - int256(MEAN_OFFSET);
        for (uint256 i = 1; i < ARM_COUNT; ++i) {
            int256 mean = int256(slots[6 + i]) - int256(MEAN_OFFSET);
            if (mean > bestMean) {
                bestMean = mean;
                bestArm = i;
            }
        }

        // Epsilon-greedy with epsilon=1/16. The trade tuple and observation
        // index provide a deterministic, seed-dependent exploration draw.
        uint256 draw = uint256(
            keccak256(
                abi.encodePacked(
                    trade.timestamp,
                    trade.amountX,
                    trade.amountY,
                    trade.reserveX,
                    trade.reserveY,
                    total
                )
            )
        );
        if ((draw & 15) == 0) return (draw >> 8) % ARM_COUNT;
        return bestArm;
    }

    function _feeFor(uint256 arm) private pure returns (uint256) {
        if (arm == 0) return bpsToWad(70);
        if (arm == 1) return bpsToWad(75);
        if (arm == 2) return bpsToWad(80);
        if (arm == 3) return bpsToWad(85);
        return bpsToWad(90);
    }

    function getName() external pure override returns (string memory) {
        return "Edge Bandit";
    }
}
