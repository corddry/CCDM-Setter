// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {console} from "forge-std/console.sol";
import {DepositExecutor, WeirollWallet} from "../lib/cross-chain-deposit-module/src/core/DepositExecutor.sol";

contract CCDMSetter {

    /// @notice Mapping from a setter to the index of a value they set to the timestamp that value was set
    mapping(address => mapping(uint256 => uint256)) public setterToIndexToTimestamp;
    /// @notice Mapping from a setter to the index of a value they set to that value
    mapping(address => mapping(uint256 => uint256)) public setterToIndexToValue;

    /// @notice Sets the value at the 0 index for the setter, must be retreived in the same block
    function setSingleValue(uint256 value) public {
        setValue(0, value);
    }

    /// @notice Sets the value at a given index for the setter, allowing multiple values to be set, must be retreived in the same block
    function setValue(uint256 index, uint256 value) public {
        setterToIndexToTimestamp[msg.sender][index] = block.timestamp;
        setterToIndexToValue[msg.sender][index] = value;
    }

    /// @notice Gets the value at the 0 index for the setter, reverts if the value was not set this block
    function getSingleValue() public view returns (uint256) {
        return getValue(0);
    }

    /// @notice Gets the value at a given index for the setter, reverts if the value was not set this block
    function getValue(uint256 index) public view returns (uint256) {
        DepositExecutor depositExecutor = DepositExecutor(WeirollWallet(payable(msg.sender)).recipeMarketHub());
        bytes32 marketHash = WeirollWallet(payable(msg.sender)).marketHash();

        (address owner,,,,,) = depositExecutor.sourceMarketHashToDepositCampaign(marketHash);

        require(setterToIndexToTimestamp[owner][index] == block.timestamp, "Value not set this block");
        return setterToIndexToValue[owner][index];
    }
}
