// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract MBPVP {
    address payable public ownerAddress;

    struct Bet {
        uint256 amount;
        address payable player1;
        address payable player2;
        uint256 betId;
        bool player1Paid;
        bool player2Paid;
        bool resolved;
    }

    mapping(uint256 => Bet) public bets;
    uint256 public currentBetId = 0;

    constructor() {
        ownerAddress = payable(msg.sender);
    }

    function createBet(address payable _player1, address payable _player2, uint256 _amount) external onlyOwner returns (uint256) {
        require(_player1 != _player2, "Players must have different addresses");
        require(_player1 != address(0), "Invalid player 1 address");
        require(_player2 != address(0), "Invalid player 2 address");
        require(_amount > 0, "Bet amount must be greater than 0");

        currentBetId++;

        bets[currentBetId] = Bet(_amount, _player1, _player2, currentBetId, false, false, false);
        return currentBetId;
    }

    function makePayment(uint256 _betId) external payable {
        require(bets[_betId].betId > 0, "BetId is not exists");
        require(msg.value == bets[_betId].amount, "Incorrect amount");
        require(!bets[_betId].resolved, "Bet already resolved");

        if (msg.sender == bets[_betId].player1) {
            require(!bets[_betId].player1Paid, "Already paid");
            bets[_betId].player1Paid = true;
        } else if (msg.sender == bets[_betId].player2) {
            require(!bets[_betId].player2Paid, "Already paid");
            bets[_betId].player2Paid = true;
        } else {
            revert("Sender is not a player in this bet");
        }
        ownerAddress.transfer(msg.value);
    }

    function makeWinnerPayment(uint256 _betId, address payable _winner) external onlyOwner {
        Bet storage _bet = bets[_betId];
        require(_bet.player1Paid && _bet.player2Paid, "Both players must have paid before a winner can be chosen");
        require(!_bet.resolved, "Bet already resolved");

        _bet.resolved = true;
        _winner.transfer((bets[_betId].amount * 19) / 10);
    }

    function removeBet(uint _betId) public onlyOwner {
        require(_betId > 0, "Wrong betId");
        require(bets[_betId].resolved == true, "Bet is not resolved");

        delete bets[_betId];
    }

    function getBetStatus(uint256 _betId) public view returns (bool, bool) {
        require(_betId > 0, "Wrong betId"); 
        require(bets[_betId].betId > 0, "Bet with this id does not exists");
        return (bets[_betId].player1Paid, bets[_betId].player2Paid);
    }

    function changeOwner(address payable _newOwnerAddress) external onlyOwner {
        require(msg.sender == ownerAddress, "Only the owner can call this function");
        ownerAddress = _newOwnerAddress;
    }
    
    modifier onlyOwner() {
        require(msg.sender == ownerAddress, "Only the contract owner can call this function");
        _;
    }

}