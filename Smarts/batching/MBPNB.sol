// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import './ERC721A.sol';

contract MyToken is ERC721A{
        
    string private _baseTokenURI;
    address public ownerAddress;

    constructor(string memory baseTokenURI) ERC721A("MadBackPackNFT", "MBPN") {
        _baseTokenURI = baseTokenURI;
        ownerAddress = msg.sender;
    }
    
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function mint(uint256 quantity) public onlyOwner {
        // `_mint`'s second argument now takes in a `quantity`, not a `tokenId`.
        _mint(msg.sender, quantity);
    }

    
    function mintTo(uint256 quantity, address to) public onlyOwner {
        // `_mint`'s second argument now takes in a `quantity`, not a `tokenId`.
        _mint(to, quantity);
    }

    modifier onlyOwner() {
        require(msg.sender == ownerAddress, "Only the contract owner can call this function");
        _;
    }
}