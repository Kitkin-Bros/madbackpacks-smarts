// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "../contracts/White.sol";

contract WWMBToken is BEP20TokenWhitelisted {

    constructor() {
        _name = "WWMBToken";
        _symbol = "WWMB";
        _decimals = 18;
        _totalSupply = 1000000 * 10 ** 18;
        _balances[_msgSender()] = _totalSupply;
        
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }
    
}