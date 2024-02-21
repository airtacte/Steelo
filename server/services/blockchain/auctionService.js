const ethers = require('ethers');
const { contractInstance } = require('./blockchainUtils');

// Assuming contractInstance is an initialized ethers Contract instance
// with methods corresponding to the smart contract

async function initiateAuction(tokenId, startingBid, bidIncrement) {
  // Start a new auction for a creator token
  const tx = await contractInstance.initiateAuction(tokenId, ethers.utils.parseEther(startingBid.toString()), ethers.utils.parseEther(bidIncrement.toString()));
  await tx.wait();
  console.log(`Auction initiated for token ID ${tokenId}`);
}

async function placeBid(auctionId, bidAmount) {
  // Place a bid in an existing auction
  const tx = await contractInstance.placeBid(auctionId, { value: ethers.utils.parseEther(bidAmount.toString()) });
  await tx.wait();
  console.log(`Bid placed in auction ID ${auctionId}`);
}

async function fetchAuctionDetails(auctionId) {
  // Fetch details of a specific auction
  const auctionDetails = await contractInstance.auctions(auctionId);
  return {
    startingBid: ethers.utils.formatEther(auctionDetails.startingBid),
    bidIncrement: ethers.utils.formatEther(auctionDetails.bidIncrement),
    highestBid: ethers.utils.formatEther(auctionDetails.highestBid),
    highestBidder: auctionDetails.highestBidder
  };
}

module.exports = {
  initiateAuction,
  placeBid,
  fetchAuctionDetails
};