import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:solpaws/pages/my-spaws/nft_details_screen.dart';

class NFT {
  final String name;
  final String description;
  final String tokenAddress;
  final String collectionName;
  final String imageUrl;
  final String collectionAddress;
  final List<dynamic> traits;
  final List<dynamic> creators;
  final String chain;
  final String network;

  NFT({
    required this.name,
    required this.description,
    required this.tokenAddress,
    required this.collectionName,
    required this.imageUrl,
    required this.collectionAddress,
    required this.traits,
    required this.creators,
    required this.chain,
    required this.network,
  });

  factory NFT.fromJson(Map<String, dynamic> json) {
    return NFT(
      name: json['name'],
      description: json['description'] != null ? json['description'] : [],
      tokenAddress: json['tokenAddress'],
      collectionName: json['collectionName'],
      imageUrl: json['imageUrl'],
      collectionAddress: json['collectionAddress'],
      traits: json['traits'] != null ? json['traits'] : [],

      creators: json['creators'],
      chain: json['chain'],
      network: json['network'],
    );
  }
}

Future<List<NFT>> fetchNFTs(String walletAddress) async {
  final url = dotenv.env['QUICKNODE_API_URL'] ?? '';

  final headers = {
    'Content-Type': 'application/json',
    'x-qn-api-version': '1',
  };

  final body = json.encode({
    'id': 67,
    'jsonrpc': '2.0',
    'method': 'qn_fetchNFTs',
    'params': {
      'wallet': walletAddress,
      'omitFields': ['provenance', 'traits'],
      'page': 1,
      'perPage': 10,
    },
  });

  final response = await http.post(Uri.parse(url), headers: headers, body: body);

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    final assetsData = jsonData?['result']?['assets'] as List<dynamic>? ?? [];
    final nfts = assetsData.map((data) => NFT.fromJson(data)).toList();
    print(assetsData);
    return nfts;
  } else {
    throw Exception('Failed to load NFTs');
  }
}

class NFTScreen extends StatefulWidget {
  final String walletAddress;

  const NFTScreen({required this.walletAddress});

  @override
  _NFTScreenState createState() => _NFTScreenState();
}

class _NFTScreenState extends State<NFTScreen> {
  late Future<List<NFT>> futureNFTs;

  @override
  void initState() {
    super.initState();
    futureNFTs = fetchNFTs(widget.walletAddress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: const Color(0xFF98D6BD),
      appBar: AppBar(
        title: const Text('My SPaws'),
         backgroundColor: const Color(0xFF98D6BD),
      ),
      body: FutureBuilder<List<NFT>>(
        future: futureNFTs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final nfts = snapshot.data;
            return ListView.builder(
              itemCount: nfts?.length ?? 0,
              itemBuilder: (context, index) {
                final nft = nfts![index];
                return ListTile(
                  onTap: () {
                    // Navegar a la vista de detalles del NFT al hacer clic en la imagen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NFTDetailsScreen(nft: nft),
                      ),
                    );
                  },
                  title: Text(nft.name),
                  subtitle: Text(nft.description),
                  leading: Image.network(nft.imageUrl),
                );
              },
            );
          }
        },
      ),
    );
  }
}
