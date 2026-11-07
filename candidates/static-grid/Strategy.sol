// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AMMStrategyBase} from "./AMMStrategyBase.sol";
import {TradeInfo} from "./IAMMStrategy.sol";

/// @notice Fixed fees selected by paired static-grid measurements.
contract Strategy is AMMStrategyBase {
    uint256 public constant BID_FEE = 75 * BPS;
    uint256 public constant ASK_FEE = 75 * BPS;

    function afterInitialize(uint256, uint256) external pure override returns (uint256, uint256) {
        return (BID_FEE, ASK_FEE);
    }

    function afterSwap(TradeInfo calldata) external pure override returns (uint256, uint256) {
        return (BID_FEE, ASK_FEE);
    }

    function getName() external pure override returns (string memory) {
        return "Static Grid 75/75";
    }
}
