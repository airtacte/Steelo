const ethers = require("ethers");
const { contractInstance } = require("./blockchainUtils");

async function transferToken(to, amount) {
  // Transfer tokens to another address
  const tx = await contractInstance.transfer(
    to,
    ethers.utils.parseEther(amount.toString())
  );
  await tx.wait();
  console.log(`Transferred ${amount} tokens to ${to}`);
}

async function mintToken(to, amount) {
  // Mint new tokens (if the contract allows minting)
  const tx = await contractInstance.mint(
    to,
    ethers.utils.parseEther(amount.toString())
  );
  await tx.wait();
  console.log(`Minted ${amount} tokens to ${to}`);
}

async function burnToken(amount) {
  // Burn tokens (if the contract allows burning)
  const tx = await contractInstance.burn(
    ethers.utils.parseEther(amount.toString())
  );
  await tx.wait();
  console.log(`Burned ${amount} tokens`);
}

module.exports = {
  transferToken,
  mintToken,
  burnToken,
};