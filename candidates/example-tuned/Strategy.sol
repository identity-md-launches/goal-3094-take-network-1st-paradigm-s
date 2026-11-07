// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AMMStrategyBase} from "./AMMStrategyBase.sol";
import {TradeInfo} from "./IAMMStrategy.sol";

/// @notice Raises the fee on the side exposed by a large price-moving trade.
contract Strategy is AMMStrategyBase {
    uint256 private constant BASE_BID = 30 * BPS;
    uint256 private constant BASE_ASK = 30 * BPS;
    uint256 private constant THRESHOLD_BID = 50; // bps of Y reserves
    uint256 private constant THRESHOLD_ASK = 50; // bps of Y reserves
    uint256 private constant BUMP_BID = 135 * BPS;
    uint256 private constant BUMP_ASK = 135 * BPS;
    uint256 private constant DECAY_BID = 7 * BPS; // bps per elapsed step
    uint256 private constant DECAY_ASK = 7 * BPS;
    uint256 private constant MAX_BID = BASE_BID + 2 * BUMP_BID;
    uint256 private constant MAX_ASK = BASE_ASK + 2 * BUMP_ASK;

    // slots[0] = bid fee, slots[1] = ask fee, slots[2] = last observed step.
    function afterInitialize(uint256, uint256) external override returns (uint256, uint256) {
        slots[0] = BASE_BID;
        slots[1] = BASE_ASK;
        slots[2] = 0;
        return (BASE_BID, BASE_ASK);
    }

    function afterSwap(TradeInfo calldata trade) external override returns (uint256 bidFee, uint256 askFee) {
        uint256 elapsed = trade.timestamp > slots[2] ? trade.timestamp - slots[2] : 0;
        bidFee = slots[0];
        askFee = slots[1];

        // Saturating linear decay avoids underflow and cannot cross the base fee.
        uint256 excessBid = bidFee - BASE_BID;
        uint256 excessAsk = askFee - BASE_ASK;
        uint256 bidDecay = elapsed * DECAY_BID;
        uint256 askDecay = elapsed * DECAY_ASK;
        bidFee = BASE_BID + (bidDecay >= excessBid ? 0 : excessBid - bidDecay);
        askFee = BASE_ASK + (askDecay >= excessAsk ? 0 : excessAsk - askDecay);

        // When this AMM buys X, spot falls and a return trade uses its ask.
        // When it sells X, spot rises and a return trade uses its bid.
        if (trade.reserveY > 0) {
            uint256 sizeBps = trade.amountY * 10000 / trade.reserveY;
            if (trade.isBuy) {
                if (sizeBps >= THRESHOLD_ASK) {
                    askFee = askFee + BUMP_ASK;
                    if (askFee > MAX_ASK) askFee = MAX_ASK;
                }
            } else {
                if (sizeBps >= THRESHOLD_BID) {
                    bidFee = bidFee + BUMP_BID;
                    if (bidFee > MAX_BID) bidFee = MAX_BID;
                }
            }
        }

        slots[0] = bidFee;
        slots[1] = askFee;
        slots[2] = trade.timestamp;
        return (bidFee, askFee);
    }

    function getName() external pure override returns (string memory) {
        return "ExampleTuned";
    }
}
