// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
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

    uint256 balance = IERC20Metadata(data.token).balanceOf(data.vault);
    string memory tokenName = IERC20Metadata(data.token).name();
    string memory tokenSymbol = IERC20Metadata(data.token).symbol();

    bytes memory svg = abi.encodePacked(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 240">',

        // — Definitions: gradient + glow filter —
        '<defs>',
          '<linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">',
            '<stop offset="0%" style="stop-color:#0f0c29"/>',
            '<stop offset="50%" style="stop-color:#302b63"/>',
            '<stop offset="100%" style="stop-color:#24243e"/>',
          '</linearGradient>',
          '<linearGradient id="card" x1="0%" y1="0%" x2="100%" y2="100%">',
            '<stop offset="0%" style="stop-color:#1a1a3e;stop-opacity:1"/>',
            '<stop offset="100%" style="stop-color:#2d2b55;stop-opacity:1"/>',
          '</linearGradient>',
          '<filter id="glow">',
            '<feGaussianBlur stdDeviation="3" result="blur"/>',
            '<feMerge><feMergeNode in="blur"/><feMergeNode in="SourceGraphic"/></feMerge>',
          '</filter>',
        '</defs>',

        // — Background —
        '<rect width="400" height="240" fill="url(#bg)"/>',

        // — Decorative blurred circles —
        '<circle cx="340" cy="40" r="60" fill="#7b5ea7" opacity="0.15"/>',
        '<circle cx="60" cy="200" r="80" fill="#4a90d9" opacity="0.1"/>',

        // — Card —
        '<rect x="20" y="20" width="360" height="200" rx="16" ry="16" fill="url(#card)" stroke="#ffffff18" stroke-width="1"/>',

        // — Top accent line —
        '<rect x="20" y="20" width="360" height="3" rx="2" fill="#7b5ea7"/>',

        // — VAULT NFT label (top left) —
        '<text x="40" y="58" font-family="Georgia, serif" font-size="11" fill="#9b8ec4" letter-spacing="3">The Coding Chef</text>',

        // — Token ID (top right) —
        // '<text x="360" y="58" font-family="Georgia, serif" font-size="11" fill="#9b8ec4" text-anchor="end">#', id.toString(), '</text>',

        // — Divider —
        '<line x1="40" y1="68" x2="360" y2="68" stroke="#ffffff12" stroke-width="1"/>',

        // — Token name (large) —
        '<text x="40" y="108" font-family="Georgia, serif" font-size="28" font-weight="bold" fill="#ffffff" filter="url(#glow)">', tokenName, '</text>',

        // — Symbol badge —
        '<rect x="40" y="118" width="52" height="20" rx="10" fill="#7b5ea733"/>',
        '<text x="66" y="132" font-family="Georgia, serif" font-size="11" fill="#c4b5f4" text-anchor="middle">', tokenSymbol, '</text>',

        // — Balance label —
        '<text x="40" y="168" font-family="Georgia, serif" font-size="11" fill="#9b8ec4" letter-spacing="2">BALANCE</text>',

        // — Balance value —
        '<text x="40" y="192" font-family="Georgia, serif" font-size="22" fill="#e2d9f3">', balance.toString(), '</text>',

        // — Vault address (bottom right, small) —
        '<text x="360" y="204" font-family="monospace" font-size="7" fill="#ffffffc7" text-anchor="end">', data.vault.toHexString(), '</text>',

        '</svg>'
    );

    bytes memory json = abi.encodePacked(
        '{"name":"Vault NFT #', id.toString(), '",',
        '"description":"On-chain Vault NFT for ', tokenName, '",',
        '"image":"data:image/svg+xml;base64,', Base64.encode(svg), '"}'
    );

    return string(abi.encodePacked("data:application/json;base64,", Base64.encode(json)));
}
}