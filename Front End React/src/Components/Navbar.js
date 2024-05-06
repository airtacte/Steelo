import React from 'react';
import bank from '../bank-2.png';
import styles from '../Components/Signup.module.css';

function Navbar({ account, setEmail, setToken }) {

	function remover() {
		      localStorage.removeItem('email');
		      localStorage.removeItem('token');
		      setEmail("");
		      setToken("");
//		      setSuccess(false);
//		      setlogin(false);
	}
    return (
        <nav className='navbar navbar-dark fixed-top shadow p-0' style={{ backgroundColor: 'black', height: '50px' }}>
            <div className='navbar-brand col-sm-3 col-md-2 mr-0' style={{ color: 'white' }}>
                <button onClick={remover} className={styles.loginbutton}>Log Out</button>
                <img src={bank} alt='Bank Logo' width='50' style={{ marginTop: '-10px' }} className='d-inline-block align-top' />
                <span>Steelo Defi</span>
            </div>
            {account && (
                <ul className='navbar-nav px-3'>
                    <li className='text-nowrap d-none nav-item d-sm-block'>
                        <small style={{ color: 'white' }}>
                            ACCOUNT NUMBER: {account}
                        </small>
                    </li>
                </ul>
            )}
        </nav>
    );
}

export default Navbar;

