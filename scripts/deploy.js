async function main() {
	const [deployer] = await ethers.getSigners();

	console.log("Deploying contracts with the account:", deployer.address);

	console.log("Account balance:", (await deployer.getBalance()).toString());

	const Token = await ethers.getContractFactory("RewardToken");
	const token = await Token.deploy();

	console.log("Token address:", token.address);

	const Staker = await ethers.getContractFactory("Staker");
	const staker = await Staker.deploy(token.address);

	console.log("Staker address:", staker.address);
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});