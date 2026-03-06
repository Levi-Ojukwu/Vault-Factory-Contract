// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract VaultNFT is ERC721 {
    using Strings for uint256;
    using Strings for address;

    error NotFactory();

    uint256 public tokenId;
    address public immutable factory;

    struct VaultData {
        address token;
        address vault;
    }

    mapping(uint256 => VaultData) public vaultData;

    modifier onlyFactory() {
        if (msg.sender != factory) revert NotFactory();
        _;
    }

    constructor(address _factory) ERC721("Vault NFT", "VNFT") {
        factory = _factory;
    }

    function mint(address to, address token, address vault) external onlyFactory {
        tokenId++;

        _mint(to, tokenId);

        vaultData[tokenId] = VaultData(token, vault);
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        VaultData memory data = vaultData[id];
        
        uint256 balance = IERC20(data.token).balanceOf(data.vault);

        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 350 350">',
            '<rect width="100%" height="100%" fill="#1a1a2e"/>',
            '<text x="50%" y="30%" fill="white" font-family="serif" font-size="18" text-anchor="middle">Vault NFT #', id.toString(), '</text>',
            '<text x="50%" y="50%" fill="white" font-family="serif" font-size="11" text-anchor="middle">Balance: ', balance.toString(), '</text>',
            '<text x="50%" y="70%" fill="white" font-family="serif" font-size="9" text-anchor="middle">Vault: ', data.vault.toHexString(), '</text>',
            '</svg>'
        );

        bytes memory json = abi.encodePacked(
            '{"name":"Vault NFT #', id.toString(), '",',
            '"description":"On-chain Vault NFT",',
            '"image":"data:image/svg+xml;base64,', Base64.encode(svg), '"}'
        );

        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(json)));
    }
}