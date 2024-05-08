import { useState, useEffect } from "react";
import { ethers } from "ethers";
import Diamond from "./artifacts/steeloDiamond.json";
import "./App.css";
import Navbar from './Components/Navbar';
import Main from "./Components/Main";
import Login from "./Components/Login";
import SignUp from "./Components/SignUp";
import Admin from "./Components/Admin";
import Creator from "./Components/Creator"; 
import Bazaar from "./Components/Baz"; 
import Gallery from "./Components/Gallery"; 
import ParticleSettings from './ParticleSettings';
import { BrowserRouter as Router, Route, Routes  } from "react-router-dom";
import {diamondAddress} from "./utils/constants";





function App() {





  const [token, setToken] = useState('');
  const [email, setEmail] = useState('');
  const [role, setRole] = useState('');
  const [userId, setUserId] = useState("");
  const [userName, setUserName] = useState("");
  const [loginData, setLoginData] = useState({
		      email: "",
		      password: "",
		    });
  const [signupData, setSignupData] = useState({
	      name: '',
	      email: '',
	      password: '',
	    });
  const [remover, setRemover] = useState(true);
  const [shower, setShower] = useState(false);
  const [loggedin, setlogin] = useState(false);
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  useEffect(() => {
	      if (typeof localStorage !== 'undefined') {
		            const storedToken = localStorage.getItem("token");
		            const storedEmail = localStorage.getItem("email");
		      	    const storedName = localStorage.getItem("name");
		            const storedRole = localStorage.getItem("role");
		            const storedIsAuthenticated = localStorage.getItem('token') !== null;

		            if (storedToken) setToken(storedToken);
		            if (storedEmail) setEmail(storedEmail);
		            if (storedName) setRole(storedRole);
		            if (storedName) setUserName(storedName);
		            setIsAuthenticated(storedIsAuthenticated);
		          }
	    }, []);


   









  const [name, setName] = useState("");
  const [profileId, setProfileId] = useState("");
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
  const [creatorId, setCreatorId] = useState("fvG74d0z271TuaE6WD2t");
  const [creatorIdBid, setCreatorIdBid] = useState(0);
  const [biddingAmount, setBiddingAmount] = useState(0);
  const [answer, setAnswer] = useState(false);
  const [totalTransactionCount, setTotalTransactionCount] = useState(0);
  const [lowestBid, setLowestBid] = useState(0);
  const [highestBid, setHighestBid] = useState(0);
  const [roleGranted, setRoleGranted] = useState("");
  const [stakedPound, setStakedPound] = useState(0);
  const [interest, setInterest] = useState(0);
  let isConfirm = false


  async function requestAccount() {
    if (window.ethereum) {
        try {
            await window.ethereum.request({ method: 'eth_requestAccounts' });
        } catch (error) {
            console.error("Error requesting accounts access: ", error);
        }
    } else {
        console.error('MetaMask is not installed. Please consider installing it: https://metamask.io/download.html');
    }
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
	const authors = await contract.authors();
        const name = await contract.steeloName();
	const profileId = await contract.profileIdUser();
        const creatorName = await contract.creatorTokenName();
//      const creatorSymbol = await contract.creatorTokenSymbol();
        const symbol = await contract.steeloSymbol();
          const totalSupply = await contract.steeloTotalSupply();
        const totalToken = await contract.steeloTotalTokens();
        const balance = await contract.steeloBalanceOf(signerAddress);
	const stakedPound = await contract.getStakedBalance();
	const unstakers = await contract.getUnstakers();
	const interest = await contract.getInterest();
//        const creator = await contract.getAllCreator(creatorId);
//        const creator2 = await contract.getAllCreator2(creatorId);
//        const creator3 = await contract.getAllCreator3(creatorId);
//        const creator4 = await contract.checkBidAmount(creatorId);
//        const creator5 = await contract.checkInvestors(creatorId);
//        const index = await contract.getPopIndex();
        const transactionCount = await contract.getTotalTransactionAmount();
//	const preOrderStatus = await contract.checkPreOrderStatus(creatorId);
//	const Bidders = await contract.FirstAndLast(creatorId);
        console.log("authors :", authors);
	console.log("profile :", profileId);
	console.log("name :", name);
        console.log("symbol :", symbol);
        console.log("totalSupply :", parseFloat(totalSupply, 10));
        console.log("totalToken :", parseFloat(totalToken, 10));
        console.log("balance :", parseFloat(balance, 10));
	console.log("staked pound :", parseFloat(stakedPound));
        console.log("Creator Name :", creatorName);
	console.log("Unstakers :", unstakers);
	console.log("your interest :", interest);
//       console.log("Creator Symbol :", creatorSymbol);
//	console.log("creator address :", creator[0].toString(), "total supply :",parseInt(creator[1], 10), "current price :", parseInt(creator[2], 10));
//	console.log("bid Amount :", parseInt(preOrderStatus[0], 10),"steelo balance :", parseInt(preOrderStatus[1], 10),"total steelo  :", parseInt(preOrderStatus[2], 10),
//		"steez invested :", parseInt(preOrderStatus[3], 10), "lqiuidity pool :", parseInt(preOrderStatus[4], 10));
//	console.log("auction start time :", new Date(creator2[0].toNumber() * 1000).toString(),"auction anniversery :", new Date(creator2[1].toNumber() * 1000).toString(),"auction concluded :", creator2[2]);
//	console.log("preorder start time :", new Date(creator3[0].toNumber() * 1000).toString(),"liquidity pool :", parseInt(creator3[1], 10),"preorder started :", creator3[2]);
//	console.log("bid Amount :", parseInt(creator4[0], 10),"liquidity pool :", parseInt(creator4[1], 10),"auction secured :", parseInt(creator4[2]), "Total Steelo Preorder :", parseInt(creator4[3], 10)/(10 ** 18));
//      console.log("investor length :", parseInt(creator5[0], 10),"steelo Invested :", parseInt(creator5[1], 10),"time invested :", parseInt(creator5[2]), "address of investor :", creator5[3].toString());
//	console.log("popping index :", parseInt(index[0]), "poppin address :", index[1].toString(), "popping price :", parseInt(index[2], 10));

	console.log("transaction count :", parseInt(transactionCount, 10));
	
	setName(name);
	setProfileId(profileId);
	setUserId(profileId);
	setSymbol(symbol);
	setTotalSupply(parseFloat(totalSupply)/(10 ** 18));
	setTotalTokens(parseFloat(totalToken)/(10 ** 18));
	setBalance(parseFloat(balance)/(10 ** 18));
	setStakedPound(parseFloat(stakedPound)/(10 ** 18));
	setCreatorName(creatorName);
	setInterest(parseFloat(interest/ 100));
//	setCreatorSymbol(creatorSymbol);
//	setCreatorAddress(creator[0].toString());
//	setSteezTotalSupply(parseInt(creator[1], 10));
//	setSteezCurrentPrice(parseInt(creator[2], 10)/(10 ** 18));
//	setSteezInvested(parseInt(preOrderStatus[3], 10));
//	setauctionStartTime(new Date(creator2[0].toNumber() * 1000).toString());
//	setauctionAnniversary(new Date(creator2[1].toNumber() * 1000).toString());	
//	setAuctionConlcuded(creator2[2]);
//	setPreOrderStartTime(new Date(creator3[0].toNumber() * 1000).toString());
//	setLiquidityPool(parseInt(creator3[1], 10));
//	setPreOrderStarted(creator3[2]);
//	setBidAmount(parseInt(creator4[0], 10) / (10 ** 18));
//	setAuctionSecured(parseInt(creator4[2]));
//	setTotalSteeloPreOrder(parseInt(creator4[3], 10)/(10 ** 18));
//	setInvestorLength(parseInt(creator5[0], 10));
//	setTimeInvested(new Date(creator5[2].toNumber() * 1000).toString());
//	setInvestorAddress(creator5[3].toString());
	setTotalTransactionCount(parseInt(transactionCount, 10));
//	console.log("minimum allowed :", (parseInt(Bidders[1], 10) + (10 * 10 ** 18)), "minimum bid price :", parseInt(Bidders[1], 10), "highest bid :", parseInt(Bidders[2], 10));
//	setHighestBid((parseInt(Bidders[1], 10) + (10 * 10 ** 18)));
//	setLowestBid(parseInt(Bidders[1], 10));
//	setHighestBid(parseInt(Bidders[2], 10));
	
      } catch (error) {
        console.log("Blockchain interaction failed :", error);
      }
    }
  }


       window.ethereum.on('accountsChanged', async function (accounts) {
	        localStorage.removeItem('email');
		localStorage.removeItem('name');
		localStorage.removeItem('role');
		localStorage.removeItem('token');
		setEmail("");
		setToken("");
		setRole("");
		setUserName("");
                await fetchDiamond();
		
	});

	
	


