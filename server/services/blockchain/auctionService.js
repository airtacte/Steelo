const ethers = require('ethers');
const { contractInstance } = require('./blockchainUtils');

// This service assumes that contractInstance is already set up to interact with the smart contract.
// The contractInstance should be initialized with the ABI and address of the deployed Auction contract.

async function initiateAuction(tokenId, startingBid, bidIncrement, duration) {
  // Convert Ether values to Wei
  const formattedStartingBid = ethers.utils.parseEther(startingBid.toString());
  const formattedBidIncrement = ethers.utils.parseEther(bidIncrement.toString());
  
  // Start a new auction for a creator token
  const tx = await contractInstance.initiateAuction(tokenId, formattedStartingBid, formattedBidIncrement, duration);
  const receipt = await tx.wait();
  
  // Emit an event or log for successful auction initiation
  console.log(`Auction initiated for token ID ${tokenId} with transaction receipt:`, receipt);
}

async function placeBid(auctionId, bidAmount) {
  // Convert Ether value to Wei for the bid
  const formattedBidAmount = ethers.utils.parseEther(bidAmount.toString());

  // Place a bid in an existing auction
  const tx = await contractInstance.placeBid(auctionId, { value: formattedBidAmount });
  const receipt = await tx.wait();

  // Emit an event or log for successful bid placement
  console.log(`Bid placed in auction ID ${auctionId} with transaction receipt:`, receipt);
}

async function fetchAuctionDetails(auctionId) {
  // Fetch details of a specific auction
  const auctionDetails = await contractInstance.fetchAuctionDetails(auctionId);
  
  // Format values from Wei to Ether for readability
  return {
    startingBid: ethers.utils.formatEther(auctionDetails.startingBid),
    bidIncrement: ethers.utils.formatEther(auctionDetails.bidIncrement),
    highestBid: ethers.utils.formatEther(auctionDetails.highestBid),
    highestBidder: auctionDetails.highestBidder,
    endTime: new Date(auctionDetails.endTime * 1000) // Convert timestamp to Date
  };
}

async function finalizeAuction(auctionId) {
  // Finalize an auction, distributing funds and transferring ownership of the token
  const tx = await contractInstance.finalizeAuction(auctionId);
  const receipt = await tx.wait();
  
  // Emit an event or log for successful auction finalization
  console.log(`Auction ID ${auctionId} finalized with transaction receipt:`, receipt);
}

module.exports = {
initiateAuction,
placeBid,
fetchAuctionDetails,
finalizeAuction
};