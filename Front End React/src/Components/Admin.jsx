import React, { Component,  useEffect, useState } from 'react'
import tether from '../tether.png';
import { useNavigate } from 'react-router-dom';

function Admin ( { initiateAccess, email, token, initiate, initiateSteez } ) {

	const navigate = useNavigate();
	
	useEffect(() => {
		
        if (!token || !email) {
		    navigate("/");
	          }

	}, [email, token]);
		
	
		return(
			<main role='main' className='col-lg-12 ml-auto mr-auto' style={{ maxWidth: '600px', minHeight: '100vm' }}>
			<div id='content' className='mt-3'>
				Executive Page
			<button onClick={initiate}  className='btn btn-primary btn-lg btn-block'>
				 	Initiate Steelo
				</button>
			</div>
			<div id='content' className='mt-3'>
				Executive Page
			<button onClick={initiateSteez}  className='btn btn-primary btn-lg btn-block'>
				 	Initiate Steez
				</button>
			</div>
		</main>
		)
}

export default Admin;
