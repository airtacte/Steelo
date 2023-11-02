import React from 'react';
import firebase from '../../services/firebase';

const SocialLogin = () => {
    const handleGoogleLogin = async () => {
        const provider = new firebase.auth.GoogleAuthProvider();
        try {
            await firebase.auth().signInWithPopup(provider);
            // Redirect or perform another action upon successful login.
        } catch (err) {
            console.error(err.message);
        }
    };

    return (
        <div>
            <h2>Social Login</h2>
            <button onClick={handleGoogleLogin}>Login with Google</button>
            {/* Add similar handlers for other social platforms like Twitter, Instagram, etc. */}
        </div>
    );
};

export default SocialLogin;
