import { useState, useEffect } from "react";
import { ethers } from "ethers";
import Greeter from "./artifacts/contracts/Greeter.sol/Greeter.json";
import Diamond from "./artifacts/steeloDiamond.json";
import "./App.css";
import Navbar from './Components/Navbar';
import Main from "./Components/Main";
import ParticleSettings from './ParticleSettings';

const diamondAddress = "0x4C1eeeb3D7E4cd3768c6d4CB8cAcA540809E29fb";

function App() {

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
        const name = await contract.steeloName();
        const creatorName = await contract.creatorTokenName();
        const creatorSymbol = await contract.creatorTokenSymbol();
        const symbol = await contract.steeloSymbol();
        const totalSupply = await contract.steeloTotalSupply();
        const totalToken = await contract.steeloTotalTokens();
        const balance = await contract.steeloBalanceOf(signerAddress);
        const creator = await contract.getAllCreator(creatorId);
        const creator2 = await contract.getAllCreator2(creatorId);
        const creator3 = await contract.getAllCreator3(creatorId);
        const creator4 = await contract.checkBidAmount(creatorId);
        const creator5 = await contract.checkInvestors(creatorId);
        const index = await contract.getPopIndex();
        const transactionCount = await contract.getTotalTransactionAmount();
	const preOrderStatus = await contract.checkPreOrderStatus(creatorId);
	const Bidders = await contract.FirstAndLast(creatorId);
        console.log("name :", name);
        console.log("symbol :", symbol);
        console.log("totalSupply :", parseInt(totalSupply, 10));
        console.log("totalToken :", parseInt(totalToken, 10));
        console.log("balance :", parseInt(balance, 10));
        console.log("Creator Name :", creatorName);
        console.log("Creator Symbol :", creatorSymbol);
	console.log("creator address :", creator[0].toString(), "total supply :",parseInt(creator[1], 10), "current price :", parseInt(creator[2], 10));
	console.log("bid Amount :", parseInt(preOrderStatus[0], 10),"steelo balance :", parseInt(preOrderStatus[1], 10),"total steelo  :", parseInt(preOrderStatus[2], 10),
		"steez invested :", parseInt(preOrderStatus[3], 10), "lqiuidity pool :", parseInt(preOrderStatus[4], 10));
	console.log("auction start time :", new Date(creator2[0].toNumber() * 1000).toString(),"auction anniversery :", new Date(creator2[1].toNumber() * 1000).toString(),"auction concluded :", creator2[2]);
	console.log("preorder start time :", new Date(creator3[0].toNumber() * 1000).toString(),"liquidity pool :", parseInt(creator3[1], 10),"preorder started :", creator3[2]);
	console.log("bid Amount :", parseInt(creator4[0], 10),"liquidity pool :", parseInt(creator4[1], 10),"auction secured :", parseInt(creator4[2]), "Total Steelo Preorder :", parseInt(creator4[3], 10)/(10 ** 18));
      console.log("investor length :", parseInt(creator5[0], 10),"steelo Invested :", parseInt(creator5[1], 10),"time invested :", parseInt(creator5[2]), "address of investor :", creator5[3].toString());
	console.log("popping index :", parseInt(index[0]), "poppin address :", index[1].toString(), "popping price :", parseInt(index[2], 10));

	console.log("transaction count :", parseInt(transactionCount, 10));
	
	setName(name);
	setSymbol(symbol);
	setTotalSupply(parseInt(totalSupply)/(10 ** 18));
	setTotalTokens(parseInt(totalToken)/(10 ** 18));
	setBalance(parseInt(balance)/(10 ** 18));
	setCreatorName(creatorName);
	setCreatorSymbol(creatorSymbol);
	setCreatorAddress(creator[0].toString());
	setSteezTotalSupply(parseInt(creator[1], 10));
	setSteezCurrentPrice(parseInt(creator[2], 10)/(10 ** 18));
	setSteezInvested(parseInt(preOrderStatus[3], 10));
	setauctionStartTime(new Date(creator2[0].toNumber() * 1000).toString());
	setauctionAnniversary(new Date(creator2[1].toNumber() * 1000).toString());	
	setAuctionConlcuded(creator2[2]);
	setPreOrderStartTime(new Date(creator3[0].toNumber() * 1000).toString());
	setLiquidityPool(parseInt(creator3[1], 10));
	setPreOrderStarted(creator3[2]);
	setBidAmount(parseInt(creator4[0], 10) / (10 ** 18));
	setAuctionSecured(parseInt(creator4[2]));
	setTotalSteeloPreOrder(parseInt(creator4[3], 10)/(10 ** 18));
	setInvestorLength(parseInt(creator5[0], 10));
	setTimeInvested(new Date(creator5[2].toNumber() * 1000).toString());
	setInvestorAddress(creator5[3].toString());
	setTotalTransactionCount(parseInt(transactionCount, 10));
	console.log("minimum allowed :", (parseInt(Bidders[1], 10) + (10 * 10 ** 18)), "minimum bid price :", parseInt(Bidders[1], 10), "highest bid :", parseInt(Bidders[2], 10));
	setHighestBid((parseInt(Bidders[1], 10) + (10 * 10 ** 18)));
	setLowestBid(parseInt(Bidders[1], 10));
	setHighestBid(parseInt(Bidders[2], 10));
	
      } catch (error) {
        console.log("Error: ", error);
      }
    }
  }

	async function initiateSteez( ) {
		if (typeof window.ethereum !== "undefined") {
      		const provider = new ethers.providers.Web3Provider(window.ethereum);
      		const signer = provider.getSigner();
      		const contract = new ethers.Contract(
        		diamondAddress,
        		Diamond.abi,
        		signer
      		);
		const signerAddress = await signer.getAddress();
			await contract.steezInitiate();
			setChange(11);
			window.location.reload()
		}
	}

	async function createSteez( ) {
		if (typeof window.ethereum !== "undefined") {
      		const provider = new ethers.providers.Web3Provider(window.ethereum);
      		const signer = provider.getSigner();
      		const contract = new ethers.Contract(
        		diamondAddress,
        		Diamond.abi,
        		signer
      		);
		const signerAddress = await signer.getAddress();
			await contract.createSteez();
			setChange(12);
			window.location.reload()
		}
	}

	async function initializePreOrder( creatorId ) {
		if (typeof window.ethereum !== "undefined") {
      		const provider = new ethers.providers.Web3Provider(window.ethereum);
      		const signer = provider.getSigner();
      		const contract = new ethers.Contract(
        		diamondAddress,
        		Diamond.abi,
        		signer
      		);
		const signerAddress = await signer.getAddress();
			await contract.initializePreOrder( creatorId );
			setChange(13);
			window.location.reload()
		}
	}

	async function bidPreOrder( creatorId, amount ) {
		if (typeof window.ethereum !== "undefined") {
      		const provider = new ethers.providers.Web3Provider(window.ethereum);
      		const signer = provider.getSigner();
      		const contract = new ethers.Contract(
        		diamondAddress,
        		Diamond.abi,
        		signer
      		);
		const signerAddress = await signer.getAddress();
			await contract.bidPreOrder( creatorId, amount );
			setChange(14);
			window.location.reload()
		}
	}

	async function preOrderEnder( creatorId, amount ) {
		if (typeof window.ethereum !== "undefined") {
      		const provider = new ethers.providers.Web3Provider(window.ethereum);
      		const signer = provider.getSigner();
      		const contract = new ethers.Contract(
        		diamondAddress,
        		Diamond.abi,
        		signer
      		);
		const signerAddress = await signer.getAddress();
			await contract.PreOrderEnder( creatorId, amount );
			setChange(15);
			window.location.reload()
		}
	}

	async function AcceptOrReject( creatorId, answer ) {
		if ( answer == "yes") {
			answer = true
		}
		else if (answer == "no"){
			answer = false;
		}
		else {
			answer = false;
		}
		if (typeof window.ethereum !== "undefined") {
      		const provider = new ethers.providers.Web3Provider(window.ethereum);
      		const signer = provider.getSigner();
      		const contract = new ethers.Contract(
        		diamondAddress,
        		Diamond.abi,
        		signer
      		);
		const signerAddress = await signer.getAddress();
			await contract.AcceptOrReject( creatorId, answer );
			setChange(16);
			window.location.reload()
		}
	}



	async function initiate( ) {
		if (typeof window.ethereum !== "undefined") {
      		const provider = new ethers.providers.Web3Provider(window.ethereum);
      		const signer = provider.getSigner();
      		const contract = new ethers.Contract(
        		diamondAddress,
        		Diamond.abi,
        		signer
      		);
		const signerAddress = await signer.getAddress();
			await contract.steeloInitiate();
			setChange(10);
			window.location.reload()
		}
	}

	async function transfer( address, amount ) {
		if (typeof window.ethereum !== "undefined") {
      		const provider = new ethers.providers.Web3Provider(window.ethereum);
      		const signer = provider.getSigner();
      		const contract = new ethers.Contract(
        		diamondAddress,
        		Diamond.abi,
        		signer
      		);
		const signerAddress = await signer.getAddress();
			await contract.steeloTransfer(address, amount);
			setChange(1);
			window.location.reload()
			}
		}

	async function mint( amount ) {
		if (typeof window.ethereum !== "undefined") {
      		const provider = new ethers.providers.Web3Provider(window.ethereum);
      		const signer = provider.getSigner();
      		const contract = new ethers.Contract(
        		diamondAddress,
        		Diamond.abi,
        		signer
      		);
		const signerAddress = await signer.getAddress();
			await contract.steeloMint(amount);
			setChange(5);
			window.location.reload()
			}
		}

	async function burn( amount ) {
		if (typeof window.ethereum !== "undefined") {
      		const provider = new ethers.providers.Web3Provider(window.ethereum);
      		const signer = provider.getSigner();
      		const contract = new ethers.Contract(
        		diamondAddress,
        		Diamond.abi,
        		signer
      		);
		const signerAddress = await signer.getAddress();
			await contract.steeloBurn(amount);
			setChange(6);
			window.location.reload()
			}
		}

	async function transferFrom( from, to, amount ) {
		if (typeof window.ethereum !== "undefined") {
      		const provider = new ethers.providers.Web3Provider(window.ethereum);
      		const signer = provider.getSigner();
      		const contract = new ethers.Contract(
        		diamondAddress,
        		Diamond.abi,
        		signer
      		);
		const signerAddress = await signer.getAddress();
			await contract.steeloTransferFrom(from, to, amount);
			setChange(2);
			window.location.reload()
			}
		}

	async function approve( address, amount ) {
		if (typeof window.ethereum !== "undefined") {
      		const provider = new ethers.providers.Web3Provider(window.ethereum);
      		const signer = provider.getSigner();
      		const contract = new ethers.Contract(
        		diamondAddress,
        		Diamond.abi,
        		signer
      		);
		const signerAddress = await signer.getAddress();
		await contract.steeloApprove(address, amount);
		setChange(3);
	
			}
		}

	async function getAllowance( address ) {
		
		if (typeof window.ethereum !== "undefined") {
      			const provider = new ethers.providers.Web3Provider(window.ethereum);
      			const signer = provider.getSigner();
      			const contract = new ethers.Contract(
        			diamondAddress,
        			Diamond.abi,
        			signer
      			);
		const signerAddress = await signer.getAddress();	
		const allowed = await contract.steeloAllowance(myAccount, address);
		setAllowance(parseInt(allowed, 10));
		setChange(4);
		}
	}

	async function buySteelo( amount ) {
		if (typeof window.ethereum !== "undefined") {
		const provider = new ethers.providers.Web3Provider(window.ethereum);
      		const signer = provider.getSigner();
      		const contract = new ethers.Contract(
        		diamondAddress,
        		Diamond.abi,
        		signer
      		);
		const signerAddress = await signer.getAddress();
			await contract.convertEtherToSteelo({
            			value: ethers.utils.parseEther(amount.toString())
        			})
			setChange(7);
			window.location.reload()
			}
		}

	async function getEther( amount ) {
		if (typeof window.ethereum !== "undefined") {
		const provider = new ethers.providers.Web3Provider(window.ethereum);
      		const signer = provider.getSigner();
      		const contract = new ethers.Contract(
        		diamondAddress,
        		Diamond.abi,
        		signer
      		);
		const signerAddress = await signer.getAddress();
			await contract.convertSteeloToEther(amount)
			setChange(8);
			window.location.reload()
			}
		}
	
	


