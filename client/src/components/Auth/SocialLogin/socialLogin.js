import firebase from "../../services/firebase";
import { ethers } from "ethers";
import { SafeFactory } from "@safe-global/safe-core-sdk";

// Assuming you have initialized your Firebase and ethers providers
const provider = new ethers.providers.Web3Provider(window.ethereum);
const safeFactory = await SafeFactory.create({
  ethAdapter: new EthersAdapter({ ethers, provider }),
});

const SocialLogin = async () => {
  const provider = new firebase.auth.GoogleAuthProvider();
  try {
    const result = await firebase.auth().signInWithPopup(provider);
    const user = result.user;

    // Check if the user already has a linked Safe wallet
    const userId = user.uid;
    const userRef = firebase.database().ref(`/users/${userId}`);
    const snapshot = await userRef.once("value");
    let safeAddress = snapshot.val()?.safeAddress;

    if (!safeAddress) {
      // Create a new Safe wallet for the user
      const owners = [user.uid]; // Example owner, adjust according to your needs
      const threshold = 1;
      const safeAccountConfig = { owners, threshold };
      const safeSdk = await safeFactory.deploySafe({ safeAccountConfig });
      safeAddress = safeSdk.getAddress();

      // Link the new Safe wallet to the user's Firebase account
      userRef.update({ safeAddress });
    }

    // Redirect or perform another action upon successful login and Safe creation/linking
  } catch (err) {
    console.error(err.message);
  }
};
