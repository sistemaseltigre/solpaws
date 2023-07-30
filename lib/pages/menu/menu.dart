//Create menu view
import 'package:flutter/material.dart';
import 'package:solpaws/pages/mint-nft/mint_nft.dart';
import 'package:solpaws/pages/my-spaws/view_nft.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({
    Key? key,
  }) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    // Acceder a las variables publicKey y mainWallet aquí
    final Map<String, dynamic>? arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final publicKey = arguments?['publicKey'];
    final balance = arguments?['balance'];

    return Container(
      color: const Color(0xFF98D6BD),
      child: Scaffold(
        backgroundColor: const Color(0xFF98D6BD),
        appBar: AppBar(
          title: const Text('SolPaws'),
          backgroundColor: const Color(0xFF98D6BD),
        ),
        body: Center(
          child: Column(
            
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'User: ${publicKey.substring(0, 4)}...${publicKey.substring(publicKey.length - 4)}', // Reemplaza este valor con el wallet real
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Balance: $balance SOL", // Reemplaza este valor con el balance real
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  createNft();
                },
                child: const Text("Get SPaws"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            NFTScreen(walletAddress: publicKey)),
                  );
                },
                child: const Text("My SPaws"),
              ),
              ElevatedButton(
                onPressed: () {
                  // Lógica cuando se presiona el botón "Store"
                },
                child: const Text("Store"),
              ),
              ElevatedButton(
                onPressed: () {
                  // Lógica cuando se presiona el botón "Mini Game's"
                },
                child: const Text("Mini Game's"),
              ),
              ElevatedButton(
                onPressed: () {
                  // Lógica cuando se presiona el botón "Profile"
                },
                child: const Text("Profile"),
              ),
              ElevatedButton(
                onPressed: () {
                  // Lógica cuando se presiona el botón "Chat"
                },
                child: const Text("Chat"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
