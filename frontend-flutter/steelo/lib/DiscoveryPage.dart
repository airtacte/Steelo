import 'package:flutter/material.dart';
import 'package:steelo/widgets/CustomButtonWidget.dart';
import 'package:steelo/utils/Constants.dart';


class DiscoveryPage extends StatelessWidget {
	DiscoveryPage({ Key? key}) : super(key: key);
	Constants constants =  Constants();

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: SafeArea( child: Padding(
				padding: const EdgeInsets.all(8.0),
				child: Column(
					children: [
							Text("Home Page"),
							customButtonWidget((){}, 3, constants.mainBlackColor, "Buy Now", constants.mainWhiteColor),
							Padding(
								padding: const EdgeInsets.all(8.0),
								child: customButtonWidget((){}, 25, constants.mainYellowColor, "connect wallet", constants.mainBlackColor),
								)
						],
						),
				)),
			);
	}
}
