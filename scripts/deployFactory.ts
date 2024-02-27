import { ethers } from "hardhat";

async function main() {
  const nftFactory = await ethers.deployContract("NFTFactory");

  await nftFactory.waitForDeployment();
  console.log(`NFT Factory contract deployed to ${nftFactory.target}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
