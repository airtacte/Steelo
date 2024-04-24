import React, {Component} from 'react'
import tether from '../tether.png';

function Main ( { transfer, name, symbol, totalSupply, totalTokens, balance, balanceEther, addressTo, setAddressTo, amountToTransfer, setAmountToTransfer,addressToApprove, setAddressToApprove, amountToApprove, setAmountToApprove, approve, allowance, getAllowance, addressToTransferFrom, setAddressToTransferFrom, addressToTransferTo, setAddressToTransferTo, amountToTransferBetween, setAmountToTransferBetween, transferFrom, burnAmount, setBurnAmount, mintAmount, setMintAmount, burn, mint, buySteelo, buyingEther, setBuyingEther, steeloAmount, setSteeloAmount, getEther, initiate, initiateSteez, creatorName, creatorSymbol, creatorAddress , steezTotalSupply, steezCurrentPrice, steezInvested, createSteez, auctionStartTime, auctionAnniversary, auctionConcluded , preOrderStartTime, liquidityPool, preOrderStarted , bidAmount , auctionSecured, totalSteeloPreOrder, investorLength, timeInvested, investorAddress, creatorId, setCreatorId, initializePreOrder, bidPreOrder, creatorIdBid, setCreatorIdBid, biddingAmount, setBiddingAmount, answer, setAnswer, preOrderEnder, AcceptOrReject, totalTransactionCount, lowestBid, highestBid  } ) {

		return(
			<div id='content' className='mt-3'>
				<button onClick={initiate} className='btn btn-primary btn-lg btn-block'>
							Initiate Steelo
				</button>
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
						<th scope='col'>My Ethereum Balance</th>
						<th scope='col'>My {name} Tokens</th>
					</tr>
					</thead>
					<tbody>
					<tr style={{ color: 'white' }}>
						<td>{balanceEther} ETH</td>
						<td>{balance} {symbol}</td>
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
				<div className='card mb-2' style={{opacity:'.9'}}>
					<form 
						onSubmit={ (event) => {
							event.preventDefault()
							buySteelo(buyingEther)
						}}
						className='mb-3'
						style={{ padding: '15px' }}>
						<div style={{ borderSpacing:'0 1em'}}>
						<div className='input-group mb-4'>
						
						<label className='input-group mb-4' style={{marginTop: '20px'}}>Amount</label>
						<input 
							type='number'
							placeholder='0'
							onChange={(e) => setBuyingEther(e.target.value) }
							required />
						<div className='input-group-open' style={{backgroundColor: '#ffffff', border: 'none'}}>
						<div className='input-group-text' style={{ height: '70px', marginLeft: '40px', backgroundColor: '#ffffff', border: 'none'}}>
							&nbsp;&nbsp;&nbsp; ETH
						</div>
						</div>
						</div>
						<button type='submit' className='btn btn-primary btn-lg btn-block'>
							Buy Steelo Tokens With Ether
						</button>
						
						</div>
					</form>
					<form 
						onSubmit={ (event) => {
							event.preventDefault()
							getEther(steeloAmount)
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
							Change Your Steelo Token to ether
						</button>
						
						</div>
					</form>
					<form 
						onSubmit={ (event) => {
							event.preventDefault()
							mint(mintAmount)
						}}
						className='mb-3'
						style={{ padding: '15px' }}>
						<div style={{ borderSpacing:'0 1em'}}>
						<div className='input-group mb-4'>
						
						<label className='input-group mb-4' style={{marginTop: '20px'}}>Amount</label>
						<input 
							type='number'
							placeholder='0'
							onChange={(e) => setMintAmount(e.target.value) }
							required />
						<div className='input-group-open' style={{backgroundColor: '#ffffff', border: 'none'}}>
						<div className='input-group-text' style={{ height: '70px', marginLeft: '40px', backgroundColor: '#ffffff', border: 'none'}}>
							&nbsp;&nbsp;&nbsp; {symbol}
						</div>
						</div>
						</div>
						<button type='submit' className='btn btn-primary btn-lg btn-block'>
							Mint
						</button>
						
						</div>
					</form>	



					<form 
						onSubmit={ (event) => {
							event.preventDefault()
							burn(burnAmount)
						}}
						className='mb-3'
						style={{ padding: '15px' }}>
						<div style={{ borderSpacing:'0 1em'}}>
						<div className='input-group mb-4'>
						
						<label className='input-group mb-4' style={{marginTop: '20px'}}>Amount</label>
						<input 
							type='number'
							placeholder='0'
							onChange={(e) => setBurnAmount(e.target.value) }
							required />
						<div className='input-group-open' style={{backgroundColor: '#ffffff', border: 'none'}}>
						<div className='input-group-text' style={{ height: '70px', marginLeft: '40px', backgroundColor: '#ffffff', border: 'none'}}>
							&nbsp;&nbsp;&nbsp; {symbol}
						</div>
						</div>
						</div>
						<button type='submit' className='btn btn-primary btn-lg btn-block'>
							Burn
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





















			<button onClick={initiateSteez} className='btn btn-primary btn-lg btn-block'>
							Initiate Steez
				</button>
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
						<td>{steezCurrentPrice} {symbol}</td>
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
					<button onClick={createSteez} className='btn btn-primary btn-lg btn-block'>
							Create Steez
					</button>
					<form 
						onSubmit={ (event) => {
							event.preventDefault()
							initializePreOrder(creatorId)
						}}
						className='mb-3'
						style={{ padding: '15px' }}>
						<div style={{ borderSpacing:'0 1em'}}>
						<div className='input-group mb-4'>
						
						<label className='input-group mb-4' style={{marginTop: '20px'}}>Creator Id</label>
						<input 
							type='number'
							placeholder='0'
							onChange={(e) => setCreatorId(e.target.value) }
							required />
						<div className='input-group-open' style={{backgroundColor: '#ffffff', border: 'none'}}>
						<div className='input-group-text' style={{ height: '70px', marginLeft: '40px', backgroundColor: '#ffffff', border: 'none'}}>
							&nbsp;&nbsp;&nbsp; Id
						</div>
						</div>
						</div>
						<button type='submit' className='btn btn-primary btn-lg btn-block'>
							Initialize PreOrder
						</button>
						
						</div>
					</form>
					<form 
						onSubmit={ (event) => {
							event.preventDefault()
							bidPreOrder(creatorIdBid, biddingAmount)
						}}
						className='mb-3'
						style={{ padding: '15px' }}>
						<div style={{ borderSpacing:'0 1em'}}>
						<div className='input-group mb-4'>
						
						<label className='input-group mb-4' style={{marginTop: '20px'}}>Creator Id</label>
						<input 
							type='number'
							placeholder='0'
							onChange={(e) => setCreatorIdBid(e.target.value) }
							required />
						<div className='input-group-open' style={{backgroundColor: '#ffffff', border: 'none'}}>
						<div className='input-group-text' style={{ height: '70px', marginLeft: '40px', backgroundColor: '#ffffff', border: 'none'}}>
							&nbsp;&nbsp;&nbsp; Id
						</div>
						</div>
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
							Bid
						</button>
						
						</div>
					</form>

					<form 
						onSubmit={ (event) => {
							event.preventDefault()
							preOrderEnder(creatorIdBid, biddingAmount)
						}}
						className='mb-3'
						style={{ padding: '15px' }}>
						<div style={{ borderSpacing:'0 1em'}}>
						<div className='input-group mb-4'>
						
						<label className='input-group mb-4' style={{marginTop: '20px'}}>Creator Id</label>
						<input 
							type='number'
							placeholder='0'
							onChange={(e) => setCreatorIdBid(e.target.value) }
							required />
						<div className='input-group-open' style={{backgroundColor: '#ffffff', border: 'none'}}>
						<div className='input-group-text' style={{ height: '70px', marginLeft: '40px', backgroundColor: '#ffffff', border: 'none'}}>
							&nbsp;&nbsp;&nbsp; Id
						</div>
						</div>
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
							Late Bid
						</button>
						
						</div>
					</form>


					<form 
						onSubmit={ (event) => {
							event.preventDefault()
							AcceptOrReject(creatorIdBid, answer)
						}}
						className='mb-3'
						style={{ padding: '15px' }}>
						<div style={{ borderSpacing:'0 1em'}}>
						<div className='input-group mb-4'>
						
						<label className='input-group mb-4' style={{marginTop: '20px'}}>Creator Id</label>
						<input 
							type='number'
							placeholder='0'
							onChange={(e) => setCreatorIdBid(e.target.value) }
							required />
						<div className='input-group-open' style={{backgroundColor: '#ffffff', border: 'none'}}>
						<div className='input-group-text' style={{ height: '70px', marginLeft: '40px', backgroundColor: '#ffffff', border: 'none'}}>
							&nbsp;&nbsp;&nbsp; Id
						</div>
						</div>
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
							Accept Or Reject
						</button>
						
						</div>
					</form>



					
					<div className='card-body text-center' style={{ color: 'blue' }}>
						
					</div>
				</div>
		
			</div>
		)
}

export default Main;
