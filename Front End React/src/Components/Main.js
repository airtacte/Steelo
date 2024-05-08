import React, { Component,  useEffect, useState } from 'react'
import tether from '../tether.png';
import { useParams, useNavigate } from 'react-router-dom';
import axios from "axios";
import userImage from "../assets/user.png";
import styl from "../Components/Upload.module.css";
import Diamond from "../artifacts/steeloDiamond.json";
import { ethers } from "ethers";
import {diamondAddress} from "../utils/constants";


function Main ( { transfer, name, symbol, totalSupply, totalTokens, balance, balanceEther, addressTo, setAddressTo, amountToTransfer, setAmountToTransfer,addressToApprove, setAddressToApprove, amountToApprove, setAmountToApprove, approve, allowance, getAllowance, addressToTransferFrom, setAddressToTransferFrom, addressToTransferTo, setAddressToTransferTo, amountToTransferBetween, setAmountToTransferBetween, transferFrom, burnAmount, setBurnAmount, mintAmount, setMintAmount, burn, mint, buySteelo, buyingEther, setBuyingEther, steeloAmount, setSteeloAmount, getEther, initiate, initiateSteez, creatorName, creatorSymbol, createSteez, email, token, role  } ) {


	  const navigate = useNavigate();
	  const { id } = useParams();
	  console.log("creator Id :", id);
	  const [creatorDataBackend, setCreatorDataBackend] = useState("");
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
	  const [creatorId, setCreatorId] = useState("fvG74d0z271TuaE6WD2t");
	  const [creatorIdBid, setCreatorIdBid] = useState(0);
	  const [biddingAmount, setBiddingAmount] = useState(0);
	  const [answer, setAnswer] = useState(false);
	  const [totalTransactionCount, setTotalTransactionCount] = useState(0);
	  const [lowestBid, setLowestBid] = useState(0);
	  const [highestBid, setHighestBid] = useState(0);
	  const [launchAmount, setLaunchAmount] = useState(0);
	  const [anniversaryAmount, setAnniversaryAmount] = useState(0);
	  const [sellingAmount, setSellingAmount] = useState(0);
	  const [amountToSell, setAmountToSell] = useState(0);
	  const [buyingAmount, setBuyingAmount] = useState(0);
	  const [amountToBuy, setAmountToBuy] = useState(0);
	  const [sellers, setSellers] = useState([]);
	  
	


	useEffect(() => {
		      const fetchCreatorData = async () => {
			            try {
					            const response = await axios.get(`http://localhost:9000/auth/${id}`, {
							              headers: {
									                  'Content-Type': 'application/json',
									                  Authorization: `Bearer ${token}`,
									                },
							            });

					            console.log('Creator fetched successfully');
					            console.log(response.data);
						    setCreatorDataBackend(response.data);
					          } catch (error) {
							          console.error('Network error:', error);
							        }
			          };

		      fetchCreatorData();
		    }, []);



 async function fetchCreatorDetail() {
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
//	setBalanceEther(etherBalance);
      try {
	
        const creator = await contract.getAllCreator(id);
        const creator2 = await contract.getAllCreator2(id);
        const creator3 = await contract.getAllCreator3(id);
        const creator4 = await contract.checkBidAmount(id);
        const creator5 = await contract.checkInvestors(id);
       const transactionCount = await contract.getTotalTransactionAmount();
	const preOrderStatus = await contract.checkPreOrderStatus(id);
	const sellers = await contract.returnSellers(id);
//	const Bidders = await contract.FirstAndLast(id);
	console.log("creator address :", creator[0].toString(), "total supply :",parseInt(creator[1], 10), "current price :", parseInt(creator[2], 10));
	console.log("bid Amount :", parseInt(preOrderStatus[0], 10),"steelo balance :", parseInt(preOrderStatus[1], 10),"total steelo  :", parseInt(preOrderStatus[2], 10),		"steez invested :", parseInt(preOrderStatus[3], 10), "lqiuidity pool :", parseInt(preOrderStatus[4], 10));
	console.log("auction start time :", new Date(creator2[0].toNumber() * 1000).toString(),"auction anniversery :", new Date(creator2[1].toNumber() * 1000).toString(),"auction concluded :", creator2[2]);
	console.log("preorder start time :", new Date(creator3[0].toNumber() * 1000).toString(),"liquidity pool :", parseInt(creator3[1], 10),"preorder started :", creator3[2]);
	console.log("bid Amount :", parseInt(creator4[0], 10),"liquidity pool :", parseInt(creator4[1], 10),"auction secured :", parseInt(creator4[2]), "Total Steelo Preorder :", parseInt(creator4[3], 10)/(10 ** 18));
      console.log("investor length :", parseInt(creator5[0], 10),"steelo Invested :", parseInt(creator5[1], 10),"time invested :", parseInt(creator5[2]), "address of investor :", creator5[3].toString());

	console.log("transaction count :", parseInt(transactionCount, 10));
	console.log("sellers :", sellers);
	
	
	setCreatorAddress(creator[0].toString());
	setSteezTotalSupply(parseInt(creator[1], 10));
	setSteezCurrentPrice(parseInt(creator[2], 10)/(10 ** 20));
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
	setSellers(sellers);
	
//	console.log("minimum allowed :", (parseInt(Bidders[1], 10) + (10 * 10 ** 18)), "minimum bid price :", parseInt(Bidders[1], 10), "highest bid :", parseInt(Bidders[2], 10));
//	setHighestBid((parseInt(Bidders[1], 10) + (10 * 10 ** 18)));
//	setLowestBid(parseInt(Bidders[1], 10));
//	setHighestBid(parseInt(Bidders[2], 10));
	
      } catch (error) {
        console.log("Blockchain interaction failed :", error);
      }
    }
  }
	




	useEffect(() => {
		const storedRole = localStorage.getItem("role");
		
        if (!storedRole) {
		    navigate("/");
	          }
	fetchCreatorDetail();

	}, [role]);













	async function bidPreOrder( creatorId, amount ) {
		console.log("creator Id :", creatorId);
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
		}
	}


		async function launchStarter( creatorId ) {
		console.log("creator Id :", creatorId);
		if (typeof window.ethereum !== "undefined") {
      		const provider = new ethers.providers.Web3Provider(window.ethereum);
      		const signer = provider.getSigner();
      		const contract = new ethers.Contract(
        		diamondAddress,
        		Diamond.abi,
        		signer
      		);
		const signerAddress = await signer.getAddress();
			await contract.launchStarter( creatorId );
		}
	}


		async function bidLaunch( creatorId, amount ) {
		console.log("creator Id :", creatorId);
		if (typeof window.ethereum !== "undefined") {
      		const provider = new ethers.providers.Web3Provider(window.ethereum);
      		const signer = provider.getSigner();
      		const contract = new ethers.Contract(
        		diamondAddress,
        		Diamond.abi,
        		signer
      		);
		const signerAddress = await signer.getAddress();
			await contract.bidLaunch( creatorId, amount );
		}
	}



	async function initiateP2PSell( creatorId, sellingAmount, amountToSell ) {
		console.log("selling Amount :", sellingAmount);
		if (typeof window.ethereum !== "undefined") {
      		const provider = new ethers.providers.Web3Provider(window.ethereum);
      		const signer = provider.getSigner();
      		const contract = new ethers.Contract(
        		diamondAddress,
        		Diamond.abi,
        		signer
      		);
		const signerAddress = await signer.getAddress();
			await contract.initiateP2PSell( creatorId, sellingAmount, amountToSell );
		}
	}

	async function P2PBuy( creatorId, buyingAmount, amountToBuy ) {
		console.log()
		if (typeof window.ethereum !== "undefined") {
      		const provider = new ethers.providers.Web3Provider(window.ethereum);
      		const signer = provider.getSigner();
      		const contract = new ethers.Contract(
        		diamondAddress,
        		Diamond.abi,
        		signer
      		);
		const signerAddress = await signer.getAddress();
			await contract.P2PBuy( creatorId, buyingAmount, amountToBuy );
		}
	}
	




	async function anniversaryStarter( creatorId ) {
		console.log("creator Id :", creatorId);
		if (typeof window.ethereum !== "undefined") {
      		const provider = new ethers.providers.Web3Provider(window.ethereum);
      		const signer = provider.getSigner();
      		const contract = new ethers.Contract(
        		diamondAddress,
        		Diamond.abi,
        		signer
      		);
		const signerAddress = await signer.getAddress();
			await contract.anniversaryStarter( creatorId );
		}
	}


		async function bidAnniversary( creatorId, amount ) {
		console.log("creator Id :", creatorId);
		if (typeof window.ethereum !== "undefined") {
      		const provider = new ethers.providers.Web3Provider(window.ethereum);
      		const signer = provider.getSigner();
      		const contract = new ethers.Contract(
        		diamondAddress,
        		Diamond.abi,
        		signer
      		);
		const signerAddress = await signer.getAddress();
			await contract.bidAnniversary( creatorId, amount );
		}
	}
		

	








		return(
			<main role='main' className='col-lg-12 ml-auto mr-auto' style={{ maxWidth: '600px', minHeight: '100vm' }}>
			<img src={creatorDataBackend.profile ? creatorDataBackend.profile : userImage} alt="Image Preview" className={styl.previewImage} style={{ borderRadius: '50%'}}/>
			<p style={{color: "white"}}>{creatorDataBackend.name ? creatorDataBackend.name : "unnamed creator"}</p>
			



















		<div id='content' className='mt-3'>

		
				<table className='table text-muted text-center'>
					<thead>
					<tr style={{ color: 'white' }}>
						<th scope='col'>Steez Total Supply</th>
						<th scope='col'>Creator Address</th>
					</tr>
					</thead>
					<tbody>
					<tr style={{ color: 'white' }}>
						<td>{steezTotalSupply}</td>
						<td>{creatorAddress}</td>
					</tr>
					</tbody>
				</table>
				<table className='table text-muted text-center'>
					<thead>
					<tr style={{ color: 'white' }}>
						<th scope='col'>Steez Current Price</th>
						<th scope='col'>My {creatorName} Tokens</th>
					</tr>
					</thead>
					<tbody>
					<tr style={{ color: 'white' }}>
						<td>{steezCurrentPrice} £</td>
						<td>{steezInvested} {creatorSymbol}</td>
					</tr>
					</tbody>
				</table>
				<table className='table text-muted text-center'>
					<thead>
					<tr style={{ color: 'white' }}>
						<th scope='col'>Auction Start Time</th>
						<th scope='col'>Anniversary Date</th>
					</tr>
					</thead>
					<tbody>
					<tr style={{ color: 'white' }}>
						<td>{auctionStartTime}</td>
						<td>{auctionAnniversary}</td>
					</tr>
					</tbody>
				</table>
				<table className='table text-muted text-center'>
					<thead>
					<tr style={{ color: 'white' }}>
						<th scope='col'>Auction Concluded</th>
						<th scope='col'>Pre Order Start Time</th>
					</tr>
					</thead>
					<tbody>
					<tr style={{ color: 'white' }}>
						<td>{auctionConcluded ? 'yes' : 'no' }</td>
						<td>{preOrderStartTime}</td>
					</tr>
					</tbody>
				</table>
				<table className='table text-muted text-center'>
					<thead>
					<tr style={{ color: 'white' }}>
						<th scope='col'>Bid Amount</th>
						<th scope='col'>Auction Slots Secured</th>
					</tr>
					</thead>
					<tbody>
					<tr style={{ color: 'white' }}>
						<td>{bidAmount}</td>
						<td>{auctionSecured}</td>
					</tr>
					</tbody>
				</table>
				<table className='table text-muted text-center'>
					<thead>
					<tr style={{ color: 'white' }}>
						<th scope='col'>Total Investors</th>
						<th scope='col'> Bid Time</th>
					</tr>
					</thead>
					<tbody>
					<tr style={{ color: 'white' }}>
						<td>{investorLength} </td>
						<td>{timeInvested}</td>
					</tr>
					</tbody>
				</table>
				<table className='table text-muted text-center'>
					<thead>
					<tr style={{ color: 'white' }}>
						<th scope='col'>Liquidity Pool</th>
						<th scope='col'> PreOrder Started</th>
					</tr>
					</thead>
					<tbody>
					<tr style={{ color: 'white' }}>
						<td>{liquidityPool}</td>
						<td>{preOrderStarted ? 'yes' : 'no' }</td>
					</tr>
					</tbody>
				</table>
				<table className='table text-muted text-center'>
					<thead>
					<tr style={{ color: 'white' }}>
						<th scope='col'>Total Steelo PreOrder</th>
						<th scope='col'>Investor Address </th>
					</tr>
					</thead>
					<tbody>
					<tr style={{ color: 'white' }}>
						<td>{totalSteeloPreOrder}</td>
						<td>{investorAddress}</td>
					</tr>
					</tbody>
				</table>
				<table className='table text-muted text-center'>
					<thead>
					<tr style={{ color: 'white' }}>
						<th scope='col'>Highest Bid</th>
						<th scope='col'>Lowest Bid</th>
						<th scope='col'>Minimum Bid Allowed</th>
					</tr>
					</thead>
					<tbody>
					<tr style={{ color: 'white' }}>
						<td>{highestBid / 10 ** 18}</td>
						<td>{lowestBid / 10 ** 18}</td>
						<td>{(auctionSecured == 5 ? lowestBid + (10 ** 19) : lowestBid ) / 10 ** 18}</td>
					</tr>
					</tbody>
				</table>
				
				
								
				
				
				<div className='card mb-2' style={{opacity:'.9'}}>
				
					<form 
						onSubmit={ (event) => {
							event.preventDefault()
							bidPreOrder(id, biddingAmount)
						}}
						className='mb-3'
						style={{ padding: '15px' }}>
						<div style={{ borderSpacing:'0 1em'}}>
						<div className='input-group mb-4'>
						
					
						<label className='input-group mb-4' style={{marginTop: '20px'}}>Bidding Amount</label>
						<input 
							type='number'
							placeholder='0'
							onChange={(e) => setBiddingAmount(e.target.value) }
							required />
						<div className='input-group-open' style={{backgroundColor: '#ffffff', border: 'none'}}>
						<div className='input-group-text' style={{ height: '70px', marginLeft: '40px', backgroundColor: '#ffffff', border: 'none'}}>
							&nbsp;&nbsp;&nbsp; {symbol}
						</div>
						</div>
						</div>
						<button type='submit' className='btn btn-primary btn-lg btn-block'>
							Bid PreOrder
						</button>
						
						</div>
					</form>

					<form 
						onSubmit={ (event) => {
							event.preventDefault()
							preOrderEnder(id, biddingAmount)
						}}
						className='mb-3'
						style={{ padding: '15px' }}>
						<div style={{ borderSpacing:'0 1em'}}>
						<div className='input-group mb-4'>
						
						
						<label className='input-group mb-4' style={{marginTop: '20px'}}>Bidding Amount</label>
						<input 
							type='number'
							placeholder='0'
							onChange={(e) => setBiddingAmount(e.target.value) }
							required />
						<div className='input-group-open' style={{backgroundColor: '#ffffff', border: 'none'}}>
						<div className='input-group-text' style={{ height: '70px', marginLeft: '40px', backgroundColor: '#ffffff', border: 'none'}}>
							&nbsp;&nbsp;&nbsp; {symbol}
						</div>
						</div>
						</div>
						<button type='submit' className='btn btn-primary btn-lg btn-block'>
							PreOrder Ender
						</button>
						
						</div>
					</form>


					<form 
						onSubmit={ (event) => {
							event.preventDefault()
							AcceptOrReject(id, answer)
						}}
						className='mb-3'
						style={{ padding: '15px' }}>
						<div style={{ borderSpacing:'0 1em'}}>
						<div className='input-group mb-4'>
						
						
						<label className='input-group mb-4' style={{marginTop: '20px'}}>Bidding Answer</label>
						<input
							
							type='text'
							placeholder='your answer'
							onChange={(e) => setAnswer(e.target.value) }
							required />
						<div className='input-group-open' style={{backgroundColor: '#ffffff', border: 'none'}}>
						<div className='input-group-text' style={{ height: '70px', marginLeft: '40px', backgroundColor: '#ffffff', border: 'none'}}>
							&nbsp;&nbsp;&nbsp; 
						</div>
						</div>
						</div>
						<button type='submit' className='btn btn-primary btn-lg btn-block'>
							Accept Or Reject Preorder
						</button>
						
						</div>
					</form>



					
					<button onClick={() => launchStarter( id )} className='btn btn-primary btn-lg btn-block'>
							Launch Starter
					</button>

						

					<form 
						onSubmit={ (event) => {
							event.preventDefault()
							bidLaunch(id, launchAmount)
						}}
						className='mb-3'
						style={{ padding: '15px' }}>
						<div style={{ borderSpacing:'0 1em'}}>
						<div className='input-group mb-4'>
						
					


						<label className='input-group mb-4' style={{marginTop: '20px'}}>Bidding Amount</label>
						<input 
							type='number'
							placeholder='0'
							onChange={(e) => setLaunchAmount(e.target.value) }
							required />
						<div className='input-group-open' style={{backgroundColor: '#ffffff', border: 'none'}}>
						<div className='input-group-text' style={{ height: '70px', marginLeft: '40px', backgroundColor: '#ffffff', border: 'none'}}>
							&nbsp;&nbsp;&nbsp; {symbol}
						</div>
						</div>
						</div>


						
					
						


						

						<button type='submit' className='btn btn-primary btn-lg btn-block'>
							Bid Launch
						</button>
						
						</div>
					</form>






					<button onClick={() => anniversaryStarter( id )} className='btn btn-primary btn-lg btn-block'>
							Anniversary Starter
					</button>

						

					<form 
						onSubmit={ (event) => {
							event.preventDefault()
							bidAnniversary(id, anniversaryAmount)
						}}
						className='mb-3'
						style={{ padding: '15px' }}>
						<div style={{ borderSpacing:'0 1em'}}>
						<div className='input-group mb-4'>
						
					


						<label className='input-group mb-4' style={{marginTop: '20px'}}>Bidding Amount</label>
						<input 
							type='number'
							placeholder='0'
							onChange={(e) => setAnniversaryAmount(e.target.value) }
							required />
						<div className='input-group-open' style={{backgroundColor: '#ffffff', border: 'none'}}>
						<div className='input-group-text' style={{ height: '70px', marginLeft: '40px', backgroundColor: '#ffffff', border: 'none'}}>
							&nbsp;&nbsp;&nbsp; {symbol}
						</div>
						</div>
						</div>


						
					
						


						

						<button type='submit' className='btn btn-primary btn-lg btn-block'>
							Bid Anniversary
						</button>
						
						</div>
					</form>









					<form 
						onSubmit={ (event) => {
							event.preventDefault()
							initiateP2PSell( id, sellingAmount, amountToSell )
						}}
						className='mb-3'
						style={{ padding: '15px' }}>
						<div style={{ borderSpacing:'0 1em'}}>
						<div className='input-group mb-4'>
						
				
						<label className='input-group mb-4' style={{marginTop: '20px'}}>Selling Price</label>
						<input 
							type='number'
							placeholder='0'
							onChange={(e) => setSellingAmount(e.target.value) }
							required />


						<label className='input-group mb-4' style={{marginTop: '20px'}}>Amounts To Sell</label>
						<input 
							type='number'
							placeholder='0'
							onChange={(e) => setAmountToSell(e.target.value) }
							required />
						<div className='input-group-open' style={{backgroundColor: '#ffffff', border: 'none'}}>
						<div className='input-group-text' style={{ height: '70px', marginLeft: '40px', backgroundColor: '#ffffff', border: 'none'}}>
							&nbsp;&nbsp;&nbsp; {symbol}
						</div>
						</div>
						</div>


						
					
						


						

						<button type='submit' className='btn btn-primary btn-lg btn-block'>
							Sell Your Steez
						</button>

			<main role="main" className="col-lg-12 mx-auto" style={{ maxWidth: '600px', minHeight: '100vh' }}>
			    <div id="content" className="mt-3">
			        {sellers?.map((seller, index) => (
			            <div key={index} className="list-group-item list-group-item-action bg-dark text-white mb-2">
			                    <div className="d-flex justify-content-between align-items-center">
 			                       <div>
			                            <h5 className="mb-1">Seller Address :{seller?.sellerAddress}</h5>
			                        </div>
			                    </div>
		                    <div>Amount :{parseFloat(seller?.sellingAmount)}</div>
		                    <div>Selling Price :{parseFloat(seller?.sellingPrice)/(10 ** 18)} £</div>
			            </div>
			        ))}
			    </div>
			</main>
						
						</div>
					</form>






				<form 
						onSubmit={ (event) => {
							event.preventDefault()
							P2PBuy( id, buyingAmount, amountToBuy )
						}}
						className='mb-3'
						style={{ padding: '15px' }}>
						<div style={{ borderSpacing:'0 1em'}}>
						<div className='input-group mb-4'>
						
				
						<label className='input-group mb-4' style={{marginTop: '20px'}}>Buying Price</label>
						<input 
							type='number'
							placeholder='0'
							onChange={(e) => setBuyingAmount(e.target.value) }
							required />


						<label className='input-group mb-4' style={{marginTop: '20px'}}>Amounts To Buy</label>
						<input 
							type='number'
							placeholder='0'
							onChange={(e) => setAmountToBuy(e.target.value) }
							required />
						<div className='input-group-open' style={{backgroundColor: '#ffffff', border: 'none'}}>
						<div className='input-group-text' style={{ height: '70px', marginLeft: '40px', backgroundColor: '#ffffff', border: 'none'}}>
							&nbsp;&nbsp;&nbsp; {symbol}
						</div>
						</div>
						</div>


						
					
						


						

						<button type='submit' className='btn btn-primary btn-lg btn-block'>
							Buy Peer To Peer
						</button>

									
						</div>
					</form>


					
					<div className='card-body text-center' style={{ color: 'blue' }}>
						
					</div>
				</div>
		
			</div>




			
























				
							
		</main>
		)
}

export default Main;
