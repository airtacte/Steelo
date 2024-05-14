import React, { Component,  useEffect, useState } from 'react'
import tether from '../tether.png';
import { useNavigate } from 'react-router-dom';
import Diamond from "../artifacts/steeloDiamond.json";
import { ethers } from "ethers";
import {diamondAddress} from "../utils/constants";
import axios from "axios";
import styl from "../Components/Upload.module.css";
import userImage from "../assets/user.png";





function Baazar ( {  email, token, role } ) {

	const [roleGranted, setRoleGranted] = useState("");
	const [addressGranted, setAddressGranted] = useState("");
	const [donatingEther, setDonatingEther] = useState(0);
	const [withdrawingPound, setWithdrawingPound] = useState(0);
	const [creators, setCreators] = useState([]);
	const [balanceChange, setBalanceChange] = useState(0);
	const [creatorsDataBackend, setCreatorDataBackend] = useState([]);



	useEffect(() => {
        	getAllCreatorsDataBlockchain() 
    }, []);

	useEffect(() => {
			  let isMounted = true;  // flag to indicate if the component is still mounted
	
			  const fetchCreatorDataBackend = async () => {
		    try {
		      const response = await axios.get(`http://localhost:9000/auth`, {
		        headers: {
		          'Content-Type': 'application/json',
		          Authorization: `Bearer ${token}`,
		        },
		      });
//		      console.log('Creators fetched successfully');
		      if (isMounted) {
		        setCreatorDataBackend(response.data);
		      }
		    } catch (error) {
		      console.error('Network error:', error);
		    }
		  };
	
		  fetchCreatorDataBackend();
		
		  return () => {
		    isMounted = false;  // set the flag to false when the component unmounts
		  }
	}, []);

	
	


	async function getAllCreatorsDataBlockchain() {
		console.log("amount to be donated :", parseFloat(ethers.utils.parseEther(donatingEther.toString())));
		if (typeof window.ethereum !== "undefined") {
		const provider = new ethers.providers.Web3Provider(window.ethereum);
      		const signer = provider.getSigner();
      		const contract = new ethers.Contract(
        		diamondAddress,
        		Diamond.abi,
        		signer
      		);
		const signerAddress = await signer.getAddress();
			const creatorsData = await contract.getAllCreatorsData();
			setCreators(creatorsData);
			}
		}

//	console.log(creators[0]);
//	console.log(creatorsDataBackend?.userRecords);

	



	const navigate = useNavigate();
	
	useEffect(() => {
		
        if (!token || !email || !role) {
		    navigate("/");
	          }

	}, [email, token, role]);
		
	
		return(
				
			<main role="main" className="col-lg-12 mx-auto" style={{ maxWidth: '600px', minHeight: '100vh' }}>
			{ token && email && role ?
				<a href="/mosaic" className="btn btn-primary"> Mosaic</a>
				:
				null
			}
			    <div id="content" className="mt-3">
			        {creators?.map(creator => (
			            <div key={creator?.creatorId} className="list-group-item list-group-item-action bg-dark text-white mb-2">
			                <a href={`bazaar/${creator?.creatorId}`} className="text-decoration-none text-white">
			                    <div className="d-flex justify-content-between align-items-center">
 			                       <div>
			                            <h5 className="mb-1">{creatorsDataBackend?.userRecords?.find(element => element.id === creator?.creatorId)?.name || "Unnamed Creator"}</h5>
			                        </div>
			                        <img src={creatorsDataBackend?.userRecords?.find(element => element.id === creator?.creatorId)?.profile || userImage} alt="Image Preview" className="img-fluid rounded" style={{ width: '100px' }} />
			                    </div>
		                    <div>Current Steez Price: £{parseFloat(creator?.steezPrice) / (10 ** 20)}</div>
		                    <div>Total Investors: {parseFloat(creator?.totalInvestors)}</div>
			                </a>
			            </div>
			        ))}
			    </div>
			</main>

		)
}

export default Baazar;
