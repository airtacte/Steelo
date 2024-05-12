import React, { useState, useContext, useRef, useEffect } from 'react';
import axios, { AxiosResponse, AxiosError } from 'axios';
import styles from '../Components/Signup.module.css';
import { useNavigate } from 'react-router-dom';
import { ethers } from "ethers";
import Diamond from "../artifacts/steeloDiamond.json";

import {diamondAddress} from "../utils/constants";



interface Props {
	  user: string;
	  token: string;
	  formData: {
		      email: string;
		      password: string;
		    };
	  setFormData: any;
	  loggedin: boolean;
	  setlogin: React.Dispatch<React.SetStateAction<boolean>>;
	  response: any;
	  search: any;
	  setSearch: any;
	  setSelectedAbout: any;
	  setSelectedService: any;
	  selectedAbout: any;
	  selectedService: any; 
}

function Login({ email, token, formData, setFormData, loggedin, setlogin, response, search, setSearch, setSelectedAbout, setSelectedService, selectedAbout, selectedService, setEmail, setToken, role, setRole, userId, setUserId, userName, setUserName, profileId, fetchDiamond }: Props) {
	  const userRef = useRef(null);
	  const errRef = useRef(null);

	  const [errMsg, setErrMsg] = useState('');
	  const [success, setSuccess] = useState(false);
	  const navigate = useNavigate();
//	  console.log("userId :", userId);

	  useEffect(() => {
		      if (email && token && role) {
			            if (role == "user" && userId) {
   			            	navigate("/bazaar");
				    }
			            else if (role == "creator" && userId) {
					navigate(`/creator/${userId}`);
				    }
			            else if (role == "executive") {
					    navigate(`/admin`);
				    }
			      	    
			          }

		      if (userRef.current) {
			            userRef.current.focus();
			          }
		    }, [email, token, role, userId]);

	  useEffect(() => {
		      setErrMsg('');
		    }, [formData.email, formData.password]);

	  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
		      setFormData({
			            ...formData,
			            [e.target.name]: e.target.value,
			          });
		    };

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

	async function isExecutive() {
    	if (typeof window.ethereum !== "undefined") {
        	const provider = new ethers.providers.Web3Provider(window.ethereum);
        	const signer = provider.getSigner();
        	const contract = new ethers.Contract(
        	    diamondAddress,
        	    Diamond.abi,
        	    signer
        	);
        	const signerAddress = await signer.getAddress();
        	return await contract.isExecutive();  // Return the value directly
    	}
    	return null;  // Return null or throw an error if the environment is not correct
}

	  const handleSubmit = async (e) => {
    		e.preventDefault();
    		setErrMsg('');  // Reset error message at the start
    		try {
        		const response = await axios.post('http://localhost:9000/auth/login', formData);
        		const { token, role: roleData, name: userNameData, userId: userIdData } = response.data;
        		const profileId = await profileIdUser();  // Fetch profile ID before deciding navigation

        	if ((roleData === "user" || roleData == "creator")  && profileId !== userIdData) {
			try {
//            			await axios.delete(`http://localhost:9000/auth/${userIdData}`);
            			console.log("you are using different account use your original account");
				setErrMsg('you are using different account use your original account');
        		} catch (rollbackError) {
            			console.error("Rollback failed:", rollbackError);
        		}	
            		throw new Error("User profile ID mismatch.");
        	}
			const executive = await isExecutive();

		if (roleData == "executive" && !executive) {
			try {
//            			await axios.delete(`http://localhost:9000/auth/${userIdData}`);
            			console.log("you are using different account use your original account");
				setErrMsg('you are using different account use your original account')
        		} catch (rollbackError) {
            			console.error("Rollback failed:", rollbackError);
        		}	
            		throw new Error("User profile ID mismatch.");
			
		}

        	localStorage.setItem('name', userNameData);
		localStorage.setItem('email', formData.email);
		localStorage.setItem('token', token);
		localStorage.setItem('role', roleData);

        	setSuccess(true);
        	setlogin(true);
        	setEmail(formData.email);
        	setToken(token);
        	setRole(roleData);
        	setUserId(userIdData);
        	setUserName(userNameData);
		
		if (roleData == "executive") {
        		navigate(`/admin`);
		}
		else if (roleData == "creator") {
        		navigate(`/creator/${userIdData}`);
		}
		else if (roleData == "user") {
			navigate(`/bazaar`);
		}

    	} catch (err) {
		        if (!err?.response) {
//			      setErrMsg('No Server Response');
		      } else if (err.response.status === 400) {
		              setErrMsg(err?.response?.data);
		      } else if (err.response.status === 401) {
		              setErrMsg(err?.response?.data);
		      } else {
		              setErrMsg(err?.response?.data);
		      }
					        if (errRef.current) {
							        errRef.current.focus();
							      }
					      }
	}
	  function remover() {
		      localStorage.removeItem('email');
		      localStorage.removeItem('token');
		      setSuccess(false);
		      setlogin(false);
		    }
	document.title = "Sign In"
	  return (
		  	    <>
		        <link
		          href="https://fonts.googleapis.com/css2?family=Advent+Pro:wght@100;400&family=Aguafina+Script&family=Amatic+SC&family=Barrio&family=Bellota:wght@300&family=Black+Ops+One&family=Caveat&family=Chakra+Petch:ital,wght@1,300&family=Cinzel&family=Cookie&family=Croissant+One&family=Dancing+Script&family=Faster+One&family=Fuggles&family=Gugi&family=Hammersmith+One&family=Homemade+Apple&family=Itim&family=Lilita+One&family=Montserrat+Alternates:wght@100&family=Nothing+You+Could+Do&family=Orbitron&family=Playball&family=Rajdhani&family=Satisfy&family=Sedgwick+Ave+Display&family=Shadows+Into+Light&family=Space+Mono&family=Tilt+Prism&family=Yellowtail&display=swap"
		          rel="stylesheet"
		        />



		        {success ? (
				        <div className={styles.login}>
				          <h1 className={styles.logintitle}>You are logged In!</h1>
				          <br />
				          <p>
				            <button onClick={remover} className={styles.loginbutton}>Log Out</button>
					    <a className={styles.loggedlink} href="/"> Go to Home Page </a>
				          </p>
				        </div>
				      ) : (
					              <>
					                <div className={styles.login}>
					                  <h1 className={styles.logintitle}>Sign In</h1>
					                  <p
					                    className={errMsg ? `${styles.rederror}` : 'offscreen'}
					                    ref={errRef}
					                    aria-live="assertive"
					                  >
					                    <span className={styles.rederror}>{errMsg}</span>
					                  </p>
					                  <form onSubmit={handleSubmit}>
					                    <label className={styles.labeltitle}>Email</label>
					                    <input
					                      className="form-control"
					                      type="text"
					                      name="email"
					      		placeholder="email"
					                      ref={userRef}
					                      autoComplete="off"
					                      value={formData.email}
					                      onChange={handleChange}
					                    />
					                    <label className={styles.labeltitle}>Password</label>
					                    <input
					                      className="form-control"
					                      type="password"
					                      name="password"
					      		placeholder="password"
					                      value={formData.password}
					                      onChange={handleChange}
					                    />
					                    <button className={styles.loginbutton} type="submit">
					                      Signin
					                    </button>
					                 Create Steelo Account
							<a href="/signup" className={styles.loginbutton}>
					                      Signup
					                </a>
					                  </form>
					                </div>
					              </>
					            )}
		      </>
		    );
}

export default Login;
