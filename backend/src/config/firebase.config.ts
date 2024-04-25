import * as dotenv from 'dotenv';
dotenv.config();
import {getAuth, GoogleAuthProvider } from "firebase/auth";

export default {
 	firebaseConfig : {
  		apiKey: "AIzaSyBcCpZvLHspg1p1f-cyhmAs8SgW4oFvFoA",
  		authDomain: "steelo-testnet.firebaseapp.com",
  		databaseURL: "https://steelo-testnet-default-rtdb.europe-west1.firebasedatabase.app",
  		projectId: "steelo-testnet",
  		storageBucket: "steelo-testnet.appspot.com",
  		messagingSenderId: "856135872273",
  		appId: "1:856135872273:web:672d777b657ec33ca9e6b0",
  		measurementId: "G-8MHZM68TSX"
},
};

const provider = new  GoogleAuthProvider();
