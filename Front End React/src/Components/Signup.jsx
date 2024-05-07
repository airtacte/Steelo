import React, { useState, useContext, useRef, useEffect } from 'react';
import axios, { AxiosResponse, AxiosError } from 'axios';
import styles from '../Components/Signup.module.css';
import { useNavigate } from 'react-router-dom';



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

function SignUp({ email, token, formData, setFormData, loggedin, setlogin, response, search, setSearch, setSelectedAbout, setSelectedService, selectedAbout, selectedService, setEmail, setToken, role, setRole, userId, setUserId, userName, setUserName, createCreator, createSteeloUser, initiateAccess }: Props) {
	  const userRef = useRef(null);
	  const errRef = useRef(null);

	  const [errMsg, setErrMsg] = useState('');
	  const [success, setSuccess] = useState(false);
	  const [selectedRole, setSelectedRole] = useState("");
	  const navigate = useNavigate();

	  useEffect(() => {
		      if (email && token) {
			            setSuccess(true);
			            setlogin(true);
				    navigate("/1");
			          }

		      if (userRef.current) {
			            userRef.current.focus();
			          }
		    }, [email, token]);

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
			            if (roleData == "executive") {
					try {
						await initiateAccess();
			      	    		navigate(`/admin/${userIdData}`);
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
            					console.log("This account is not recognized in the blockchain");
        				} catch (rollbackError) {
            					console.error("Rollback failed:", rollbackError);
        				}
        				throw innerError;
    				}
				    console.log(response);
			      	    localStorage.setItem('email', email);
			            localStorage.setItem('token', token);
			            setSuccess(true);
			            setlogin(true);
			      	    setEmail(email);
			      	    setToken(token);
			            setRole(roleData);
			            setUserId(userIdData)
			            setUserName(userNameData);
			            console.log("token :", token);
			      	    console.log("role :", roleData);
			      	    console.log("userId :", userIdData);
			            console.log("userName", userNameData);




			          } catch (err) {
					        if (!err?.response) {
//						        setErrMsg('No Server Response');
						} else if (err.response.status === 400) {
						        setErrMsg('Invalid Credentials or account already exists');
						} else if (err.response.status === 401) {
						        setErrMsg('Unauthorized');
						} else {
						        setErrMsg('Login Failed');
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
					                      className={styles.titleinput}
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
					                      className={styles.titleinput}
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
					                      className={styles.titleinput}
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
