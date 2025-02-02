// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract MultiToken is ERC1155, ERC1155URIStorage, ERC1155Supply, Ownable {
    mapping(uint256 => uint256) public tokenPrices;
    mapping(uint256 => uint256) public maxSupply;
    
    constructor(string memory uri) ERC1155(uri) Ownable(msg.sender) {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function setTokenPrice(uint256 id, uint256 price) public onlyOwner {
        tokenPrices[id] = price;
    }

    function setMaxSupply(uint256 id, uint256 supply) public onlyOwner {
        maxSupply[id] = supply;
    }

    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public payable {
        require(msg.value >= tokenPrices[id] * amount, "Insufficient payment");
        require(
            maxSupply[id] == 0 || totalSupply(id) + amount <= maxSupply[id],
            "Max supply exceeded"
        );
        _mint(account, id, amount, data);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyOwner {
        _mintBatch(to, ids, amounts, data);
    }

    function withdraw() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    // Override required functions
    function _update(address from, address to, uint256[] memory ids, uint256[] memory values)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._update(from, to, ids, values);
    }

    function uri(uint256 tokenId)
        public
        view
        override(ERC1155, ERC1155URIStorage)
        returns (string memory)
    {
        return super.uri(tokenId);
    }
}