useEffect(() => {
    fetchDiamond();
    document.title = "Steelo Test Blockchain"
  }, [change]);
  

  return (
    <div className="App">


	  <div className='App' style={{ 
				position: 'relative',
				fontFamily: 'Quicksand', 
				 }}>
			<div style={{ position: 'absolute' }}>
			<ParticleSettings />
			</div>
			<Navbar account={myAccount}/>
			<div className="container-fluid mt-5" >
				<div className='row'>
					<main role='main' className='col-lg-12 ml-auto mr-auto' style={{ maxWidth: '600px', minHeight: '100vm' }}>
					<div>
	  					<Main transfer={transfer} name={name} symbol={symbol} totalSupply={totalSupply} totalTokens={totalTokens} balance={balance}
	  									balanceEther={balanceEther} addressTo={addressTo} setAddressTo={setAddressTo}
	  									amountToTransfer={amountToTransfer} setAmountToTransfer={setAmountToTransfer}
										 addressToApprove={addressToApprove} setAddressToApprove={setAddressToApprove} 												   amountToApprove={amountToApprove} setAmountToApprove={setAmountToApprove}
	  									 approve={approve} allowance={allowance} getAllowance={getAllowance}
	  									addressToTransferFrom={addressToTransferFrom} setAddressToTransferFrom={setAddressToTransferFrom}
	  									addressToTransferTo={addressToTransferTo} setAddressToTransferTo={setAddressToTransferTo}										  amountToTransferBetween={amountToTransferBetween} setAmountToTransferBetween={setAmountToTransferBetween}
	  									transferFrom={transferFrom} burnAmount={burnAmount} setBurnAmount={setBurnAmount} 
	  									mintAmount={mintAmount} setMintAmount={setMintAmount} burn={burn} mint={mint}
	  									buySteelo={buySteelo}  buyingEther={buyingEther} setBuyingEther={setBuyingEther}
	  									getEther={getEther} steeloAmount={steeloAmount} setSteeloAmount={setSteeloAmount}
	  									initiate={initiate} initiateSteez={initiateSteez} creatorName={creatorName}
	  									creatorSymbol={creatorSymbol} creatorAddress={creatorAddress} 
	  									steezTotalSupply={steezTotalSupply} steezCurrentPrice={steezCurrentPrice}
	  									steezInvested={steezInvested} createSteez={createSteez} auctionStartTime={auctionStartTime}
	  									auctionAnniversary={auctionAnniversary} auctionConcluded={auctionConcluded} 
	  									preOrderStartTime={preOrderStartTime}
	  									liquidityPool={liquidityPool} preOrderStarted={preOrderStarted}
	  									bidAmount={bidAmount} auctionSecured={auctionSecured} totalSteeloPreOrder={totalSteeloPreOrder}  
	  									investorLength={investorLength} timeInvested={timeInvested} investorAddress={investorAddress}
	  									creatorId={creatorId} setCreatorId={setCreatorId} initializePreOrder={initializePreOrder}
	  									bidPreOrder={bidPreOrder} creatorIdBid={creatorIdBid} setCreatorIdBid={setCreatorIdBid}
	  									biddingAmount={biddingAmount} setBiddingAmount={setBiddingAmount} 
	  									
	  									answer={answer} setAnswer={setAnswer} preOrderEnder={preOrderEnder} AcceptOrReject={AcceptOrReject}
	  									totalTransactionCount={totalTransactionCount} lowestBid={lowestBid} highestBid={highestBid}
	  									
	/>
						ezra			 
					</div>
					</main>
				</div>
			</div>
	</div>




      
    </div>
  );
}

export default App;