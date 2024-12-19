// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {CCDMSetter} from "../src/CCDMSetter.sol";
import {DepositExecutor, WeirollWallet, ClonesWithImmutableArgs} from "../lib/cross-chain-deposit-module/src/core/DepositExecutor.sol";

contract CCDMSetterTest is Test {
    using ClonesWithImmutableArgs for address;

    address constant EXECUTOR_OWNER = address(0xA11CE);
    address constant MARKET_OWNER = address(0xB0B);
    bytes32 constant SOURCE_MARKET_HASH = bytes32(abi.encode("merry-christmas"));

    address public weirollWalletImplementation;
    DepositExecutor public depositExecutor;
    WeirollWallet public depositWallet;
    CCDMSetter public ccdmSetter;

    function setUp() public {
        weirollWalletImplementation = address(new WeirollWallet());
        address[] memory validLzOFTs = new address[](0);

        depositExecutor = new DepositExecutor(
            EXECUTOR_OWNER,
            address(0),
            address(0),
            address(0),
            30_101,
            address(0),
            validLzOFTs,
            new bytes32[](0),
            new address[](0)
        );

        depositWallet = createWallet(address(0), address(depositExecutor), uint256(0), block.timestamp, false, SOURCE_MARKET_HASH);

        vm.prank(EXECUTOR_OWNER);
        depositExecutor.setNewCampaignOwner(SOURCE_MARKET_HASH, MARKET_OWNER);

        ccdmSetter = new CCDMSetter();
    }

    function createWallet(
        address _owner,
        address _recipeMarketHub,
        uint256 _amount,
        uint256 _lockedUntil,
        bool _isForfeitable,
        bytes32 _marketHash
    ) public returns (WeirollWallet) {
        return WeirollWallet(
            payable(weirollWalletImplementation.clone(abi.encodePacked(_owner, _recipeMarketHub, _amount, _lockedUntil, _isForfeitable, _marketHash)))
        );
    }

    
    function test_CCDMSetter() public {
        vm.startPrank(MARKET_OWNER);
        ccdmSetter.setValue(0, 100);
        ccdmSetter.setValue(3, 300);
        ccdmSetter.setValue(2, 200);
        vm.stopPrank();

        vm.startPrank(address(depositWallet));
        assertEq(ccdmSetter.getValue(0), 100);
        assertEq(ccdmSetter.getValue(3), 300);
        assertEq(ccdmSetter.getValue(2), 200);
        vm.stopPrank();
    }

    function testFail_wrongSetter() public {
        vm.prank(address(0xBAD));
        ccdmSetter.setValue(0, 100);

        vm.prank(address(depositWallet));
        ccdmSetter.getValue(0);
    }

    function testFail_timePassesAfterSet() public {
        vm.prank(MARKET_OWNER);
        ccdmSetter.setValue(0, 100);

        vm.warp(block.timestamp + 1);
        vm.prank(address(depositWallet));
        ccdmSetter.getValue(0);
    }
}
