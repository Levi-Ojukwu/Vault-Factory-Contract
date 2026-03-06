// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Vault} from "./Vault.sol";
import {VaultNFT} from "./VaultNFT.sol";

contract VaultFactory {

    mapping(address => address) public vaultOf;

    VaultNFT public immutable nft;

    event VaultCreated(address indexed token, address indexed vault);

    constructor(address _nft) {
        nft = VaultNFT(_nft);
    }

    function createVault(address _token) external returns (address vault) {
        require(vaultOf[_token] == address(0), "Vault already exists");

        bytes32 salt = keccak256(abi.encodePacked(_token));

        bytes memory bytecode = abi.encodePacked(
            type(Vault).creationCode,
            abi.encode(_token, address(this))
        );

        assembly {
            vault := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
            if iszero(extcodesize(vault)) {
                revert(0, 0)
            }
        }

        vaultOf[_token] = vault;

        nft.mint(msg.sender, vault);

        emit VaultCreated(_token, vault);
    }

    function computeVaultAddress(address _token) public view returns (address) {
        bytes32 salt = keccak256(abi.encodePacked(_token));
        bytes memory bytecode = abi.encodePacked(
            type(Vault).creationCode,
            abi.encode(_token, address(this))
        );
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                salt,
                keccak256(bytecode)
            )
        );
        return address(uint160(uint(hash)));
    }
}