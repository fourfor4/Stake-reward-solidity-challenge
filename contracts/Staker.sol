// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import "@openzeppelin/contracts/utils/Address.sol";
import 'hardhat/console.sol';
import "./RewardToken.sol";

// interface of rewardToken
interface IRewardToken is IERC20 {
  function owner() external view returns (address);
  function deposit() external payable;
  function withdraw(uint256) external;
	function getRewardRate() external view returns (uint256);
  function withdrawFee() external view returns (uint256);
}

library SafeRewardToken {
	using Address for address;

	function safeTransfer(
		IRewardToken token,
		address to,
		uint256 value
	) internal {
		_callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
	}

  function safeTransferFrom(
    IRewardToken token,
    address from,
    address to,
    uint256 value
  ) internal {
      _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
  }

	function _callOptionalReturn(IRewardToken token, bytes memory data) private {
		bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
		if (returndata.length > 0) {
			// Return data is optional
			require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
		}
	}
}

contract Staker is Ownable {
  using SafeMath for uint256;
  using SafeRewardToken for IRewardToken;

  IRewardToken public rewardsToken;

  uint public lastUpdateTime;
  uint public rewardPerTokenStored;

  mapping(address => uint) public userRewardPerTokenPaid;
  mapping(address => uint) private rewards;

  uint private _totalSupply;
  mapping(address => uint) private _balances;
  mapping(address => uint) private _endBlock;

  event RewardUpdated(address account, uint rewards, uint rewardPerTokenStored, uint lastUpdateTime);
  event Deposit(address account, uint amount, uint amountSoFar);
  event Withdraw(address account, uint amount, uint amountRemaining);
  event ClaimReward(address account, uint amount);

  constructor(address _rewardsToken) {
    rewardsToken = IRewardToken(_rewardsToken);
  }

  function getBalanceOf(address account) public view returns (uint256 _balance) {
    return _balances[account];
  }

  function getRewardsOf(address account) public view returns (uint256 _balance) {
    return rewards[account];
  }

  function getRewardToken() public view returns (address _address)  {
    return address(rewardsToken);
  }

  function rewardPerToken() public view returns (uint) {
    if (_totalSupply == 0) {
      return 0;
    }

    uint256 reward_value = 0;
    uint256 rewardRate = rewardsToken.getRewardRate();
    reward_value = rewardPerTokenStored.add((((block.timestamp.sub(lastUpdateTime)).mul(rewardRate).mul(1e18)).div(_totalSupply)));

    return reward_value;
  }

  function earned(address account) public view returns (uint) {
    return ((_balances[account].mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))).div(1e18)).add(rewards[account]);
  }

  modifier updateReward(address account) {
    rewardPerTokenStored = rewardPerToken();
    lastUpdateTime = block.timestamp;

    rewards[account] = earned(account);
    userRewardPerTokenPaid[account] = rewardPerTokenStored;

    emit RewardUpdated(account, rewards[account], rewardPerTokenStored, lastUpdateTime);
    _;
  }

  function deposit(uint256 _amount) external  updateReward(msg.sender) {
    require( msg.sender.balance >= _amount + 23000, "Insufficient amount");
    require( block.number >= _endBlock[msg.sender], "Too Early");

    _totalSupply = _totalSupply.add(_amount);
    _balances[msg.sender] = _balances[msg.sender].add(_amount);
    _endBlock[msg.sender] = block.number;

    rewardsToken.transferFrom(msg.sender, address(this), _amount);
    
    emit Deposit(msg.sender, _amount, _balances[msg.sender]);
  }

  // withdraw
  function withdraw(uint _amount) external updateReward(msg.sender) {
    require(_balances[msg.sender] >= _amount, "Over the limit");
    require(rewardsToken.balanceOf(address(this)) >= _amount, "Insufficient amount");
    require( block.number >= _endBlock[msg.sender], "Too Early");

    uint realAmount = _amount;
    realAmount = _amount.mul(100 - rewardsToken.withdrawFee()).div(100);

    rewardsToken.transfer(msg.sender, realAmount);

    _totalSupply = _totalSupply.sub(realAmount);
    _balances[msg.sender] = _balances[msg.sender].sub(_amount);
    emit Withdraw(msg.sender, _amount, _balances[msg.sender]);
    if (rewards[msg.sender] > 0) {
      uint reward = rewards[msg.sender];
      rewards[msg.sender] = 0;
      rewardsToken.transfer(msg.sender, reward);
      emit ClaimReward(msg.sender, reward);
    }
  }
}