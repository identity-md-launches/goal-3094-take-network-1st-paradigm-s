// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AMMStrategyBase} from "./AMMStrategyBase.sol";
import {TradeInfo} from "./IAMMStrategy.sol";

/// @notice Router marginal-edge objective with a future-arbitrage penalty.
contract Strategy is AMMStrategyBase {
    uint256 private constant RISK_WEIGHT = 2500;
    uint256 private constant RISK_SUPPORT = 60 * BPS;
    uint256 private constant MEAN_ORDER = 20 * WAD;

    // slots: 0 filtered fair price; 1 last timestamp + 1; 2 bid; 3 ask.
    function afterInitialize(uint256 initialX, uint256 initialY)
        external override returns (uint256 bidFee, uint256 askFee)
    {
        uint256 fair = wdiv(initialY, initialX);
        slots[0] = fair;
        slots[1] = 0;
        slots[4] = fair;
        (bidFee, askFee) = quote(fair, fair, initialY, fair);
        slots[2] = bidFee;
        slots[3] = askFee;
    }

    function afterSwap(TradeInfo calldata trade)
        external override returns (uint256 bidFee, uint256 askFee)
    {
        if (trade.reserveX == 0 || trade.reserveY == 0) return (MAX_FEE, MAX_FEE);
        uint256 spot = wdiv(trade.reserveY, trade.reserveX);
        uint256 fair = slots[0];
        uint256 implied = trade.isBuy
            ? wmul(spot, WAD - slots[2])
            : wdiv(spot, WAD - slots[3]);
        uint256 endpoint = implied;
        bool first = trade.timestamp + 1 != slots[1];
        uint256 weight = first ? 26 : 5;
        // An arbitrage endpoint reveals fair price. Retail endpoints are noisy;
        // use a bounded filter and less weight after the first fill of a step.
        uint256 limit = fair * 60 / 10000;
        implied = clamp(implied, fair - limit, fair + limit);
        fair = (fair * (100 - weight) + implied * weight) / 100;
        slots[0] = fair;
        slots[1] = trade.timestamp + 1;
        // Both pools keep k constant. At fair, normalizer Y is sqrt(k * fair).
        // This arithmetic approximation has only second-order spot error.
        uint256 depth = (trade.reserveY + wmul(trade.reserveX, fair)) / 2;
        uint256 normalizer = slots[4];
        if (first) {
            normalizer = clamp(normalizer, wmul(fair, WAD - 30 * BPS), wdiv(fair, WAD - 30 * BPS));
        }
        // A retail split equates fee-adjusted post-trade marginal prices.
        uint256 routed = trade.isBuy
            ? wdiv(endpoint, WAD - 30 * BPS)
            : wmul(endpoint, WAD - 30 * BPS);
        uint256 inferred = trade.isBuy
            ? (normalizer < routed ? normalizer : routed)
            : (normalizer > routed ? normalizer : routed);
        if (!first) normalizer = inferred;
        else normalizer = inferred;
        slots[4] = normalizer;
        (bidFee, askFee) = quote(spot, fair, depth, normalizer);
        slots[2] = bidFee;
        slots[3] = askFee;
    }

    function marginFor(int256 competitorCost, uint256 depth) private pure returns (uint256 margin) {
        int256 raw = (competitorCost + int256(2 * wdiv(MEAN_ORDER, depth))) / 3;
        margin = raw > int256(5 * BPS) ? uint256(raw) : 5 * BPS;
        margin = clamp(margin, 5 * BPS, 300 * BPS);
        if (margin < RISK_SUPPORT && RISK_WEIGHT != 0) {
            uint256 gap = RISK_SUPPORT - margin;
            margin += 2 * RISK_WEIGHT * gap * gap
                / (3 * 8000 * RISK_SUPPORT + 4 * RISK_WEIGHT * gap);
        }
    }

    function quote(uint256 spot, uint256 fair, uint256 depth, uint256 normalizer)
        private pure returns (uint256 bidFee, uint256 askFee)
    {
        fair = (fair * 3 + spot) / 4;
        uint256 ratio = wdiv(normalizer, fair);
        uint256 bidMargin = marginFor(int256(WAD) - int256(wmul(ratio, WAD - 30 * BPS)), depth);
        uint256 askMargin = marginFor(int256(wdiv(ratio, WAD - 30 * BPS)) - int256(WAD), depth);
        uint256 bidRatio = fair * (WAD - bidMargin) / spot;
        uint256 askRatio = spot * WAD / wmul(fair, WAD + askMargin);
        bidFee = bidRatio < WAD ? clampFee(WAD - bidRatio) : 0;
        askFee = askRatio < WAD ? clampFee(WAD - askRatio) : 0;
    }

    function getName() external pure override returns (string memory) {
        return "RouterOptimal";
    }
}
