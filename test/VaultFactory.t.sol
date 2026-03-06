// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {VaultFactory} from "../src/VaultFactory.sol";
import {VaultNFT} from "../src/VaultNFT.sol";
import {Vault} from "../src/Vault.sol";

contract VaultFactoryTest is Test {
    VaultFactory vFactory;
    VaultNFT vNFT;

    address USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address WHALE = 0x55FE002aefF02F77364de339a1292923A15844B8;

    function setUp() public {
        vm.createSelectFork("https://mainnet.gateway.tenderly.co");
        vFactory = new VaultFactory();
        vNFT = vFactory.nft();
    }

    function testCreateVault() public {
        address predicted = vFactory.computeVaultAddress(USDC);
        address vault = vFactory.createVault(USDC);
        assertEq(predicted, vault, "CREATE2 address mismatch");
    }

    function testCreateVaultMintsNFT() public {
        vFactory.createVault(USDC);
        assertEq(vNFT.tokenId(), 1);
        assertEq(vNFT.ownerOf(1), address(this));
    }

    function testDeposit() public {
        address vault = vFactory.createVault(USDC);

        vm.startPrank(WHALE);

        IERC20(USDC).approve(vault, 1000e6);

        Vault(vault).deposit(1000e6);

        vm.stopPrank();

        assertEq(Vault(vault).balances(WHALE), 1000e6);

        assertEq(Vault(vault).totalDeposits(), 1000e6);
    }

    function testWithdraw() public {
        address vault = vFactory.createVault(USDC);

        vm.startPrank(WHALE);

        IERC20(USDC).approve(vault, 1000e6);

        Vault(vault).deposit(1000e6);

        Vault(vault).withdraw(400e6);

        vm.stopPrank();

        assertEq(Vault(vault).balances(WHALE), 600e6);

        assertEq(Vault(vault).totalDeposits(), 600e6);
    }

}
