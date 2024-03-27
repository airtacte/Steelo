require('dotenv').config();

import Web3 from "web3";
import WalletConnectProvider from "@walletconnect/react-native-dapp";

const web3 = new Web3(Web3.givenProvider);

// ... in your component or hook
const connectWallet = async () => {
  const provider = new WalletConnectProvider({
    rpc: { 1: `https://mainnet.infura.io/v3/${process.env.NEXT_PUBLIC_PROJECT_ID}` },
  });
  await provider.enable();
  web3.setProvider(provider);
};