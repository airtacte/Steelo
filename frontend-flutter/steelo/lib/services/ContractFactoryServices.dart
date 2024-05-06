
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:steelo/utils/Constants.dart';
import 'dart:convert';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:url_launcher/url_launcher.dart';

class ContractFactoryServices extends ChangeNotifier {
  Constants constants = Constants();

  String? authors;
  bool authorsLoading = true;
  String? Account;
  String? name;

  Web3Client? _client;
  String? _abiCode;
  EthereumAddress? _contractAddress;
  DeployedContract? _contract;
  final String privateKey = "0x35f3261cc418b10d894f0c73a5d84412fc23c421a0aa4558de1218c271259afd";
  BigInt oneEtherInWei = BigInt.from(2) * BigInt.from(10).pow(18);
  String role = "ADMIN_ROLE";
  String address = "0x27d5F1Ce16C68a3e1840ff3BA2F77fDEff69BE65";

  ContractFactoryServices(){
    _setUpNetwork();
  }

// final connector = WalletConnect(
//    bridge: 'https://bridge.walletconnect.org',
//    clientMeta: PeerMeta(
//      name: 'Steelo',
//      description: 'Decentralized socialfi',
//      url: 'https://steelo.io',
//      icons: [
//        'https://assets-global.website-files.com/64772e383f3cad7c4ffc0c52/64ac1876175e18d155887521_Banner%20Logo%20v0.3-p-500.png'
//      ],
//    ),
//  );

//  connectWallet() async {
//    if (!connector.connected) {
//      await connector.createSession(onDisplayUri: (uri) async {
//        final Uri url = Uri.parse(uri);
//        print(url);
//        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
//          throw Exception('Could not launch $url');
//        }
//      });
//    }
//  }

  _setUpNetwork() async {
    _client = Web3Client(constants.NETWORK_HTTPS_RPC, http.Client(), socketConnector: () {
      return IOWebSocketChannel.connect(constants.NETWORK_HTTPS_RPC).cast<String>();
    });

    await _fetchABIAndContractAddress();
    await _getDeployedContract();
    await _getAuthors();
    await initiate();
    await initiateSteelo();
    await grantRole(role, address);
    await initiateTGE();
    await _getName();
    await convertEtherToSteelo(oneEtherInWei);
    await steeloTransfer(address, 10);
    await steeloBalanceOf(address);
  }

  Future<void> _fetchABIAndContractAddress() async {
    String abiFileRoot = await rootBundle.loadString(constants.CONTRACT_ABI_PATH);
    var abiJsonFormat = jsonDecode(abiFileRoot);
    _abiCode = jsonEncode(abiJsonFormat["abi"]);
    _contractAddress = EthereumAddress.fromHex(constants.CONTRACT_ADDRESS);
  }

  Future<void> _getDeployedContract() async {
    _contract = DeployedContract(ContractAbi.fromJson(_abiCode!, "steeloDiamond"), _contractAddress!);
  }

  Future<void> _getAuthors() async {
    List<dynamic> authorData = await _client!.call(contract: _contract!, function: _contract!.function("authors"), params: []);
    if (authorData[0].length > 0) {
      authors = authorData[0];
      print(authors);
      authorsLoading = false;
    } else {
      authorsLoading = true;
    }
    notifyListeners();  // Ensure UI updates when author data changes.
  }


Future<bool> initiate() async {
  try {
    // Ensure the client and contract are initialized
    if (_client == null || _contract == null) {
      print("Client or contract not initialized");
      return false;
    }

    // Convert the private key string to Ethereum private key credentials
    final credentials = EthPrivateKey.fromHex(privateKey);

    // Get the function from the ABI
    final initiateFunction = _contract!.function('initialize');

    // Perform the transaction
    final result = await _client!.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: _contract!,
        function: initiateFunction,
        parameters: [],
      ),
      chainId: 1337,
    );

    print("Transaction successful: $result");
    return true;
  } catch (e) {
    print("Failed to initiate Steelo: $e");
    return false;
  }
}




Future<bool> initiateSteelo() async {
  try {
    // Ensure the client and contract are initialized
    if (_client == null || _contract == null) {
      print("Client or contract not initialized");
      return false;
    }

    // Convert the private key string to Ethereum private key credentials
    final credentials = EthPrivateKey.fromHex(privateKey);

    // Get the function from the ABI
    final initiateFunction = _contract!.function('steeloInitiate');

    // Perform the transaction
    final result = await _client!.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: _contract!,
        function: initiateFunction,
        parameters: [],
      ),
      chainId: 1337,
    );

    print("Transaction successful: $result");
    return true;
  } catch (e) {
    print("Failed to initiate Steelo: $e");
    return false;
  }
}

