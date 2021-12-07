// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RewardToken is ERC20, Ownable {

  // Default reward rate is 5.
  uint256 public rewardRate = 5;

  // Default enableWithdrawFee is false.
  bool private _enableWithdrawFee = false;

  // Default withdrawFee unit is 2%.
  uint256 private _withdrawFee = 2;

  // change reward rate event
  event ChangeRewardRateEvent(address indexed owner, uint256 indexed oldRate, uint256 indexed newRate);

  // change enable/disable withdraw fee event
  event ChangeEnableWithdrawFee(address indexed owner, bool indexed newState);

  // change withdraw fee event
  event ChangeWithdrawFee(address indexed owner, uint256 indexed oldFee, uint256 indexed newFee);

  /*
  ** Reward Token
  ** Name: Antonio Token
  ** Symbol: ATO
  ** Init Mint 100 ether
  */
  constructor() ERC20("Antonio Token", "ATO") {
    _mint(msg.sender, 100_000_000 * 10**18);
  }

  // Only owner can mint this token
  function mint(uint256 amount_) public onlyOwner {
    _mint(msg.sender, amount_);
  }

  // Only owner can change the reward rate for this token.
  function changeRewardRate(uint256 rewardRate_) public onlyOwner {
    emit ChangeRewardRateEvent(owner(), rewardRate, rewardRate_);
    rewardRate = rewardRate_;
  }

  // get reward per block
  function getRewardRate() public view returns (uint256) {
    return rewardRate;
  }


  // Only owner can change enable or disable of withdraw fee.
  function changeEnableWithdrawFee() public onlyOwner {
    _enableWithdrawFee = !_enableWithdrawFee;
    emit ChangeEnableWithdrawFee(owner(), _enableWithdrawFee);
  }

  // Only owner can change withdraw fee.
  function changeWithdrawFee(uint256 withdrawFee_) public onlyOwner {
    emit ChangeWithdrawFee(owner(), _withdrawFee, withdrawFee_);
    _withdrawFee = withdrawFee_;
  }
  
  // withdraw Fee
  function withdrawFee() public view returns(uint256) {
    return _enableWithdrawFee ? _withdrawFee : 0;
  }
}