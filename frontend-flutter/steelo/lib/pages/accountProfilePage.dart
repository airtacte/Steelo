import 'package:flutter/material.dart';
import 'package:steelo/utils/Constants.dart';

class AccountProfilePage extends StatelessWidget {
	AccountProfilePage ({ Key? key }) : super(key: key);
	Constants constants = Constants();

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: constants.mainYBGColor,
			appBar: AppBar(
				title: Text("Profile"),
				backgroundColor: constants.mainYellowColor,
				elevation: 0,

			),
			body: SingleChildScrollView(
				child: Column(
					children: [
						Card(
							child: Column(
								children: [
									Text("Account Address", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
									Text("0xDC4D2882fc6Bfd97bD3F162Ad20b17A719e12054", style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),),
									Text("Account Balance", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
									Text("ETH 0.0026", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
								],
							), 
						),	
					],
				),
			),
		);
	}
}
