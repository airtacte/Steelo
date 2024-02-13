// 1 - Install the depenedencies and import them as per all following steps
import { StatusBar } from 'expo-status-bar';
import { StyleSheet, Text, View } from 'react-native';
import SafeApiKit from '@safe-global/api-kit'
import Safe, { SafeFactory } from '@safe-global/protocol-kit'
import { ContractNetworksConfig } from '@safe-global/protocol-kit'
import { SafeAccountConfig } from '@safe-global/protocol-kit'
import { SafeTransactionOptionalProps } from '@safe-global/protocol-kit'
import { MetaTransactionData } from '@safe-global/safe-core-sdk-types'

const safeService = new SafeApiKit({ chainId })
const safeSdk = await Safe.create({ ethAdapter, safeAddress })
const safeVersion = '1.4.1'
const safeFactory = await SafeFactory.create({ ethAdapter, safeVersion })

export default function App() {
  return (
    <View style={styles.container}>
      <Text>Open up App.js to start working on your app!</Text>
      <StatusBar style="auto" />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
});

// 2 - Initialize the Safe SDK
const safeService = new SafeApiKit({
  chainId,
  txServiceUrl: 'https://txServiceUrl.com'
})

const chainId = await ethAdapter.getChainId()
const contractNetworks: ContractNetworksConfig = {
  [chainId]: {
    safeSingletonAddress: '<SINGLETON_ADDRESS>',
    safeProxyFactoryAddress: '<PROXY_FACTORY_ADDRESS>',
    multiSendAddress: '<MULTI_SEND_ADDRESS>',
    multiSendCallOnlyAddress: '<MULTI_SEND_CALL_ONLY_ADDRESS>',
    fallbackHandlerAddress: '<FALLBACK_HANDLER_ADDRESS>',
    signMessageLibAddress: '<SIGN_MESSAGE_LIB_ADDRESS>',
    createCallAddress: '<CREATE_CALL_ADDRESS>',
    simulateTxAccessorAddress: '<SIMULATE_TX_ACCESSOR_ADDRESS>',
    safeSingletonAbi: '<SINGLETON_ABI>', // Optional. Only needed with web3.js
    safeProxyFactoryAbi: '<PROXY_FACTORY_ABI>', // Optional. Only needed with web3.js
    multiSendAbi: '<MULTI_SEND_ABI>', // Optional. Only needed with web3.js
    multiSendCallOnlyAbi: '<MULTI_SEND_CALL_ONLY_ABI>', // Optional. Only needed with web3.js
    fallbackHandlerAbi: '<FALLBACK_HANDLER_ABI>', // Optional. Only needed with web3.js
    signMessageLibAbi: '<SIGN_MESSAGE_LIB_ABI>', // Optional. Only needed with web3.js
    createCallAbi: '<CREATE_CALL_ABI>', // Optional. Only needed with web3.js
    simulateTxAccessorAbi: '<SIMULATE_TX_ACCESSOR_ABI>' // Optional. Only needed with web3.js
  }
}

const safeFactory = await SafeFactory.create({ ethAdapter, contractNetworks })

const safeSdk = await Safe.create({ ethAdapter, safeAddress, contractNetworks })

// 3 - Deploy a new Safe
const safeAccountConfig: SafeAccountConfig = {
  owners: ['0x...', '0x...', '0x...'] // list of 3 owners
  threshold: 2, // 2 out of 3 owners are needed to confirm a transaction
  // ... (optional params)
}
const safeSdk = await safeFactory.deploySafe({ safeAccountConfig })

// 4 - Create a transaction
const transactions: MetaTransactionData[] = [
  {
    to,
    data,
    value,
    operation
  },
  {
    to,
    data,
    value,
    operation
  }
  // ...
]

const options: SafeTransactionOptionalProps = {
  safeTxGas, // Optional
  baseGas, // Optional
  gasPrice, // Optional
  gasToken, // Optional
  refundReceiver, // Optional
  nonce // Optional
}

const safeTransaction = await safeSdk.createTransaction({ transactions, options })

const nonce = await safeService.getNextNonce(safeAddress)

// 5 - Propose the transaction to the Safe Transaction Service
const safeTxHash = await safeSdk.getTransactionHash(safeTransaction)
const senderSignature = await safeSdk.signHash(safeTxHash)
await safeService.proposeTransaction({
  safeAddress,
  safeTransactionData: safeTransaction.data,
  safeTxHash,
  senderAddress,
  senderSignature: senderSignature.data,
  origin
})

// 6 - Get the transaction from the Safe Transaction Service
const pendingTxs = await safeService.getPendingTransactions(safeAddress)
const tx = await safeService.getTransaction(safeTxHash)

// 7 - Confirm/Reject the transaction
const hash = transaction.safeTxHash
let signature = await safeSdk.signHash(hash)
await safeService.confirmTransaction(hash, signature.data)

// 8 - Execute the transaction
const safeTransaction = await safeService.getTransaction(...)
const isValidTx = await safeSdk.isValidTransaction(safeTransaction)
const executeTxResponse = await safeSdk.executeTransaction(safeTransaction)
const receipt = executeTxResponse.transactionResponse && (await executeTxResponse.transactionResponse.wait())

// 9 - Interface checks
const isTransactionSignedByAddress = (
  signerAddress: string,
  transaction: SafeMultisigTransactionResponse
) => {
  const confirmation = transaction.confirmations.find(
    (confirmation) => confirmation.owner === signerAddress
  )
  return !!confirmation
}

const isTransactionExecutable = (
  safeThreshold: number,
  transaction: SafeMultisigTransactionResponse
) => {
  return transaction.confirmations.length >= safeThreshold
}