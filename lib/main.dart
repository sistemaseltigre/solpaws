import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:solana_web3/solana_web3.dart' as web3;
import 'package:solpaws/pages/menu/menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => const MyHomePage(),
        '/menu': (context) => const MenuPage(),
      },
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.purple,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {

  const MyHomePage({super.key});
  
  @override
  State<MyHomePage> createState() => _MyHomePageState();

}

class _MyHomePageState extends State<MyHomePage> {

  bool _hasWallet = false;

  @override
  void initState() {
    super.initState();
    createOrLoadWallet();
  }
  //Main variables
  final storage = const FlutterSecureStorage();
  static const String solanaWalletKeyFlutterStorage = 'solana_solpaws_wallet';
  late web3.Keypair mainWallet;
  late double balance;
  late String mainWalletPublicKey;
  final connection = web3.Connection(web3.Cluster.devnet);
  bool _creatingWallet = false;


  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/w.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: _hasWallet
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      mainWalletPublicKey,
                      style: const TextStyle(fontSize: 10.0),
                    ),
                    Text(
                      "Balance: $balance SOL",
                      style: const TextStyle(fontSize: 10.0),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/menu',arguments: {
                        'publicKey': mainWalletPublicKey,
                        'mainWallet': mainWallet,
                        'balance': balance,
                        },
                      ),
                      child: const Text("Play"),
                    ),
                  ],
                )
              : ElevatedButton(
                  child: Text(
                    _creatingWallet ? "Creating profile" : "Start",
                    style: const TextStyle(fontSize: 20.0),
                  ),
                  onPressed: () {
                    setState(() {
                      _creatingWallet = true;
                    });
                    createOrLoadWallet(); // Call the function to create/load the wallet
                  },
                ),
        ),     
      ),
    );
  }

  //Load or create wallet
   Future<void> createOrLoadWallet() async {  
    
    // Get main wallet key from storage
    final mainWalletKey = await storage.read(key: solanaWalletKeyFlutterStorage);

    if (mainWalletKey != "" && mainWalletKey != null) {      

      // Decode key
      final decodeKey = web3.base58Decode(mainWalletKey);
    
      // Get private key 32 bytes
      final privKeyBytes = decodeKey.sublist(decodeKey.length - 32);

      // Create wallet
      mainWallet = web3.Keypair.fromSeedSync(privKeyBytes);  

    }else{
      // Create wallet
      final mainWalletTmp = web3.Keypair.generateSync();

      // Save wallet key to storage
      await storage.write(
        key: solanaWalletKeyFlutterStorage,
        value: web3.base58Encode(mainWalletTmp.secretKey),
      );

      // Get main wallet key from storage
      final mainWalletKeyTmp = await storage.read(key: solanaWalletKeyFlutterStorage);

      // Decode key
      final decodeKeyTmp = web3.base58Decode(mainWalletKeyTmp!);
    
      // Get private key 32 bytes
      final privKeyBytesTmp = decodeKeyTmp.sublist(decodeKeyTmp.length - 32);

      // Create wallet
      mainWallet = web3.Keypair.fromSeedSync(privKeyBytesTmp);  

    }


      
    // Get public key
    mainWalletPublicKey = mainWallet.publicKey.toBase58().toString();
    
    // Get balance
    balance = await connection.getBalance(mainWallet.publicKey)/web3.lamportsPerSol;
    
    // Check if the main wallet key exists in storage
    _hasWallet = true;

  }

}
