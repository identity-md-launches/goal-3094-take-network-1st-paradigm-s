// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {AMMStrategyBase} from "./AMMStrategyBase.sol";
import {TradeInfo} from "./IAMMStrategy.sol";

/// @notice Flow-conditioned spread around a filtered band-edge price.
contract Strategy is AMMStrategyBase {
    // 0: fair price; 1: timestamp+1; 2,3: last bid/ask;
    // 4: classified retail count with prior; 5: classified Y size sum;
    // 6: elapsed exposure with prior.
    function afterInitialize(uint256 x, uint256 y) external override returns (uint256, uint256) {
        slots[0] = wdiv(y, x);
        slots[1] = 0;
        slots[2] = 176 * (BPS / 10);
        slots[3] = 176 * (BPS / 10);
        // Shrink estimates toward the population centre for the first 512 steps.
        slots[4] = 133;
        slots[5] = 1581539992873537896448;
        slots[6] = 512;
    
        return (slots[2], slots[3]);
    }

    function afterSwap(TradeInfo calldata t) external override returns (uint256 bid, uint256 ask) {
        uint256 spot = wdiv(t.reserveY, t.reserveX);
        bool newStep = t.timestamp + 1 != slots[1];
        uint256 fair = slots[0];
        if (newStep) {
            uint256 dt = slots[1] == 0 ? t.timestamp + 1 : t.timestamp + 1 - slots[1];
            slots[6] += dt;
            slots[1] = t.timestamp + 1;
            // A first trade may be arbitrage. Its terminal band edge is an
            // observation of fair; partial filtering limits retail contamination.
            uint256 implied = t.isBuy
                ? wmul(spot, WAD - slots[2])
                : wdiv(spot, WAD - slots[3]);
            uint256 weight = _weight(clamp(190170 + slots[4] * 2341162 / slots[6], 600000, 1000000), clamp(11787378084440381440 + (slots[5] / slots[4]) * 690642 / 1000000, 19 * WAD, 21 * WAD));
            fair = (fair * (1000 - weight) + implied * weight) / 1000;
        } else {
            // Arbitrage happens at most once and before all retail in a step.
            // Only these unambiguous retail observations train the flow model.
            slots[4] += 1;
            slots[5] += t.amountY;
        }
        slots[0] = fair;
        // Observed flow is censored by routing and by dropping the first trade.
        // Affine calibration on training seeds corrects both routing censoring
        // and the exclusion of ambiguous first trades. Estimates are shrunk
        // toward the population centre with a 512-step prior.
        uint256 rate = clamp(190170 + slots[4] * 2341162 / slots[6], 600000, 1000000);
        uint256 size = clamp(11787378084440381440 + (slots[5] / slots[4]) * 690642 / 1000000, 19 * WAD, 21 * WAD);
        uint256 spread = _spread(rate, size);
        // Equal fair-relative quotes require a larger fee toward fair when
        // retail has displaced the AMM's spot, and a smaller fee away from it.
        if (spot >= fair) {
            uint256 d = wdiv(spot - fair, spot);
            bid = clampFee(spread + d);
            ask = spread > d ? spread - d : 0;
        } else {
            uint256 d = wdiv(fair - spot, fair);
            ask = clampFee(spread + d);
            bid = spread > d ? spread - d : 0;
        }
        slots[2] = bid;
        slots[3] = ask;
    }

    // Flow-conditioned trust in the ambiguous first-trade price observation.
    // Table values are thousandths; later same-step trades never update fair.
    function _weight(uint256 rate, uint256 size) internal pure returns (uint256) {
        uint256 row = rate < 733333 ? 0 : (rate < 866667 ? 1 : 2);
        uint256 col = size < 19666666666666666666 ? 0 : (size < 20333333333333333333 ? 1 : 2);
        if (row == 0) return col == 0 ? 227 : (col == 1 ? 227 : 227);
        else if (row == 1) return col == 0 ? 227 : (col == 1 ? 227 : 227);
        else return col == 0 ? 227 : (col == 1 ? 227 : 227);
    }

    function _spread(uint256 rate, uint256 size) internal pure returns (uint256) {
        // Three rate rows and three size columns. Units are tenths of a bp.
        uint256 row = rate < 733333 ? 0 : (rate < 866667 ? 1 : 2);
        uint256 col = size < 19666666666666666666 ? 0 : (size < 20333333333333333333 ? 1 : 2);
        uint256 fee10;
        if (row == 0) fee10 = col == 0 ? 176 : (col == 1 ? 176 : 176);
        else if (row == 1) fee10 = col == 0 ? 176 : (col == 1 ? 176 : 176);
        else fee10 = col == 0 ? 176 : (col == 1 ? 176 : 176);
        return fee10 * (BPS / 10);
    }

    function getName() external pure override returns (string memory) {
        return "Flow Estimate flat";
    }
}
