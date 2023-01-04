// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract DynamicNft is ERC721URIStorage {
    using Strings for uint;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(uint => uint) public tokenIdToLevels;

    constructor() ERC721 ("Dynamic NFT", "BTLS"){
    }

    function generateCharacter(uint tokenId) public returns (string memory){
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">', "Warrior", '</text>',
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">', "Levels: ", getLevels(tokenId), '</text>',
            '</svg>'
        );
        return string(abi.encodePacked("data:image/svg+xml;base64,", Base64.encode(svg)));
    }

    function getLevels(uint tokenId) public view returns (string memory) {
        uint levels = tokenIdToLevels[tokenId];
        return levels.toString();
    }

    function getTokenURI(uint tokenId) public returns (string memory){
        bytes memory dataURI = abi.encodePacked(
            '{',
            '"name": "Dynamic NFT #', tokenId.toString(), '",',
            '"description": "Levels can be updated",',
            '"image": "', generateCharacter(tokenId), '"',
            '}'
        );
        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(dataURI)));
    }

    function mint() public {
        _tokenIds.increment();
        uint newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        tokenIdToLevels[newItemId] = 0;
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function train(uint tokenId) public {
        require(_exists(tokenId), "Please use an existing token");
        require(ownerOf(tokenId) == msg.sender, "You must own this token to use it");
        uint currentLevel = tokenIdToLevels[tokenId];
        tokenIdToLevels[tokenId] = currentLevel + 1;
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }
}