Future<bool> initiateTGE() async {
  try {
    // Ensure the client and contract are initialized
    if (_client == null || _contract == null) {
      print("Client or contract not initialized");
      return false;
    }

    // Convert the private key string to Ethereum private key credentials
    final credentials = EthPrivateKey.fromHex(privateKey);

    // Get the function from the ABI
    final initiateFunction = _contract!.function('steeloTGE');

    // Perform the transaction
    final result = await _client!.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: _contract!,
        function: initiateFunction,
        parameters: [],
      ),
      chainId: 1337,
    );

    print("Transaction successful: $result");
    return true;
  } catch (e) {
    print("Failed to initiate Steelo: $e");
    return false;
  }
}

   Future<void> _getName() async {
    List<dynamic> nameData = await _client!.call(contract: _contract!, function: _contract!.function("steeloName"), params: []);
    if (nameData[0].length > 0) {
      name = nameData[0];
      print(name);
      authorsLoading = false;
    } else {
      authorsLoading = true;
    }
    notifyListeners();  // Ensure UI updates when author data changes.
  }

Future<bool> grantRole(String role, String accountAddress) async {
  try {
    if (_client == null || _contract == null) {
      print("Client or contract not initialized");
      return false;
    }

    final credentials = EthPrivateKey.fromHex(privateKey);
    final grantRoleFunction = _contract!.function('grantRole');

    // Convert the account address from string to EthereumAddress
    final address = EthereumAddress.fromHex(accountAddress);

    var transaction = Transaction.callContract(
      contract: _contract!,
      function: grantRoleFunction,
      parameters: [role, address],
      maxGas: 900000 // Adjust gas limit as needed
    );

    final result = await _client!.sendTransaction(
      credentials,
      transaction,
      chainId: 1337, // Adjust chain ID as necessary
    );

    print("Transaction successful, hash: $result");
    return true;
  } catch (e) {
    print("Failed to grant role: $e");
    return false;
  }
}
  


  Future<bool> convertEtherToSteelo(BigInt amountInWei) async {
  try {
    if (_client == null || _contract == null) {
      print("Client or contract not initialized");
      return false;
    }

    final credentials = EthPrivateKey.fromHex(privateKey);
    final convertFunction = _contract!.function('convertEtherToSteelo');

    var transaction = Transaction.callContract(
      contract: _contract!,
      function: convertFunction,
      parameters: [],
      value: EtherAmount.inWei(amountInWei),
      maxGas: 100000 // Set an appropriate gas limit
    );

    final result = await _client!.sendTransaction(
      credentials,
      transaction,
      chainId: 1337, // Specify the correct chain ID here
    );

    print("Transaction successful, hash: $result");
    return true;
  } catch (e) {
    print("Failed to convert Ether to Steelo: $e");
    return false;
  }
}

   Future<bool> steeloTransfer(String to, int amount) async {
  try {
    // Ensure the client and contract are initialized
    if (_client == null || _contract == null) {
      print("Client or contract not initialized");
      return false;
    }

    // Convert the private key string to Ethereum private key credentials
    final credentials = EthPrivateKey.fromHex(privateKey);

    // Get the function from the ABI
    final transferFunction = _contract!.function('steeloTransfer');

    // Convert the amount to the appropriate format
     final amountBigInt = BigInt.from(amount); // Convert amount to wei

    // Convert the 'to' address to EthereumAddress
    final toAddress = EthereumAddress.fromHex(to);

    // Perform the transaction
    final result = await _client!.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: _contract!,
        function: transferFunction,
        parameters: [toAddress, amountBigInt],
      ),
      chainId: 1337,
    );

    print("Transaction successful: $result");
    return true;
  } catch (e) {
    print("Failed to perform steeloTransfer: $e");
    return false;
  }
}

Future<BigInt> steeloBalanceOf(String account) async {
  try {
    // Ensure the client and contract are initialized
    if (_client == null || _contract == null) {
      print("Client or contract not initialized");
      return BigInt.zero; // Return zero as default value
    }

    // Get the function from the ABI
    final balanceOfFunction = _contract!.function('steeloBalanceOf');

    // Convert the 'account' address to EthereumAddress
    final accountAddress = EthereumAddress.fromHex(account);

    // Call the function to get the balance
    List<dynamic> result = await _client!.call(
      contract: _contract!,
      function: balanceOfFunction,
      params: [accountAddress],
    );

    // Extract the balance from the result
    BigInt balance = result[0] as BigInt;

    print("Balance of $account: $balance");
    return balance;
  } catch (e) {
    print("Failed to get balance: $e");
    return BigInt.zero; // Return zero as default value
  }
}

  
}

