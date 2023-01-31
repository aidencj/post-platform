import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:provider/provider.dart';

const String MY_ADDRESS = "0x10A6eBcD1B15bDBE70B5BDA7a4cf5F66285F7876";
const String MY_PRIVATE_KEY = "5dbba9cd80e3f63e015f7f1878570a6459376f5223a8efff0d40c7a0cab28758";
const String BLOCKCHAIN_URL = "http://127.0.0.1:8545";
const String CONTRACT_ADDRESS = "0x2B64c384c8378eDCcaF1CeD629Bb529aEc3e97a9";
const String CONTRACT_NAME = "PostNFT";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: const HomePage()
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch(selectedIndex) {
      case 0:
        page = CreatorPage();
        break;
      case 1:
        page = SearchPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: SafeArea(
            child: Scaffold(
              body: Row(
                children: [
                  SafeArea(
                    child: NavigationRail(
                      extended: constraints.maxWidth >= 600,
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.create),
                          label: Text('Create'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.search),
                          label: Text('Search'),
                        ),
                      ],
                      selectedIndex: selectedIndex,
                      onDestinationSelected: (value) {

                        setState(() {
                          selectedIndex = value;
                        });

                      },
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: page,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}

class CreatorPage extends StatefulWidget {
  const CreatorPage({super.key});

  @override
  State<CreatorPage> createState() => _CreatorPageState();
}

class _CreatorPageState extends State<CreatorPage> {
  // Create a text controller and use it to retrieve the current value
  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: myController,
            minLines: 1,
            maxLines: 10,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              hintText: 'Write something...',
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            post(myController.text);
            myController.clear();
          },
          child: const Icon(Icons.send),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }
  
  Future<void> post(dynamic postContext) async {
    //obtain private key for write operation
    Credentials key = EthPrivateKey.fromHex(MY_PRIVATE_KEY);

    //obtain our contract from abi in json file
    final contract = await BlockChain.getContract();

    // extract function from json file
    final function = contract.function("post");

    //send transaction using the our private key, function and contract
    await BlockChain.ethClient.sendTransaction(
        key,
        Transaction.callContract(
            contract: contract,
            function: function,
            parameters: [EthereumAddress.fromHex(MY_ADDRESS), postContext]
        ),
        chainId: 4
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
 
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchResult = "";

  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: myController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  hintText: 'Token ID',
                ),
              ),
            ),
            if (searchResult.isNotEmpty)
              BigCard(postContext: searchResult,),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            getPostContext(BigInt.parse(myController.text));
          },
          child: const Icon(Icons.search),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  Future<List<dynamic>> callFunction(String name, List<dynamic> params) async {
    final contract = await BlockChain.getContract();
    final function = contract.function(name);
    final result = await BlockChain.ethClient
        .call(contract: contract, function: function, params: (params.isEmpty? []: params));
    return result;
  }

  Future<void> getPostContext(BigInt tokenID) async {
    List<dynamic> result = await callFunction("tokenURI", [tokenID]);
    searchResult = result[0];

    setState(() {});
  }
}

class BlockChain {
  static Client httpClient = Client();
  static Web3Client ethClient = Web3Client(BLOCKCHAIN_URL, httpClient);

  static Future<DeployedContract> getContract() async {
    String abiFile = await rootBundle.loadString("assets/contract.json");
    final contract = DeployedContract(ContractAbi.fromJson(abiFile, CONTRACT_NAME),
        EthereumAddress.fromHex(CONTRACT_ADDRESS));
    return contract;
  }
}


class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.postContext,
  });

  final String postContext;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
      fontSize: 25,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          postContext,
          style: style,
        ),
      ),
    );
  }
}