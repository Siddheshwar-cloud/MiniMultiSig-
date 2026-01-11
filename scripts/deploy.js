const hre = require("hardhat");

async function main() {
    const [deployer] = await hre.ethers.getSigners();

    console.log("Deploying Multisig with the account:", deployer.address);

    const Multisig = await hre.ethers.getContractFactory("MiniMultiSig");

    const owner = [
        "0x1234567890abcdef1234567890abcdef12345678",
        "0xabcdef1234567890abcdef1234567890abcdef12",

    ];

    const requiredApprovals = 2;

    const multisig = await Multisig.deploy
        (owner, requiredApprovals);

    await multisig.waitForDeployment();

    console.log("Multisig deployed to:", await multisig.target);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

