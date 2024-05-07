import React, { Component,  useEffect, useState } from 'react'
import tether from '../tether.png';
import { useNavigate } from 'react-router-dom';

function Admin ( { initiateAccess } ) {

	
		return(
			<main role='main' className='col-lg-12 ml-auto mr-auto' style={{ maxWidth: '600px', minHeight: '100vm' }}>
			<div id='content' className='mt-3'>
				Executive Page
			<button onClick={initiateAccess}  className='btn btn-primary btn-lg btn-block'>
				 	Initiate Access Control
				</button>
			</div>
		</main>
		)
}

export default Admin;
