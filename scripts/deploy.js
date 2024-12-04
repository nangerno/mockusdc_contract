async function main() {
    // Get the contract factory
    const ContractFactory = await hre.ethers.getContractFactory("MockUSDC");

    // Deploy the contract
    const contract = await ContractFactory.deploy(1000000 * 10 ** 6);

    // Wait for the deployment transaction to be mined
    await contract.waitForDeployment();

    // Log the deployed address
    console.log(`Deployed address: ${await contract.getAddress()}`);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });

