import React, { useState, useContext, useRef, useEffect } from 'react';
import axios from 'axios';
import styles from "../App.module.css";
import AuthContext from "../context/AuthProvider";
import { useNavigate } from 'react-router-dom';
import imdb from "../assets/imdb.png";

interface Props {
	user: string;
	token: string;
	formData: {};
	setFormData: () => void;
	loggedin: boolean;
	setlogin: () => void;
}

function Signup( {user, token, formData, setFormData, loggedin, setlogin} : Props) {
	const { setAuth } = useContext(AuthContext);
	const userRef = useRef();
	const errRef = useRef();
	const [errMsg, setErrMsg] = useState("");
	const [success, setSuccess] = useState(false);
	const navigate = useNavigate();
	const [allUsers, setAllUsers] = useState([]);
	console.log(formData)	

	useEffect(() => {
		if (user) {
		setSuccess(true);
		setlogin(true);
		navigate("/");
	}

		userRef.current.focus();
	}, [])
	useEffect(() => {
		setErrMsg("")
	}, [formData.username, formData.password])

	const handleChange = (e) => {
		const { name, value } = e.target;
		setFormData({
			...formData,
			[name]: value,
		});
	};

	const handleSubmit = async (e) => {
    		e.preventDefault();

		try {
			const response = await axios.post("https://imdb-top-60-video-games-ezra.onrender.com/user/dj-rest-auth/registration/", formData);
			const token = response?.data?.key
			console.log(response.data);
			console.log(token);
			console.log(formData.username);
			console.log(formData.password);
			const user = formData.username;
			const pwd = formData.password
			console.log('Signup successful:', response.data);
			setAuth({ user, pwd, token});
			localStorage.setItem("user", user)
			localStorage.setItem("token", token);
			setSuccess(true);
			setlogin(true);
			navigate("/");

		} catch (err) {
			if (formData.password1 !== formData.password2) {
				setErrMsg("passwords do not match")
			}


			const passwordRegex = /^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[\W_]).{8,}$/;
			if (!passwordRegex.test(formData.password1)) {
				setErrMsg("Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character.");
			}

			const usernameRegex = /^[a-zA-Z0-9_]+$/;
			if (!usernameRegex.test(formData.username)) {
				setErrMsg("Username contains invalid characters.");
			}

			
			const isAllLetters = /^[a-zA-Z]+$/.test(formData.password1);
			const isAllNumbers = /^[0-9]+$/.test(formData.password1);
			const isAllSpecialCharacters = /^[!@#$%^&*()_+{}\[\]:;<>,.?~\\/-]+$/g.test(formData.password1);

			if (isAllLetters || isAllNumbers || isAllSpecialCharacters) {
				setErrMsg("Password should include a mix of letters, numbers, and special characters.");
			}
			const commonPasswords = ["password", "12345678", "qwerty", "admin", "87654321"];

			if (commonPasswords.includes(formData.password1.toLowerCase())) {
				setErrMsg("Password is too common. Please choose a stronger password.");
			}

			const getuser = async () => {
                        	const result = await axios.get("https://imdb-top-60-video-games-ezra.onrender.com/user/");
				setAllUsers(result.data);
				result.data.map(all => formData.username === all.username ? setErrMsg("user already exists") : null);
				allUsers.map(all => console.log(all.username));
			}
			getuser();
			if (formData.password1.length < 8 || formData.password2 < 8)
			{
				setErrMsg("password must be between 8 - 24 characters")
			}
			if (!formData.password1 || !formData.password2) {
				setErrMsg("You must input a password.");
			}
			if (!formData.username) {
				setErrMsg("you have to input a user name")
			}
			if (!err?.response) {
				setErrMsg("No server found")
			}
			if (err.response?.status === 401) {
                        setErrMsg("Unauthorized");
			}
		}
	};
	function remover() {
		localStorage.removeItem("user");
		localStorage.removeItem("token");
		setSuccess(false);
		setlogin(false);
	}

	return (
		<>
	  			{success ? (
				<div>
				<h1>You are Signed Up!</h1>
				<br />
				<p><button onClick={remover}>Log Out</button></p>
				</div>
			) : (
	    <div className={styles.form}>
	    <div className={styles.login}>
	    <a href="/"><img className={styles.loginimdb} src={imdb} /></a>
	<p className={styles.rederror}>{errMsg}</p>
      <h1 className={styles.formTitle}>Register</h1>
      <form onSubmit={handleSubmit}>
	<div className={styles.loginlabel}>
          <label>Your name</label>
	</div>
	<div>
          <input
		className={styles.logininput}
            	type="text"
            	name="username"
		ref={userRef}
		value={formData.username}
		autoComplete="off"
		onChange={handleChange}
          />
        </div>
        <div className={styles.loginlabel}>
          <label>Password</label>
	</div>
	<div>
          <input
	    className={styles.logininput}
            type="password"
            name="password1"
            value={formData.password1}
            onChange={handleChange}
          />
        </div>
        <div className={styles.loginlabel}>
          <label>Re-Enter Password</label>
	</div>
	<div>
          <input
	    className={styles.logininput}
            type="password"
            name="password2"
            value={formData.password2}
            onChange={handleChange}
          />
        </div>
        <button className={styles.loginbutton} type="submit">Create your IMDb account</button>
      </form>
    </div>
	</div>
		)}
	</>
  );
}

export default Signup;
