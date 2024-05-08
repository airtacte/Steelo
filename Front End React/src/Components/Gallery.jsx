import React, { Component,  useEffect, useState } from 'react'
import tether from '../tether.png';
import { useParams, useNavigate } from 'react-router-dom';
import Diamond from "../artifacts/steeloDiamond.json";
import { ethers } from "ethers";
import {diamondAddress} from "../utils/constants";




function Gallery ( {  transfer, name, symbol, totalSupply, totalTokens, balance, addressTo, setAddressTo, amountToTransfer, setAmountToTransfer,addressToApprove, setAddressToApprove, amountToApprove, setAmountToApprove, approve, allowance, getAllowance, addressToTransferFrom, setAddressToTransferFrom, addressToTransferTo, setAddressToTransferTo, amountToTransferBetween, setAmountToTransferBetween, transferFrom, burnAmount, setBurnAmount, mintAmount, setMintAmount, burn, mint, buySteelo, buyingEther, setBuyingEther, steeloAmount, setSteeloAmount, getEther, initiate, initiateSteez, creatorName, creatorSymbol, creatorAddress , steezTotalSupply, steezCurrentPrice, steezInvested, createSteez, auctionStartTime, auctionAnniversary, auctionConcluded , preOrderStartTime, liquidityPool, preOrderStarted , bidAmount , auctionSecured, totalSteeloPreOrder, investorLength, timeInvested, investorAddress, creatorId, setCreatorId, initializePreOrder, bidPreOrder, creatorIdBid, setCreatorIdBid, biddingAmount, setBiddingAmount, answer, setAnswer, preOrderEnder, AcceptOrReject, totalTransactionCount, lowestBid, highestBid, email, token, role, setAllowance, stakedPound, balanceEther, interest } ) {

	const [roleGranted, setRoleGranted] = useState("");
	const [addressGranted, setAddressGranted] = useState("");
	const [donatingEther, setDonatingEther] = useState(0);
	const [withdrawingPound, setWithdrawingPound] = useState(0);
	const [contractBalance, setContractBalance] = useState(0);
	const [balanceChange, setBalanceChange] = useState(0);
	const [month, setMonth] = useState(0);
	const [stakingPound, setStakingPound] = useState(0);
	const [myAccount, setMyAccount] = useState("0x0");



	const navigate = useNavigate();
	const { id } = useParams();
	console.log("user Id :", id);



	




	useEffect(() => {
        async function fetchContractBalance() {
            if (typeof window.ethereum !== "undefined") {
                const provider = new ethers.providers.Web3Provider(window.ethereum);
                const contract = new ethers.Contract(
                    diamondAddress,
                    Diamond.abi,
                    provider
                );
                const balance = await contract.getContractBalance();
                setContractBalance(parseFloat(ethers.utils.formatEther(balance)));
            }
        }

        fetchContractBalance();
    }, [balanceChange]);
	



	


	

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
		}
	}




	

	async function profileIdUser() {
    	if (typeof window.ethereum !== "undefined") {
        	const provider = new ethers.providers.Web3Provider(window.ethereum);
        	const signer = provider.getSigner();
        	const contract = new ethers.Contract(
        	    diamondAddress,
        	    Diamond.abi,
        	    signer
        	);
        	const signerAddress = await signer.getAddress();
        	return await contract.profileIdUser();  // Return the value directly
    	}
    	return null;  // Return null or throw an error if the environment is not correct
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
		}
	}

	async function stakeSteelo( month, amount ) {
		if (typeof window.ethereum !== "undefined") {
		const provider = new ethers.providers.Web3Provider(window.ethereum);
      		const signer = provider.getSigner();
      		const contract = new ethers.Contract(
        		diamondAddress,
        		Diamond.abi,
        		signer
      		);
		const signerAddress = await signer.getAddress();
			await contract.stakeSteelo( month, {
            			value: ethers.utils.parseEther(amount.toString())
        			})
			}
		}


	async function stakePeriodEnder( month ) {
		if (typeof window.ethereum !== "undefined") {
		const provider = new ethers.providers.Web3Provider(window.ethereum);
      		const signer = provider.getSigner();
      		const contract = new ethers.Contract(
        		diamondAddress,
        		Diamond.abi,
        		signer
      		);
		const signerAddress = await signer.getAddress();
			await contract.stakePeriodEnder(month)
			}
		}




	async function unstakeSteelo( amount ) {
		if (typeof window.ethereum !== "undefined") {
		const provider = new ethers.providers.Web3Provider(window.ethereum);
      		const signer = provider.getSigner();
      		const contract = new ethers.Contract(
        		diamondAddress,
        		Diamond.abi,
        		signer
      		);
		const signerAddress = await signer.getAddress();
			await contract.unstakeSteelo(amount)
			}
		}
        async function steeloTGE() {
		if (typeof window.ethereum !== "undefined") {
		const provider = new ethers.providers.Web3Provider(window.ethereum);
      		const signer = provider.getSigner();
      		const contract = new ethers.Contract(
        		diamondAddress,
        		Diamond.abi,
        		signer
      		);
		const signerAddress = await signer.getAddress();
			await contract.steeloTGE();
			}
		}
	

	
	useEffect(() => {
		
//        if (!token || !email || !role) {
//		    navigate("/");
//	          }

	}, [email, token, role]);
		
	
		return(
			<main role='main' className='col-lg-12 ml-auto mr-auto' style={{ maxWidth: '600px', minHeight: '100vm' }}>
			<div id='content' className='mt-3'>
			
		<table className='table text-muted text-center'>
					<thead>
					<tr style={{ color: 'white' }}>
						<th scope='col'>Total Supply</th>
						<th scope='col'>Total Tokens</th>
					</tr>
					</thead>
					<tbody>
					<tr style={{ color: 'white' }}>
						<td>{totalSupply}</td>
						<td>{totalTokens}</td>
					</tr>
					</tbody>
				</table>
				<table className='table text-muted text-center'>
					<thead>
					<tr style={{ color: 'white' }}>
						<th scope='col'>My Balance</th>
						<th scope='col'>My {name} Balance</th>
						<th scope='col'>Staked Pound</th>
					</tr>
					</thead>
					<tbody>
					<tr style={{ color: 'white' }}>
						<td>{balanceEther} £ </td>
						<td>{balance} {symbol}</td>
						<td>{stakedPound} £ </td>
					</tr>
					</tbody>
				</table>
				<table className='table text-muted text-center'>
					<thead>
					<tr style={{ color: 'white' }}>
						<th scope='col'>Total Transaction Count</th>
						<th scope='col'></th>
					</tr>
					</thead>
					<tbody>
					<tr style={{ color: 'white' }}>
						<td>{totalTransactionCount}</td>
						<td></td>
					</tr>
					</tbody>
				</table>
				<table className='table text-muted text-center'>
					<thead>
					<tr style={{ color: 'white' }}>
						<th scope='col'>Interest</th>
						<th scope='col'></th>
					</tr>
					</thead>
					<tbody>
					<tr style={{ color: 'white' }}>
						<td>{interest}</td>
						<td></td>
					</tr>
					</tbody>
				</table>
				<div className='card mb-2' style={{opacity:'.9'}}>
					<form 
						onSubmit={ (event) => {
							event.preventDefault()
							stakeSteelo(month, stakingPound)
						}}
						className='mb-3'
						style={{ padding: '15px' }}>
						<div style={{ borderSpacing:'0 1em'}}>
						<div className='input-group mb-4'>

						<label className='input-group mb-4' style={{marginTop: '20px'}}>Month</label>
						<input 
							type='number'
							placeholder='0'
							onChange={(e) => setMonth(e.target.value) }
							required />
						
						<label className='input-group mb-4' style={{marginTop: '20px'}}>Amount</label>
						<input 
							type='number'
							placeholder='0'
							onChange={(e) => setStakingPound(e.target.value) }
							required />
						<div className='input-group-open' style={{backgroundColor: '#ffffff', border: 'none'}}>
						<div className='input-group-text' style={{ height: '70px', marginLeft: '40px', backgroundColor: '#ffffff', border: 'none'}}>
							&nbsp;&nbsp;&nbsp;  £
						</div>
						</div>
						</div>
						<button type='submit' className='btn btn-primary btn-lg btn-block'>
							Stake Pound
						</button>
						
						</div>
					</form>



					<form 
						onSubmit={ (event) => {
							event.preventDefault()
							stakePeriodEnder(month, stakingPound)
						}}
						className='mb-3'
						style={{ padding: '15px' }}>
						<div style={{ borderSpacing:'0 1em'}}>
						<div className='input-group mb-4'>

						<label className='input-group mb-4' style={{marginTop: '20px'}}>Month</label>
						<input 
							type='number'
							placeholder='0'
							onChange={(e) => setMonth(e.target.value) }
							required />
						
						</div>
						<button type='submit' className='btn btn-primary btn-lg btn-block'>
							Stake Period Ender
						</button>
						
						</div>
					</form>


					<form 
						onSubmit={ (event) => {
							event.preventDefault()
							unstakeSteelo(steeloAmount)
						}}
						className='mb-3'
						style={{ padding: '15px' }}>
						<div style={{ borderSpacing:'0 1em'}}>
						<div className='input-group mb-4'>
						
						<label className='input-group mb-4' style={{marginTop: '20px'}}>Amount</label>
						<input 
							type='number'
							placeholder='0'
							onChange={(e) => setSteeloAmount(e.target.value) }
							required />
						<div className='input-group-open' style={{backgroundColor: '#ffffff', border: 'none'}}>
						<div className='input-group-text' style={{ height: '70px', marginLeft: '40px', backgroundColor: '#ffffff', border: 'none'}}>
							&nbsp;&nbsp;&nbsp; {symbol}
						</div>
						</div>
						</div>
						<button type='submit' className='btn btn-primary btn-lg btn-block'>
							Unstake Your Tokens
						</button>
						
						</div>
					</form>
				

					<form 
						onSubmit={ (event) => {
							event.preventDefault()
							transfer(addressTo, amountToTransfer)
						}}
						className='mb-3'
						style={{ padding: '15px' }}>
						<div style={{ borderSpacing:'0 1em'}}>
						<div className='input-group mb-4'>
						<label className='input-group mb-4' style={{marginTop: '20px'}}>Address</label>
						<input 
							type='text'
							placeholder='0x0'
							onChange={(e) => setAddressTo(e.target.value) }
							required />
						<label className='input-group mb-4' style={{marginTop: '20px'}}>Amount</label>
						<input 
							type='number'
							placeholder='0'
							onChange={(e) => setAmountToTransfer(e.target.value) }
							required />
						<div className='input-group-open' style={{backgroundColor: '#ffffff', border: 'none'}}>
						<div className='input-group-text' style={{ height: '70px', marginLeft: '40px', backgroundColor: '#ffffff', border: 'none'}}>
							&nbsp;&nbsp;&nbsp; {symbol}
						</div>
						</div>
						</div>
						<button type='submit' className='btn btn-primary btn-lg btn-block'>
							Transfer
						</button>
						
						</div>
					</form>
					<form 
						onSubmit={ (event) => {
							event.preventDefault()
							approve(addressToApprove, amountToApprove)
						}}
						className='mb-3'
						style={{ padding: '15px' }}>
						<div style={{ borderSpacing:'0 1em'}}>
						<div className='input-group mb-4'>
						<label className='input-group mb-4' style={{marginTop: '20px'}}>Address</label>
						<input 
							type='text'
							placeholder='0x0'
							onChange={(e) => setAddressToApprove(e.target.value) }
							required />
						<label className='input-group mb-4' style={{marginTop: '20px'}}>Amount</label>
						<input 
							type='number'
							placeholder='0'
							onChange={(e) => setAmountToApprove(e.target.value) }
							required />
						<div className='input-group-open' style={{backgroundColor: '#ffffff', border: 'none'}}>
						<div className='input-group-text' style={{ height: '70px', marginLeft: '40px', backgroundColor: '#ffffff', border: 'none'}}>
							&nbsp;&nbsp;&nbsp; {symbol}
						</div>
						</div>
						<button type='submit' className='btn btn-primary btn-lg btn-block' style={{ marginTop: '20px' }}>
							Approve
						</button>
						<label className='input-group mb-4' style={{marginTop: '20px'}}>Allowed: {allowance}</label>
						<button onClick={() => getAllowance(addressToApprove)} className='btn btn-primary btn-lg btn-block'>
							Get Allowance
						</button>
						</div>
						
						
						</div>
					</form>
					<form 
						onSubmit={ (event) => {
							event.preventDefault()
							transferFrom(addressToTransferFrom, addressToTransferTo, amountToTransferBetween)
						}}
						className='mb-3'
						style={{ padding: '15px' }}>
						<div style={{ borderSpacing:'0 1em'}}>
						<div className='input-group mb-4'>
						<label className='input-group mb-4' style={{marginTop: '20px'}}>Address From</label>
						<input 
							type='text'
							placeholder='0x0'
							onChange={(e) => setAddressToTransferFrom(e.target.value) }
							required />
						<label className='input-group mb-4' style={{marginTop: '20px'}}>Address To</label>
						<input 
							type='text'
							placeholder='0x0'
							onChange={(e) => setAddressToTransferTo(e.target.value) }
							required />
						<label className='input-group mb-4' style={{marginTop: '20px'}}>Amount</label>
						<input 
							type='number'
							placeholder='0'
							onChange={(e) => setAmountToTransferBetween(e.target.value) }
							required />
						<div className='input-group-open' style={{backgroundColor: '#ffffff', border: 'none'}}>
						<div className='input-group-text' style={{ height: '70px', marginLeft: '40px', backgroundColor: '#ffffff', border: 'none'}}>
							&nbsp;&nbsp;&nbsp; {symbol}
						</div>
						</div>
						</div>
						<button type='submit' className='btn btn-primary btn-lg btn-block'>
							Transfer
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

export default Gallery;
