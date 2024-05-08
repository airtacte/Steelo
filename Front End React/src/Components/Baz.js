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
		      const fetchCreatorDataBackend = async () => {
			            try {
					            const response = await axios.get(`http://localhost:9000/auth`, {
							              headers: {
									                  'Content-Type': 'application/json',
									                  Authorization: `Bearer ${token}`,
									                },
							            });

					            console.log('Creators fetched successfully');

						    setCreatorDataBackend(response.data);
					          } catch (error) {
							          console.error('Network error:', error);
							        }
			          };

		      fetchCreatorDataBackend();
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

	console.log(creators[0]?.creatorAddress);
	console.log(creatorsDataBackend?.userRecords);

	



	const navigate = useNavigate();
	
	useEffect(() => {
		
        if (!token || !email || !role) {
		    navigate("/");
	          }

	}, [email, token, role]);
		
	
		return(
			<main role='main' className='col-lg-12 ml-auto mr-auto' style={{ maxWidth: '600px', minHeight: '100vm' }}>
			<div id='content' className='mt-3'>
			{
				creators?.map(creator => <li key={creator?.creatorId} style={{ color: "white"}}>
					<a href={`bazaar/${creator?.creatorId}`}>
					{creator?.creatorAddress}
					<img src={creatorsDataBackend?.userRecords?.find(element => element.id == creator?.creatorId).profile ? creatorsDataBackend?.userRecords?.find(element => element.id == creator?.creatorId).profile : userImage} alt="Image Preview" className={styl.previewImage} />
					<p>{creatorsDataBackend?.userRecords?.find(element => element.id == creator?.creatorId).name ? creatorsDataBackend?.userRecords?.find(element => element.id == creator?.creatorId).name : "Unnamed Creator"}</p>
					</a>
					</li>)
			}
			</div>
		</main>
		)
}

export default Baazar;
