import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:steelo/utils/Constants.dart';
import 'dart:convert';

class ContractFactoryServices extends ChangeNotifier {

	Constants constants = Constants();

	Web3Client? _client;
	String? _abiCode;
	EthereumAddress? _contractAddress;
	DeployedContract ? _contract;

	ContractFactoryServices(){
		_setUpNetwork();
	}
	_setUpNetwork() async {
	
		_client = Web3Client(constants.NETWORK_HTTPS_RPC, Client(), socketConnector: (){
			return IOWebSocketChannel.connect(constants.NETWORK_HTTPS_RPC).cast<String>();
		});


		Future <void> _fetchABIAndContractAddress() async{
			String abiFileRoot = await rootBundle.loadString(constants.CONTRACT_ABI_PATH);
			var abiJsonFormat = jsonDecode(abiFileRoot);
			_abiCode = jsonEncode(abiJsonFormat["abi"]);
			print(_abiCode);


		}


		_contractAddress = EthereumAddress.fromHex(constants.CONTRACT_ADDRESS);

		print(_contractAddress);

		Future<void> _getDeployedContract() async {
		_contract = DeployedContract(ContractAbi.fromJson(_abiCode!, "steeloDiamond"), _contractAddress!);
		print(_contract);
			
		}

		_getAuthors () async {
			List<dynamic> authors = await _client!.call(contract: _contract!, function: _contract!.function("authors"), params: []);
			print(authors);
		}


		await _fetchABIAndContractAddress();
		await _getDeployedContract();
		await _getAuthors();
	}
}
