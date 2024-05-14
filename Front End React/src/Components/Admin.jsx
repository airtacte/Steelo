import React, { Component,  useEffect, useState } from 'react'
import tether from '../tether.png';
import { useNavigate } from 'react-router-dom';
import Diamond from "../artifacts/steeloDiamond.json";
import { ethers } from "ethers";
import {diamondAddress} from "../utils/constants";




function Admin ( {  email, token, role, addressToTransferFrom, setAddressToTransferFrom, addressToTransferTo, setAddressToTransferTo, amountToTransferBetween, setAmountToTransferBetween, symbol, steeloPrice, totalSupply, totalTokens, totalTransactionCount } ) {

	const [roleGranted, setRoleGranted] = useState("");
	const [addressGranted, setAddressGranted] = useState("");
	const [donatingEther, setDonatingEther] = useState(0);
	const [withdrawingPound, setWithdrawingPound] = useState(0);
	const [contractBalance, setContractBalance] = useState(0);
	const [balanceChange, setBalanceChange] = useState(0);



	useEffect(() => {
    	let isActive = true; // Flag to check component mount status

    	const fetchContractBalance = async () => {
    	if (typeof window.ethereum !== 'undefined') {
        	const provider = new ethers.providers.Web3Provider(window.ethereum);
        	const contract = new ethers.Contract(
        		  diamondAddress,
        		  Diamond.abi,
        		  provider
        	);
        	const balance = await contract.getContractBalance();
        	if (isActive) {
        		  setContractBalance(parseFloat(ethers.utils.formatEther(balance)));
        		}
      		}
    	};

    fetchContractBalance();

    return () => {
      isActive = false; // Cleanup function to prevent state update after unmount
    };
  }, [balanceChange]);
	


	async function getContractBalance() {
//		console.log("amount to be donated :", parseFloat(ethers.utils.parseEther(donatingEther.toString())));
		if (typeof window.ethereum !== "undefined") {
		const provider = new ethers.providers.Web3Provider(window.ethereum);
      		const signer = provider.getSigner();
      		const contract = new ethers.Contract(
        		diamondAddress,
        		Diamond.abi,
        		signer
      		);
		const signerAddress = await signer.getAddress();
			const balance = await contract.getContractBalance();
			setContractBalance(parseFloat(balance / (10 ** 18)));
			}
		}

	async function withdrawPound( withdrawingPound ) {
		if (typeof window.ethereum !== "undefined") {
		const provider = new ethers.providers.Web3Provider(window.ethereum);
      		const signer = provider.getSigner();
      		const contract = new ethers.Contract(
        		diamondAddress,
        		Diamond.abi,
        		signer
      		);
		const signerAddress = await signer.getAddress();
			await contract.withdrawEther(ethers.utils.parseEther(withdrawingPound.toString()));
                	setTimeout(() => {
            			setBalanceChange(prev => prev + 1);
        		}, 20000);			}
			
		}


	async function donatePound( donatingEther ) {
//		console.log("amount to be donated :", parseFloat(ethers.utils.parseEther(donatingEther.toString())));
		if (typeof window.ethereum !== "undefined") {
		const provider = new ethers.providers.Web3Provider(window.ethereum);
      		const signer = provider.getSigner();
      		const contract = new ethers.Contract(
        		diamondAddress,
        		Diamond.abi,
        		signer
      		);
		const signerAddress = await signer.getAddress();
			await contract.donateEther({
            			value: ethers.utils.parseEther(donatingEther.toString())
        			});
                	setTimeout(() => {
            			setBalanceChange(prev => prev + 1);
        		}, 20000);
			}
		}

	async function initiate() {
		if (typeof window.ethereum !== "undefined") {
      		const provider = new ethers.providers.Web3Provider(window.ethereum);
      		const signer = provider.getSigner();
      		const contract = new ethers.Contract(
        		diamondAddress,
        		Diamond.abi,
        		signer
      		);
		const signerAddress = await signer.getAddress();
			await contract.initialize();
		}
	}

	async function steeloInitiate( ) {
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
		}
	}

	async function grantRole( roleGranted, addressGranted ) {
		if (typeof window.ethereum !== "undefined") {
      		const provider = new ethers.providers.Web3Provider(window.ethereum);
      		const signer = provider.getSigner();
      		const contract = new ethers.Contract(
        		diamondAddress,
        		Diamond.abi,
        		signer
      		);
		const signerAddress = await signer.getAddress();
			await contract.grantRole(roleGranted, addressGranted);
		}
	}

	async function revokeRole( roleGranted, addressGranted ) {
		if (typeof window.ethereum !== "undefined") {
      		const provider = new ethers.providers.Web3Provider(window.ethereum);
      		const signer = provider.getSigner();
      		const contract = new ethers.Contract(
        		diamondAddress,
        		Diamond.abi,
        		signer
      		);
		const signerAddress = await signer.getAddress();
			await contract.revokeRole(roleGranted, addressGranted);
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
			await contract.steeloTransferFrom(from, to, ethers.utils.parseEther(amount.toString()));
			setTimeout(() => {
            			setBalanceChange(prev => prev + 1);
        		}, 20000);
			}
		}

	const handleChangeRole = (event) => {
	    setRoleGranted(event.target.value);
	  };

	const navigate = useNavigate();
	
	useEffect(() => {
		
        if (!token || !email || !role) {
		navigate("/");
	          }
	if (role != "executive") {
		navigate("/");
	}

	}, [email, token, role]);
		
	
		return(
			<main role='main' className='col-lg-12 ml-auto mr-auto' style={{ maxWidth: '600px', minHeight: '100vm' }}>
			<div id='content' className='mt-3'>
				Executive Page
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
						<th scope='col'>Total Transaction Count</th>
					</tr>
					</thead>
					<tbody>
					<tr style={{ color: 'white' }}>
						<td>{totalTransactionCount}</td>
					</tr>
					</tbody>
				</table>
			
			
			<table className='table text-muted text-center'>
					<thead>
					<tr style={{ color: 'white' }}>
						<th scope='col'>Contract Balance</th>
						<th scope='col'>Steelo Current Price</th>
					</tr>
					</thead>
					<tbody>
					<tr style={{ color: 'white' }}>
						<td>{contractBalance} £</td>
						<td>{steeloPrice} £</td>
					</tr>
					</tbody>
				</table>
			<button onClick={steeloInitiate}  className='btn btn-primary btn-lg btn-block'>
				 	Initiate Steelo
				</button>
			</div>
			<div id='content' className='mt-3'>
				Executive Page
			<button onClick={initiateSteez}  className='btn btn-primary btn-lg btn-block'>
				 	Initiate Steez
				</button>
			</div>

			<form 
				onSubmit={ (event) => {
					event.preventDefault()
						grantRole(roleGranted, addressGranted)
						}}
						className='mb-3'
						style={{ padding: '15px' }}>
						<div style={{ borderSpacing:'0 1em'}}>
						<div className='input-group mb-4'>
						
						<label className='input-group mb-4' style={{marginTop: '20px'}}>Amount</label>
						<input 
							type='text'
							style={{ width: '100%' }}
							placeholder='0x0'
							onChange={(e) => setAddressGranted(e.target.value) }
							required />
						</div>
		                                <div>
						      <h1>Select Your Role:</h1>
						      <select value={roleGranted} onChange={handleChangeRole}>
					                <option value="" disabled>Choose Role</option>
						        <option value="ADMIN_ROLE">Admin</option>
						        <option value="EXECUTIVE_ROLE">Executive</option>
						        <option value="EMPLOYEE_ROLE">employee</option>
						        <option value="TESTER_ROLE">Tester</option>
						        <option value="STAKER_ROLE">Staker</option>
						        <option value="USER_ROLE">User</option>
						        <option value="VISITOR_ROLE">Visitor</option>
						        <option value="TEAM_ROLE">Team</option>
						        <option value="MODERATOR_ROLE">Moderator</option>
						        <option value="INVESTOR_ROLE">Investor</option>
						        <option value="SUBSCRIBER_ROLE">Subscriber</option>
						      </select>
						      <p>{roleGranted && <span>Selected Role: {roleGranted}</span>}</p>
						    </div>
						<button type='submit' className='btn btn-primary btn-lg btn-block'>
							Grant
						</button>
						
						</div>
					</form>


					<form 
				onSubmit={ (event) => {
					event.preventDefault()
						revokeRole(roleGranted, addressGranted)
						}}
						className='mb-3'
						style={{ padding: '15px' }}>
						<div style={{ borderSpacing:'0 1em'}}>
						<div className='input-group mb-4'>
						
						<label className='input-group mb-4' style={{marginTop: '20px'}}>Amount</label>
						<input 
							type='text'
							style={{ width: '100%' }}
							placeholder='0x0'
							onChange={(e) => setAddressGranted(e.target.value) }
							required />
						</div>
		                                <div>
						      <h1>Select Your Role:</h1>
						      <select value={roleGranted} onChange={handleChangeRole} className="form-select">
					                <option value="" disabled>Choose Role</option>
						        <option value="ADMIN_ROLE">Admin</option>
						        <option value="EXECUTIVE_ROLE">Executive</option>
						        <option value="EMPLOYEE_ROLE">employee</option>
						        <option value="TESTER_ROLE">Tester</option>
						        <option value="STAKER_ROLE">Staker</option>
						        <option value="USER_ROLE">User</option>
						        <option value="VISITOR_ROLE">Visitor</option>
						        <option value="TEAM_ROLE">Team</option>
						        <option value="MODERATOR_ROLE">Moderator</option>
						        <option value="INVESTOR_ROLE">Investor</option>
						        <option value="SUBSCRIBER_ROLE">Subscriber</option>
						      </select>
						      <p>{roleGranted && <span>Selected Role: {roleGranted}</span>}</p>
						    </div>
						<button type='submit' className='btn btn-primary btn-lg btn-block'>
							Revoke
						</button>
						
						</div>
					</form>

					

			<div id='content' className='mt-3'>
				Executive Page
			<button onClick={steeloTGE}  className='btn btn-primary btn-lg btn-block'>
				 	Steelo Total Token Generation
				</button>


				<form 
						onSubmit={ (event) => {
							event.preventDefault()
							donatePound(donatingEther)
						}}
						className='mb-3'
						style={{ padding: '15px' }}>
						<div style={{ borderSpacing:'0 1em'}}>
						<div className='input-group mb-4'>
						
						<label className='input-group mb-4' style={{marginTop: '20px'}}>Amount</label>
						<input 
							type='float'
							placeholder={donatingEther}
							onChange={(e) => setDonatingEther(e.target.value) }
							required />
						<div className='input-group-open' style={{color: '#ffffff',backgroundColor: '#000000', border: 'none'}}>
						<div className='input-group-text' style={{ height: '70px', marginLeft: '40px', color: '#ffffff',backgroundColor: '#000000',  border: 'none', fontSize: '50px'}}>
							&nbsp;&nbsp;&nbsp; £
						</div>
						</div>
						</div>
						<button type='submit' className='btn btn-primary btn-lg btn-block'>
							Donate Pound
						</button>
						
						</div>
					</form>


<form 
						onSubmit={ (event) => {
							event.preventDefault()
							withdrawPound(withdrawingPound)
						}}
						className='mb-3'
						style={{ padding: '15px' }}>
						<div style={{ borderSpacing:'0 1em'}}>
						<div className='input-group mb-4'>
						
						<label className='input-group mb-4' style={{marginTop: '20px'}}>Amount</label>
						<input 
							type='float'
							placeholder={withdrawingPound}
							onChange={(e) => setWithdrawingPound(e.target.value) }
							required />
						<div className='input-group-open' style={{color: '#ffffff',backgroundColor: '#000000', border: 'none'}}>
						<div className='input-group-text' style={{ height: '70px', marginLeft: '40px', color: '#ffffff',backgroundColor: '#000000',  border: 'none', fontSize: '50px'}}>
							&nbsp;&nbsp;&nbsp; £
						</div>
						</div>
						</div>
						<button type='submit' className='btn btn-primary btn-lg btn-block'>
							Withdraw Pound
						</button>
						
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
						<div className='input-group-open' style={{backgroundColor: 'none', border: 'none'}}>
						<div className='input-group-text' style={{ height: '70px', marginLeft: '40px', backgroundColor: 'none', border: 'none'}}>
							&nbsp;&nbsp;&nbsp; {symbol}
						</div>
						</div>
						</div>
						<button type='submit' className='btn btn-primary btn-lg btn-block'>
							Transfer
						</button>
						
						</div>
					</form>
					
				
			</div>
		</main>
		)
}

export default Admin;
