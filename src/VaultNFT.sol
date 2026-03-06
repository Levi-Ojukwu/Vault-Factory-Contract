// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.6.0
pragma solidity ^0.8.27;

// import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract VaultNFT is ERC721, ERC721URIStorage {
    error NotFactory();

    using Strings for uint256;
    using Strings for address;

    uint256 private _nextTokenId;

    // Only the factory can mint NFTs
    address public immutable factory;

    modifier onlyFactory() {
        if (msg.sender != factory) {
            revert NotFactory();
        }
        _;
    }

    constructor(address _factory)
        ERC721("VaultNFT", "VFT")
    {
        factory = _factory;
    }


    function generateCharacter(
        address vaultAddress,
        string memory tokenName,
        string memory tokenSymbol,
        uint256 amountDeposited,
        uint256 creationTime
    ) public pure returns (string memory) {
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            '<style>.base { fill: white; font-family: serif; font-size: 12px; }</style>',
            '<rect width="100%" height="100%" fill="#1a1a2e" />',
            '<text x="50%" y="20%" class="base" dominant-baseline="middle" text-anchor="middle" font-size="18px">🏦 Vault NFT</text>',
            '<text x="50%" y="35%" class="base" dominant-baseline="middle" text-anchor="middle">Token: ', tokenName, ' (', tokenSymbol, ')</text>',
            '<text x="50%" y="48%" class="base" dominant-baseline="middle" text-anchor="middle">Deposited: ', amountDeposited.toString(), '</text>',
            '<text x="50%" y="61%" class="base" dominant-baseline="middle" text-anchor="middle">Created: ', creationTime.toString(), '</text>',
            '<text x="50%" y="74%" class="base" dominant-baseline="middle" text-anchor="middle" font-size="9px">Vault: ', Strings.toHexString(uint160(vaultAddress), 20), '</text>',
            '</svg>'
        );

        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)
            )
        );
    }

    function getTokenURI(
        uint256 tokenId,
        address vaultAddress,
        string memory tokenName,
        string memory tokenSymbol,
        uint256 amountDeposited,
        uint256 creationTime
    ) public pure returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "VaultNFT #', tokenId.toString(), '",',
                '"description": "On-chain Vault NFT showing vault details",',
                '"image": "', generateCharacter(vaultAddress, tokenName, tokenSymbol, amountDeposited, creationTime), '"',
            '}'
        );

        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }

    // called by factory when a new vault is created
    function mint(
        address to,
        address vaultAddress,
        string memory tokenName,
        string memory tokenSymbol,
        uint256 amountDeposited,
        uint256 creationTime
    ) external onlyFactory returns (uint256) {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(
            tokenId,
            getTokenURI(tokenId, vaultAddress, tokenName, tokenSymbol, amountDeposited, creationTime)
        );
        return tokenId;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}