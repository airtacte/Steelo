const ethers = require("ethers");
const { contractInstance } = require("./blockchainUtils");

async function createProposal(description) {
  // Create a new governance proposal
  const tx = await contractInstance.createProposal(description);
  await tx.wait();
  console.log(`Proposal created: ${description}`);
}

async function castVote(proposalId, vote) {
  // Cast a vote on a governance proposal
  const tx = await contractInstance.castVote(proposalId, vote);
  await tx.wait();
  console.log(`Vote cast on proposal ID ${proposalId}`);
}

async function fetchProposal(proposalId) {
  // Fetch details of a specific proposal
  const proposal = await contractInstance.proposals(proposalId);
  return {
    description: proposal.description,
    yesVotes: proposal.yesVotes,
    noVotes: proposal.noVotes,
    executed: proposal.executed,
  };
}

module.exports = {
  createProposal,
  castVote,
  fetchProposal,
};