// import Chai to use its asserting functions here.
const { expect } = require("chai");
const { deployContract } = require("ethereum-waffle");

// `describe` is a Mocha function that allows you to organize your tests. It's
// not actually needed, but having your tests organized makes debugging them
// easier. All Mocha functions are available in the global scope.

// `describe` receives the name of a section of your test suite, and a callback.
// The callback must define the tests of that section. This callback can't be
// an async function.
describe("Staking...", function () {
  // Mocha has four functions that let you hook into the the test runner's
  // lifecyle. These are: `before`, `beforeEach`, `after`, `afterEach`.
  let Token;
  let rwToken;
  let StakerContract;
  let staker;
  let owner;
  let addr1;
  let addr2;

  // `beforeEach` will run before each test, re-deploying the contract every
  // time. It receives a callback, which can be async.
  beforeEach(async function () {
    // Get the ContractFactory and Signers here.
    Token = await ethers.getContractFactory("RewardToken");
    StakerContract = await ethers.getContractFactory("Staker");

    // get accounts.
    [owner, addr1, addr2] = await ethers.getSigners();

    // deploy reward token.
    rwToken = await Token.deploy();

    staker = await StakerContract.deploy(rwToken.address);
  });

  describe("Deployment", function() {
    it("Should set the right owner of token", async function () {
      expect(await rwToken.owner()).to.equal(owner.address);
    });
    it("Should assign the total supply of tokens to the owner", async function () {
      const ownerBalance = await rwToken.balanceOf(owner.address);
      expect(await rwToken.totalSupply()).to.equal(ownerBalance);  
    });
    it("Should set the right owner of stake contract", async function () {
      expect(await staker.owner()).to.equal(owner.address);
    });
  });

  describe("Reward Token modify", function() {
    it("Only owner can change rewardRate", async function () {
      await rwToken.connect(owner).changeRewardRate(10);
      expect(await rwToken.getRewardRate()).to.equal(10);
    });
    // it("Other account can not change rewardRate", async function () {
    //   rwToken.connect(addr1).changeRewardRate(10).catch(err => {
    //     console.log(err.message);
    //   });
    // });
  });

  describe("Stake Transaction", function() {
    it("Deposit & Withdraw", async function() {
      // init users wallet
      await rwToken.connect(owner).transfer(addr1.address, 50_000_000);
      await rwToken.connect(owner).transfer(addr2.address, 50_000_000);

      // add1 deposit to staking pool
      await rwToken.connect(addr1).approve(staker.address, 5_000_000)
      await staker.connect(addr1).deposit(5_000_000);
      expect(await staker.getBalanceOf(addr1.address)).to.equal(5_000_000);

      // add2 deposit to staking pool
      await rwToken.connect(addr2).approve(staker.address, 10_000_000)
      await staker.connect(addr2).deposit(10_000_000);
      expect(await staker.getBalanceOf(addr2.address)).to.equal(10_000_000);
      expect(await staker.getRewardsOf(addr2.address)).to.equal(0);

      // add1 withdraw from staking pool
      await staker.connect(addr1).withdraw(5_000_000);
      expect(await staker.getBalanceOf(addr1.address)).to.equal(0);
    });
  });
});