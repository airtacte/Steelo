import { useState, useEffect } from "react";
import { ethers } from "ethers";
// Import ABI Code to interact with smart contract
import Greeter from "./artifacts/contracts/Greeter.sol/Greeter.json";
import Diamond from "./artifacts/steeloDiamond.json";

import "./App.css";

// The contract address
const greeterAddress = "0xc9413f85CD3A32A66a8B4642737A64584727Ce3c";
const diamondAddress = "0xaC70A90277A2c480BDbFB3541A550Ff4D48a177e";

function App() {
  // Property Variables

  const [name, setName] = useState("");
  const [symbol, setSymbol] = useState("");
  const [totalSupply, setTotalSupply] = useState(0);
  const [totalTokens, setTotalTokens] = useState(0);
  const [balance, setBalance] = useState(0);
  const [balanceEther, setBalanceEther] = useState(0);
  const [myAccount, setMyAccount] = useState("0x0");
  const [addressTo, setAddressTo] = useState("0x0");
  const [amountToTransfer, setAmountToTransfer] = useState(0);
  const [addressToApprove, setAddressToApprove] = useState("0x0");
  const [amountToApprove, setAmountToApprove] = useState(0);
  const [allowance, setAllowance] = useState(0);
  const [addressToTransferFrom, setAddressToTransferFrom] = useState("0x0");
  const [addressToTransferTo, setAddressToTransferTo] = useState("0x0");
  const [amountToTransferBetween, setAmountToTransferBetween] = useState(0);
  const [change, setChange] = useState(0);
  const [burnAmount, setBurnAmount] = useState(0);
  const [mintAmount, setMintAmount] = useState(0);
  const [buyingEther, setBuyingEther] = useState(0);
  const [steeloAmount, setSteeloAmount] = useState(0);
  const [creatorName, setCreatorName] = useState("");
  const [creatorSymbol, setCreatorSymbol] = useState("");
  const [creatorAddress, setCreatorAddress] = useState("0x0");
  const [steezTotalSupply, setSteezTotalSupply] = useState(0);
  const [steezCurrentPrice, setSteezCurrentPrice] = useState(0);
  const [steezInvested, setSteezInvested] = useState(0);
  const [auctionStartTime, setauctionStartTime] = useState(0);
  const [auctionAnniversary, setauctionAnniversary] = useState(0);
  const [auctionConcluded, setAuctionConlcuded] = useState(false);
  const [preOrderStartTime, setPreOrderStartTime] = useState(0);
  const [liquidityPool, setLiquidityPool] = useState(0);
  const [preOrderStarted, setPreOrderStarted] = useState(false);
  const [bidAmount, setBidAmount] = useState(0);
  const [auctionSecured, setAuctionSecured] = useState(0);
  const [totalSteeloPreOrder, setTotalSteeloPreOrder] = useState(0);
  const [investorLength, setInvestorLength] = useState(0);
  const [timeInvested, setTimeInvested] = useState(0);
  const [investorAddress, setInvestorAddress] = useState(0);
  const [creatorId, setCreatorId] = useState(0);
  const [creatorIdBid, setCreatorIdBid] = useState(0);
  const [biddingAmount, setBiddingAmount] = useState(0);
  const [answer, setAnswer] = useState(false);
  const [totalTransactionCount, setTotalTransactionCount] = useState(0);
  const [lowestBid, setLowestBid] = useState(0);
  const [highestBid, setHighestBid] = useState(0);


  async function requestAccount() {
    await window.ethereum.request({ method: "eth_requestAccounts" });
  }

  async function fetchDiamond() {
    if (typeof window.ethereum !== "undefined") {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(
        diamondAddress,
        Diamond.abi,
        signer
      );
	const signerAddress = await signer.getAddress();
    	let etherBalance = await  provider.getBalance(signerAddress);
	etherBalance = await ethers.utils.formatEther(etherBalance);
	setBalanceEther(etherBalance);
      try {
	
	setMyAccount(signerAddress);
//        await contract.initialize(); 
	const authors = await contract.authors();
	console.log("authors :", authors);
	const name = await contract.steeloName();
	console.log("name :", name);
//	await contract.steeloInitiate();
	
	
      } catch (error) {
        console.log("Error: ", error);
      }
    }
  }


	useEffect(() => {
    fetchDiamond();
    document.title = "Steelo Test Blockchain"
  }, [change]);

   // Return
  return (
    <div className="App">
     
    </div>
  );
}

export default App;
