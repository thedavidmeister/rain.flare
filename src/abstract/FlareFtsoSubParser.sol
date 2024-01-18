// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {BaseRainterpreterSubParserNPE2, Operand} from "rain.interpreter/abstract/BaseRainterpreterSubParserNPE2.sol";
import {OPCODE_FTSO_CURRENT_PRICE_USD} from "./FlareFtsoExtern.sol";
import {LibSubParse, IInterpreterExternV3} from "rain.interpreter/lib/parse/LibSubParse.sol";
import {LibParseOperand} from "rain.interpreter/lib/parse/LibParseOperand.sol";
import {LibConvert} from "rain.lib.typecast/LibConvert.sol";
import {AuthoringMetaV2} from "rain.interpreter/interface/IParserV1.sol";

bytes constant SUB_PARSER_PARSE_META = hex"01000000000000000000000000000000000000000000080000000000000000000000008057ab";

bytes constant SUB_PARSER_WORD_PARSERS = hex"06c6";

bytes constant SUB_PARSER_OPERAND_HANDLERS = hex"0acd";

uint256 constant SUB_PARSER_WORD_FTSO_CURRENT_PRICE_USD = 0;
uint256 constant SUB_PARSER_WORD_PARSERS_LENGTH = 1;

function authoringMetaV2() pure returns (bytes memory) {
    AuthoringMetaV2[] memory meta = new AuthoringMetaV2[](SUB_PARSER_WORD_PARSERS_LENGTH);
    meta[SUB_PARSER_WORD_FTSO_CURRENT_PRICE_USD] = AuthoringMetaV2(
        "ftso-current-price-usd",
        "Returns the current USD price of the given token according to the FTSO. Accepts 2 inputs, the symbol string used by the FTSO and the timeout in seconds. The price is returned as 18 decimal fixed point number, rounding down if this results in any precision loss. The timeout will be used to determine if the price is stale and revert if it is."
    );
    return abi.encode(meta);
}

abstract contract FlareFtsoSubParser is BaseRainterpreterSubParserNPE2 {
    function extern() internal view virtual returns (address);

    function subParserParseMeta() internal pure override returns (bytes memory) {
        return SUB_PARSER_PARSE_META;
    }

    function subParserWordParsers() internal pure override returns (bytes memory) {
        return SUB_PARSER_WORD_PARSERS;
    }

    function subParserOperandHandlers() internal pure override returns (bytes memory) {
        return SUB_PARSER_OPERAND_HANDLERS;
    }

    function buildSubParserOperandHandlers() external pure returns (bytes memory) {
        function(uint256[] memory) internal pure returns (Operand)[] memory fs =
            new function(uint256[] memory) internal pure returns (Operand)[](SUB_PARSER_WORD_PARSERS_LENGTH);
        fs[SUB_PARSER_WORD_FTSO_CURRENT_PRICE_USD] = LibParseOperand.handleOperandDisallowed;

        uint256[] memory pointers;
        assembly ("memory-safe") {
            pointers := fs
        }
        return LibConvert.unsafeTo16BitBytes(pointers);
    }

    function buildSubParserWordParsers() external pure returns (bytes memory) {
        function(uint256, uint256, Operand) internal view returns (bool, bytes memory, uint256[] memory)[] memory fs =
        new function(uint256, uint256, Operand) internal view returns (bool, bytes memory, uint256[] memory)[](
            SUB_PARSER_WORD_PARSERS_LENGTH
        );
        fs[SUB_PARSER_WORD_FTSO_CURRENT_PRICE_USD] = ftsoCurrentPriceUsdSubParser;

        uint256[] memory pointers;
        assembly ("memory-safe") {
            pointers := fs
        }
        return LibConvert.unsafeTo16BitBytes(pointers);
    }

    function ftsoCurrentPriceUsdSubParser(uint256 constantsHeight, uint256 inputsByte, Operand operand)
        internal
        view
        returns (bool, bytes memory, uint256[] memory)
    {
        //slither-disable-next-line unused-return
        return LibSubParse.subParserExtern(
            IInterpreterExternV3(extern()),
            constantsHeight,
            inputsByte,
            // 1 output for the price.
            1,
            operand,
            OPCODE_FTSO_CURRENT_PRICE_USD
        );
    }
}