useEffect(() => {
  async function loadAndSet() {
    await fetchDiamond();
    document.title = "Steelo Test Blockchain";
  }

  loadAndSet();
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
			<Navbar account={myAccount} userId={userId} role={role} setRole={setRole} setEmail={setEmail} setToken={setToken} setUserId={setUserId} userName={userName} setUserName={setUserName}/>
			<div className="container-fluid mt-5" >
				<div className='row'>
	  			<Router>
	  <Routes>
	  	


	  	<Route index element={<Login  account={myAccount} shower={shower} remover={remover} email={email} token={token} formData={loginData} setFormData={setLoginData} loggedin={loggedin} setlogin={setlogin} setToken={setToken} setEmail={setEmail} role={role} setRole={setRole} userId={userId} setUserId={setUserId} userName={userName} setUserName={setUserName} />}  profileId={profileId} fetchDiamond={fetchDiamond}  />
	        


	  	<Route path="/signup" element={<SignUp  account={myAccount} shower={shower} remover={remover} email={email} token={token} formData={signupData} setFormData={setSignupData} loggedin={loggedin} setlogin={setlogin} setToken={setToken} setEmail={setEmail} role={role} setRole={setRole} userId={userId} setUserId={setUserId} userName={userName} setUserName={setUserName}  />} />
	  


	  	<Route path="/admin" element={<Admin  email={email} token={token}  role={role} userId={userId}  setRoleGranted={setRoleGranted} roleGranted={roleGranted} />} />

		<Route path="/creator/:id" element={<Creator  userName={userName} email={email} token={token}  role={role} userId={userId}  setRoleGranted={setRoleGranted} roleGranted={roleGranted} />} />

	  	<Route path="/bazaar" element={<Bazaar  email={email} token={token}  role={role} userId={userId}  setRoleGranted={setRoleGranted} roleGranted={roleGranted} />} />
		
	  <Route path="/gallery/:id" element={<Gallery  name={name} symbol={symbol} totalSupply={totalSupply} totalTokens={totalTokens} balance={balance}
	  									balanceEther={balanceEther} addressTo={addressTo} setAddressTo={setAddressTo}
	  									amountToTransfer={amountToTransfer} setAmountToTransfer={setAmountToTransfer}
										 addressToApprove={addressToApprove} setAddressToApprove={setAddressToApprove} 												   amountToApprove={amountToApprove} setAmountToApprove={setAmountToApprove}
	  									  allowance={allowance}
	  									addressToTransferFrom={addressToTransferFrom} setAddressToTransferFrom={setAddressToTransferFrom}
	  									addressToTransferTo={addressToTransferTo} setAddressToTransferTo={setAddressToTransferTo}										  amountToTransferBetween={amountToTransferBetween} setAmountToTransferBetween={setAmountToTransferBetween}
	  									burnAmount={burnAmount} setBurnAmount={setBurnAmount} 
	  									mintAmount={mintAmount} setMintAmount={setMintAmount} 
	  									buyingEther={buyingEther} setBuyingEther={setBuyingEther}
	  									steeloAmount={steeloAmount} setSteeloAmount={setSteeloAmount}
	  									 creatorName={creatorName}
	  									creatorSymbol={creatorSymbol} creatorAddress={creatorAddress} 
	  									steezTotalSupply={steezTotalSupply} steezCurrentPrice={steezCurrentPrice}
	  									steezInvested={steezInvested} auctionStartTime={auctionStartTime}
	  									auctionAnniversary={auctionAnniversary} auctionConcluded={auctionConcluded} 
	  									preOrderStartTime={preOrderStartTime}
	  									liquidityPool={liquidityPool} preOrderStarted={preOrderStarted}
	  									bidAmount={bidAmount} auctionSecured={auctionSecured} totalSteeloPreOrder={totalSteeloPreOrder}  
	  									investorLength={investorLength} timeInvested={timeInvested} investorAddress={investorAddress}
	  									creatorId={creatorId} setCreatorId={setCreatorId}
	  									 creatorIdBid={creatorIdBid} setCreatorIdBid={setCreatorIdBid}
	  									biddingAmount={biddingAmount} setBiddingAmount={setBiddingAmount} 
	  									
	  									answer={answer} setAnswer={setAnswer}
	  									totalTransactionCount={totalTransactionCount} lowestBid={lowestBid} highestBid={highestBid} 
										email={email} token={token} stakedPound={stakedPound} interest={interest} role={role}/>} />







	  	<Route path="/bazaar/:id"  element={<Main name={name} symbol={symbol} totalSupply={totalSupply} totalTokens={totalTokens} balance={balance}
	  									balanceEther={balanceEther} addressTo={addressTo} setAddressTo={setAddressTo}
	  									amountToTransfer={amountToTransfer} setAmountToTransfer={setAmountToTransfer}
										 addressToApprove={addressToApprove} setAddressToApprove={setAddressToApprove} 												   amountToApprove={amountToApprove} setAmountToApprove={setAmountToApprove}
	  									  allowance={allowance}
	  									addressToTransferFrom={addressToTransferFrom} setAddressToTransferFrom={setAddressToTransferFrom}
	  									addressToTransferTo={addressToTransferTo} setAddressToTransferTo={setAddressToTransferTo}										  amountToTransferBetween={amountToTransferBetween} setAmountToTransferBetween={setAmountToTransferBetween}
	  									burnAmount={burnAmount} setBurnAmount={setBurnAmount} 
	  									mintAmount={mintAmount} setMintAmount={setMintAmount} 
	  									buyingEther={buyingEther} setBuyingEther={setBuyingEther}
	  									steeloAmount={steeloAmount} setSteeloAmount={setSteeloAmount}
	  									 creatorName={creatorName}
	  									creatorSymbol={creatorSymbol} creatorAddress={creatorAddress} 
	  									steezTotalSupply={steezTotalSupply} steezCurrentPrice={steezCurrentPrice}
	  									steezInvested={steezInvested} auctionStartTime={auctionStartTime}
	  									auctionAnniversary={auctionAnniversary} auctionConcluded={auctionConcluded} 
	  									preOrderStartTime={preOrderStartTime}
	  									liquidityPool={liquidityPool} preOrderStarted={preOrderStarted}
	  									bidAmount={bidAmount} auctionSecured={auctionSecured} totalSteeloPreOrder={totalSteeloPreOrder}  
	  									investorLength={investorLength} timeInvested={timeInvested} investorAddress={investorAddress}
	  									creatorId={creatorId} setCreatorId={setCreatorId}
	  									 creatorIdBid={creatorIdBid} setCreatorIdBid={setCreatorIdBid}
	  									biddingAmount={biddingAmount} setBiddingAmount={setBiddingAmount} 
	  									
	  									answer={answer} setAnswer={setAnswer}
	  									totalTransactionCount={totalTransactionCount} lowestBid={lowestBid} highestBid={highestBid} 
										email={email} token={token}  stakedPound={stakedPound} role={role}
	  									
	/>} />
	  </Routes>
	  </Router>
					
				</div>
			</div>
	</div>




      
    </div>
  );
}

export default App;
