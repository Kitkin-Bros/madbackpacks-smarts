// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract WWMBPStack is Ownable {
    // Token used for staking
    ERC20 stakingToken;
    uint256 private _totalSupply;
    uint256 private _totalRewardSupply;
    uint256 private _rewardPercent = 1;
    uint256 private _defaultReleaseTimeDays = 0;
    uint256 private _standardReleaseTime = 3600 * _defaultReleaseTimeDays * 1e18;

    event AddStaking(address owner, uint256 amount, uint256 releaseTime);
    event WithdrawStaking(address owner, uint256 amount, uint256 burnAmount);

    struct Stake {
        uint256 releaseTime;
        uint256 amount;
        bool exists;
    }

    mapping (address => Stake) private stakes;
    mapping (address => bool) private stakesInserted;
    mapping (address => uint256) private _rewards;

    address[] private stakeHolders;


    /**
    * @dev Modifier that checks that this contract can transfer tokens from the
    *  balance in the stakingToken contract for the given address.
    */
    modifier canTransfer(address _address, uint256 _amount) {
        require(
        stakingToken.transferFrom(_address, address(this), _amount),
        "Stake required");
        _;
    }

    /**
    * @dev Constructor function
    * @param _stakingToken ERC20 The address of the token contract used for staking
    */
    constructor(ERC20 _stakingToken, address _ownerAddress){
        stakingToken = _stakingToken;
        _transferOwnership(_ownerAddress);
    }

    function createStake(
        address _address,
        uint256 _amount
      )
        internal
        canTransfer(msg.sender, _amount)
      {
        require(_amount > 0, "amount not valid");
        Stake storage _stake = stakes[_address];
        if(!stakesInserted[_address]){
            stakesInserted[_address] = true;
            stakeHolders.push(_address);
        }

        if(_defaultReleaseTimeDays > 0){
            _stake.releaseTime = _defaultReleaseTimeDays;
        }
        _totalSupply += _amount;
        _stake.amount += _amount;
        emit AddStaking(_address, _amount, _defaultReleaseTimeDays);
      }


    function stake(
        uint256 _amount
    ) external {
        createStake(msg.sender, _amount);
    }

    function stakeFor(
        address _address,
        uint256 _amount
    ) external  {
        createStake(_address, _amount);
    }

    function unStake(
        uint256 _amount
    ) external {
        uint256 burnAmount;
        require(_amount > 0, "greater than zero");
        Stake storage _stake = stakes[msg.sender];
        require(_amount <= _stake.amount, "balance low");
        require(_stake.releaseTime < block.timestamp, "token locked");
        require(stakingToken.transfer(msg.sender, _amount),
            "not transfered");
        _stake.amount -= _amount;
        _totalSupply -= _amount;
        emit WithdrawStaking(msg.sender, _amount, burnAmount);
    }

    /**
    * @notice A method to distribute rewards to all stakeholders.
    */
   function distributeRewards()
       public
       onlyOwner
   {
       for (uint256 s = 0; s < stakeHolders.length; s += 1){
           address stakeholder = stakeHolders[s];
           uint256 reward = calculateReward(stakeholder);
           _rewards[stakeholder] = SafeMath.add(_rewards[stakeholder], reward);
       }
   }

   /**
    * @notice A simple method that calculates the rewards for each stakeholder.
    * @param _stakeholder The stakeholder to calculate rewards for.
    */
   function calculateReward(address _stakeholder)
       public
       view
       returns(uint256)
   {
       return SafeMath.mul(SafeMath.div(stakes[_stakeholder].amount, 100), _rewardPercent);
   }

    function claimReward() external {
        require(_rewards[msg.sender] > 0, "no reward for claim");
        require(
            stakingToken.transfer(msg.sender, _rewards[msg.sender]),
            "reward transfer failed");
        _rewards[msg.sender] = 0;
    }

    function rewardOf(address account) public view virtual returns (uint256) {
        return _rewards[account];
    }

    function stakeBalanceOf(address account) public view virtual returns (uint256) {
        Stake memory _stake = stakes[account];
        return _stake.amount;
    }
    
    function rewardPercent() public view virtual returns (uint256) {
        return _rewardPercent;
    }

        
    function defaulReleaseTimeDays() public view virtual returns (uint256) {
        return _defaultReleaseTimeDays;
    }

    function setRewardsPercent(uint _percent) external onlyOwner {
        require(_percent > 0, "percent must be non zero");
        _rewardPercent = _percent;
    }

    
    function setDefaultReleaseDays(uint _days) external onlyOwner {
        require(_days > 0, "percent must be non zero");
        _defaultReleaseTimeDays = _days;
    }

    /**
    * @notice A method to the aggregated rewards from all stakeholders.
    * @return uint256 The aggregated rewards from all stakeholders.
    */
   function totalRewards()
       public
       view
       returns(uint256)
   {
       uint256 _totalRewards = 0;
       for (uint256 s = 0; s < stakeHolders.length; s += 1){
           _totalRewards = SafeMath.add(_totalRewards, _rewards[stakeHolders[s]]);
       }
       return _totalRewards;
   }


}