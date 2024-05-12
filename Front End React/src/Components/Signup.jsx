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

function SignUp({ email, token, formData, setFormData, loggedin, setlogin, response, search, setSearch, setSelectedAbout, setSelectedService, selectedAbout, selectedService, setEmail, setToken, role, setRole, userId, setUserId, userName, setUserName }: Props) {
	  const userRef = useRef(null);
	  const errRef = useRef(null);

	  const [errMsg, setErrMsg] = useState('');
	  const [success, setSuccess] = useState(false);
	  const [selectedRole, setSelectedRole] = useState("");
	  const navigate = useNavigate();

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
		    }, [formData.name, formData.email, formData.password]);

	  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
		      setFormData({
			            ...formData,
			            [e.target.name]: e.target.value,
			          });
		    };
	const handleChangeRole = (event) => {
	    setSelectedRole(event.target.value);
	  };

	
	async function createSteeloUser( profileId) {
		if (typeof window.ethereum !== "undefined") {
      		const provider = new ethers.providers.Web3Provider(window.ethereum);
      		const signer = provider.getSigner();
      		const contract = new ethers.Contract(
        		diamondAddress,
        		Diamond.abi,
        		signer
      		);
		const signerAddress = await signer.getAddress();
			await contract.createSteeloUser( profileId);
		}
	}

	
	


	async function createCreator( creatorId ) {
		if (typeof window.ethereum !== "undefined") {
      		const provider = new ethers.providers.Web3Provider(window.ethereum);
      		const signer = provider.getSigner();
      		const contract = new ethers.Contract(
        		diamondAddress,
        		Diamond.abi,
        		signer
      		);
		const signerAddress = await signer.getAddress();
			await contract.createCreator( creatorId );
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

	  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
		      e.preventDefault();

		      try {
			            const response = await axios.post(`http://localhost:9000/auth/register/${selectedRole}`, formData);
 
			            const token = response?.data?.token;
			      	    const roleData = response?.data?.role;
				    const userNameData = response?.data?.name;
			      	    const userIdData = response?.data?.userId;
			            const email = formData.email;
			            const password = formData.password;
			            



				try {
//				    console.log("role :", roleData);
			            if (roleData == "executive") {
					try {
						await createSteeloUser( userIdData);
						await initiate();
			      	    		navigate(`/admin`);
					} catch (error) {
						console.log("blockchain error :", error.data.message);	
						setErrMsg(error.data.message);
						throw error;
					}
				    }
			      	    else if (roleData == "creator") {
					try {
				    		await createCreator(userIdData);
						navigate(`/creator/${userIdData}`);
					} catch (error) {
						console.log("blockchain error :", error.data.message);	
						setErrMsg(error.data.message);
						throw error;
					}
				    }
			      	    else if (roleData == "user") {
					try {
						await createSteeloUser( userIdData);
						navigate(`/bazaar`);
					} catch (error) {
						console.log("blockchain error :", error.data.message);	
						setErrMsg(error.data.message);
						throw error;
					}
				    }
			      	    else {
					navigate("/1");
				    }
				} catch (innerError) {
        				console.error("Failed to create user-specific data:", innerError);
					try {
            					await axios.delete(`http://localhost:9000/auth/${userIdData}`);
            					console.log("account deleted because account is not recognized in the blockchain");
        				} catch (rollbackError) {
            					console.error("Rollback failed:", rollbackError);
        				}
        				throw innerError;
    				}
//				    console.log(response);
			      	    localStorage.setItem('name', userNameData);
			      	    localStorage.setItem('email', email);
			            localStorage.setItem('token', token);
			            localStorage.setItem('role', roleData);
			            setSuccess(true);
			            setlogin(true);
			      	    setEmail(email);
			      	    setToken(token);
			            setRole(roleData);
			            setUserId(userIdData)
			            setUserName(userNameData);
//			            console.log("token :", token);
//			      	    console.log("role :", roleData);
//			      	    console.log("userId :", userIdData);
//			            console.log("userName", userNameData);




			          } catch (err) {
					        if (!err?.response) {
						        setErrMsg(err?.response?.data);
						} else if (err.response.status === 400) {
							console.log(err?.response?.data);
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
	document.title = "Sign Up"
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
					                  <h1 className={styles.logintitle}>Sign Up</h1>
					                  <p
					                    className={errMsg ? `${styles.rederror}` : 'offscreen'}
					                    ref={errRef}
					                    aria-live="assertive"
					                  >
					                    <span className={styles.rederror}>{errMsg}</span>
					                  </p>
					                  <form onSubmit={handleSubmit}>
					                    <label className={styles.labeltitle}>Name</label>
					                    <input
					                      className="form-control"
					                      type="text"
					                      name="name"
					      		placeholder="name"
					                      ref={userRef}
					                      autoComplete="off"
					                      value={formData.name}
					                      onChange={handleChange}
					                    />
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
					      	<div>
						      <h1>Select Your Role:</h1>
						      <select value={selectedRole} onChange={handleChangeRole}>
					                <option value="" disabled>Choose Role</option>
						        <option value="user">User</option>
						        <option value="creator">Creator</option>
						        <option value="executive">Executive</option>
						      </select>
						      <p>{selectedRole && <span>Selected Role: {selectedRole}</span>}</p>
						    </div>
					                    <button className={styles.loginbutton} type="submit">
					                      Sign Up
					                    </button>
					                  </form>
					                </div>
					              </>
					            )}
		      </>
		    );
}

export default SignUp;
