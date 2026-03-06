// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Vault} from "./Vault.sol";
import {VaultNFT} from "./VaultNFT.sol";

contract VaultFactory {
    VaultNFT public immutable nft;

    mapping(address => address) public vaultOf;

    event VaultCreated(address indexed token, address indexed vault);

    constructor() {
        nft = new VaultNFT(address(this));
    }

    function createVault(address token) external returns (address vault) {
        require(vaultOf[token] == address(0), "Vault exists");

        bytes32 salt = keccak256(abi.encode(token));
        
        bytes memory bytecode = abi.encodePacked(
            type(Vault).creationCode,
            abi.encode(token, address(this))
        );

        assembly {
            vault := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
            if iszero(extcodesize(vault)) { revert(0, 0) }
        }

        vaultOf[token] = vault;

        nft.mint(msg.sender, token, vault);

        emit VaultCreated(token, vault);
    }

    function computeVaultAddress(address token) public view returns (address) {
        bytes32 salt = keccak256(abi.encode(token));

        bytes32 hash = keccak256(abi.encodePacked(
            bytes1(0xff),
            address(this),
            salt,
            keccak256(abi.encodePacked(
                type(Vault).creationCode,
                abi.encode(token, address(this))
            ))
        ));

        return address(uint160(uint256(hash)));
    }
}