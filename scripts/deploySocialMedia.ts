import { ethers } from "hardhat";

const ADMIN_ADDRESS = "0x77158c23cC2D9dd3067a82E2067182C85fA3b1F6";
async function main() {
  const nftFactory = await ethers.deployContract("NFTFactory");

  await nftFactory.waitForDeployment();
  console.log(`NFT Factory contract deployed to ${nftFactory.target}`);

  const socialMedia = await ethers.deployContract("QuteeMedia", [
    ADMIN_ADDRESS,
    nftFactory.target,
  ]);

  await socialMedia.waitForDeployment();

  console.log(`Social Media contract deployed to ${socialMedia.target}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});



// npx hardhat run scripts/deploySocialMedia.ts --network sepolia

// NFT Factory contract deployed to 0x311213bB5125aA63ef65EE42e3748d67998049B7
// Social Media contract deployed to 0x30815424E049C87d5ABBB3c10C8044D04fd0e81a

// npx hardhat verify --network sepolia 0x311213bB5125aA63ef65EE42e3748d67998049B7 


// npx hardhat verify --network sepolia 0x30815424E049C87d5ABBB3c10C8044D04fd0e81a  0x77158c23cC2D9dd3067a82E2067182C85fA3b1F6 0x311213bB5125aA63ef65EE42e3748d67998049B7