import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:steelo/pages/DiscoveryPage.dart';
import 'package:steelo/services/ContractFactoryServices.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ContractFactoryServices>(create: (context) => ContractFactoryServices(),
      child: MaterialApp(
      title: 'Steelo',
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: DiscoveryPage(),
    ), 
    );
    }
}


