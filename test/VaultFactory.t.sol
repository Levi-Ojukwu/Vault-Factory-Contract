// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {VaultFactory} from "../src/VaultFactory.sol";
import {VaultNFT} from "../src/VaultNFT.sol";
import {Vault} from "../src/Vault.sol";

contract VaultFactoryTest is Test {
    using Strings for uint256;
    using Strings for address;

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

    function testTokenURI() public {
        vFactory.createVault(USDC);
        string memory uri = vNFT.tokenURI(1);
        console.log(uri);
        assertTrue(bytes(uri).length > 0);
    }

    function testRenderSVG() public {
        address vault = vFactory.createVault(USDC);

        vm.startPrank(WHALE);
        IERC20(USDC).approve(vault, 1000e6);
        Vault(vault).deposit(1000e6);
        vm.stopPrank();

        (address token, address vaultAddr) = vNFT.vaultData(1);
        uint256 balance = IERC20Metadata(token).balanceOf(vaultAddr);
        string memory tokenName = IERC20Metadata(token).name();
        string memory tokenSymbol = IERC20Metadata(token).symbol();

        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 350 350">',
            '<rect width="100%" height="100%" fill="#1a1a2e"/>',
            '<text x="50%" y="20%" fill="white" font-family="serif" font-size="18" text-anchor="middle">The Coding Chef</text>',
            '<text x="50%" y="35%" fill="white" font-family="serif" font-size="13" text-anchor="middle">Token: ', tokenName, ' (', tokenSymbol, ')</text>',
            '<text x="50%" y="50%" fill="white" font-family="serif" font-size="13" text-anchor="middle">Balance: ', balance.toString(), ' ', tokenSymbol, '</text>',
            '<text x="50%" y="70%" fill="white" font-family="serif" font-size="9" text-anchor="middle">Vault: ', vaultAddr.toHexString(), '</text>',
            '</svg>'
        );

        console.log("=== RAW SVG (paste into svgviewer.dev) ===");
        console.log(string(svg));

        console.log("=== FULL TOKEN URI (paste into browser address bar) ===");
        console.log(vNFT.tokenURI(1));
    }
}