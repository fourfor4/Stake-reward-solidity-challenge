# challenge
create and deploy (locally) an ERC20 token and a staking contract that will distribute rewards to stakers over time. No need for an app or UI. You can reuse published or open source code, but you must indicate the source and what you have modified.

## User journey
An account with some balance of the tokens can deposit them into the staking contract (which also has the tokens and distributes them over time). As the time goes by and blocks are being produced, this user should accumulate more of the tokens and can claim the rewards and withdraw the deposit.

## RewardToken.sol
this contract defines an ERC20 token that will be used for staking/rewards. The owner should be able to mint the token.

## Staker.sol
this contract will get deployed with some tokens minted for the distribution to the stakers. And then, according to a schedule, allocate the reward tokens to addresses that deposited those tokens into the contract. The schedule is up to you, but you could say that every block 100 tokens are being distributed; then you'd take the allocated tokens and divide by the total balance of the deposited tokens so each depositor get's proportional share of the rewards. Ultimately, a user will deposit some tokens and later will be able to withdraw the principal amount plus the earned rewards. The following functions must be implemented: deposit(), withdraw()

## Scoring criteria
- launch ERC20 token
- implement reward allocation logic
- safe deposit/withdraw functions (avoid common attack vectors)


## Deploy result in ropsten network
Deploying contracts with the account: 0x36615d222082A7ffF780AE4a93D72b8E344bbB92
Account balance: 992797350332357680
Token address: 0x48F4b3A7903163fd5d04B91450F01B06D8254585
Staker address: 0xA9bF4Cf53F4E08441682d62f73A24DD5E3A92761
# Stake-reward-solidity-challenge
