// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MBPN is ERC721, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    IERC20 _payToken;
    uint256 _cost;
    string private _baseTokenURI;


    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor(address _tokenAddress, uint256 _price, string memory baseTokenURI) ERC721("MadBackPackNFT", "MBPN") {
        _payToken = IERC20(_tokenAddress);
        _cost = _price;
        _baseTokenURI = baseTokenURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }
    
    /**
     * @dev Mint with provided IERC20 token and price which was specified during deploy
     */
    function safeMint(address to) public {
         _payToken.transferFrom(msg.sender, address(this), _cost);
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    /**
     * @dev simple mint for toker owner
     */
    function safeSelfMint(address to) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }
}