import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:solpaws/pages/my-spaws/view_nft.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:solana/solana.dart' as solana;
import 'package:solana_web3/solana_web3.dart' as web3;
import 'package:solana/metaplex.dart' as metaplex;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NFTDetailsScreen extends StatefulWidget {
  final NFT nft;

  const NFTDetailsScreen({required this.nft});

  @override
  _NFTDetailsScreenState createState() => _NFTDetailsScreenState();
}

class _NFTDetailsScreenState extends State<NFTDetailsScreen> {
  Map<String, dynamic> nftAttributes = {};
  Future<String> _getNFTData() async {
    final client = solana.SolanaClient(
      rpcUrl: Uri.parse(dotenv.env['QUICKNODE_API_URL'].toString()),
      websocketUrl: Uri.parse('wss://api.devnet.solana.com'),
    );

    final programIdPublicKey =
        solana.Ed25519HDPublicKey.fromBase58(widget.nft.tokenAddress);
    debugPrint('programIdPublicKey: $programIdPublicKey');

    final metaplexmetadata = await client.rpcClient.getMetadata(
      mint: programIdPublicKey,
      commitment: solana.Commitment.confirmed,
    );

    

    final urimetaplextmp = metaplexmetadata?.uri;

    final response = await http.get(Uri.parse(urimetaplextmp!));

    // Remover parte inicial
    final reqIDTmp = urimetaplextmp.replaceFirst(
        "https://quicknode.myfilebase.com/ipfs/", "");

    // Remover / final
    final reqID = reqIDTmp.substring(0, reqIDTmp.length - 1);

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      // Guardar los atributos en el objeto nftAttributes
      nftAttributes = {
        'name': json['name'],
        'symbol': json['symbol'],
        'description': json['description'],
        'Lvl': json['attributes'][0]['value'],
        'Vitality': json['attributes'][1]['value'],
        'Speed': json['attributes'][2]['value'],
        'Food': json['attributes'][3]['value'],
        'Love': json['attributes'][4]['value'],
        'reqID': reqID,
      };
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF98D6BD),
      appBar: AppBar(
        title: const Text('SPaws Details'),
        backgroundColor: const Color(0xFF98D6BD),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(widget.nft.imageUrl), // Mostrar la imagen del NFT
            const SizedBox(height: 16),
            Text('Name: ${widget.nft.name}'), // Mostrar el nombre del NFT
            Text(
                'Description: ${widget.nft.description}'), // Mostrar el nombre de la colección del NFT
            // Mostrar otros atributos del NFT aquí según tus necesidades
            const SizedBox(height: 16),

            FutureBuilder(
              future: _getNFTData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text(
                      'Error al obtener la data del NFT: ${snapshot.error}');
                } else {
                  return Column(
                    children: [
                      Text('Lvl: ${nftAttributes['Lvl']}'),
                      Text('Vitality: ${nftAttributes['Vitality']}'),
                      Text('Speed: ${nftAttributes['Speed']}'),
                      Text('Food: ${nftAttributes['Food']}'),
                      Text('Love: ${nftAttributes['Love']}'),
                      Text('Exp: ${nftAttributes['Exp'] ?? "0"}'),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                updateNft(nftAttributes);
                setState(() {});
                //print('tempFile: $tempFile');
                // print('RequestId: $requestId');
              },
              child: const Text("Feed your spaws"),
            ),
            ElevatedButton(
              onPressed: () {
                // Lógica cuando se presiona el botón "Give love"
              },
              child: const Text("Give love"),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> updateNft(Map<String, dynamic> attr) async {
    final apiKeyQuicknodeIPFS = dotenv.env['QUICKNODE_API_URL_IPFS'].toString();
    final String oldcid = attr['reqID'];
    final apiUrl =
        'https://api.quicknode.com/ipfs/rest/v1/pinning?pageNumber=1&perPage=10';
    final headers = {
      'x-api-key': apiKeyQuicknodeIPFS,
      'Content-Type': 'application/json',
    };

    final response = await http.get(Uri.parse(apiUrl), headers: headers);

    // Decodificar la respuesta JSON
    final jsonResponse = jsonDecode(response.body);

// Obtener lista de pins
    final pins = jsonResponse['data'];

// Encontrar pin por CID
    final matchingPin = pins.firstWhere((pin) => pin['cid'] == oldcid);

// Obtener su requestId
    final requestId = matchingPin['requestId'];

   

    final String apiUrl2 =
        'https://api.quicknode.com/ipfs/rest/v1/pinning/$requestId';
    final Uri uriQuicknode = Uri.parse(apiUrl2);

    // Verificar si los atributos "age" y "exp" existen en el JSON actual
    final ageExists = attr.containsKey('Age');
    final expExists = attr.containsKey('Exp');

    // Si no existen, agregarlos con valores predeterminados
    if (!ageExists) {
      attr['Age'] = "0";
    }
    if (attr['Exp'] != null && double.parse(attr['Exp']) >= 100) {
      attr['Exp'] = "0";
      attr['Age'] = (int.parse(attr['Age']) + 1).toString();
      attr['Lvl'] = (int.parse(attr['Lvl']) + 1).toString();
      attr['Vitality'] = (int.parse(attr['Vitality']) + 1).toString();
      attr['Speed'] = (int.parse(attr['Speed']) + 1).toString();
      attr['Food'] = (int.parse(attr['Food']) + 1).toString();
    }
    if (!expExists) {
      attr['Exp'] = "0.1";
    } else {
      // Obtener el valor actual de "Exp"
      String exp = attr['Exp'];

      // Sumar 0.1 al valor de "Exp"
      String updatedExp = sumPercentage(exp, 0.1);

      // Actualizar el atributo "Exp" en el objeto nftAttributes
      attr['Exp'] = updatedExp;
    }

    final meta = {
      "name": attr['name'],
      "symbol": attr['symbol'],
      "description": attr['description'],
      "image": "https://quicknode.myfilebase.com/ipfs/$oldcid/",
      "attributes": [
        {"trait_type": "Lvl", "value": attr['Lvl']},
        {"trait_type": "Vitality", "value": attr['Vitality']},
        {"trait_type": "Speed", "value": attr['Speed']},
        {"trait_type": "Food", "value": attr['Food']},
        {"trait_type": "Love", "value": attr['Love']},
        {"trait_type": "Age", "value": "1"},
        {"trait_type": "Exp", "value": "0.1%"},
      ],
      "properties": {
        "files": [
          {
            "uri": "https://quicknode.myfilebase.com/ipfs/$oldcid/",
            "type": "image/png",
          }
        ]
      }
    };

    // Expresión regular para buscar dígitos al final
    final regExp = RegExp(r'#(\d+)$');

    // Buscar coincidencia
    final match = regExp.firstMatch(attr['name']);

    // Obtener el grupo de captura con los dígitos
    final numbermach = match!.group(1)!;

    final cleanedNumber =
        numbermach.replaceAllMapped(RegExp(r'^0+'), (match) => '');

    // Armar el nombre del archivo
    final String fileName = "nft$cleanedNumber.json";

    final uploadnewFile = await uploadJSONToIPFS(meta, fileName, requestId);
    

    
    // Actualizar los atributos en el objeto nftAttributes
    nftAttributes['Lvl'] = attr['Lvl'];
    nftAttributes['Vitality'] = attr['Vitality'];
    nftAttributes['Speed'] = attr['Speed'];
    nftAttributes['Food'] = attr['Food'];
    nftAttributes['Love'] = attr['Love'];
    nftAttributes['Exp'] = attr['Exp'];

    return nftAttributes;
  }

  String sumPercentage(String percentage, double valueToAdd) {
    // Eliminar el símbolo de porcentaje
    String percentageWithoutSymbol = percentage.replaceAll('%', '');

    // Convertir la cadena a un valor numérico
    double percentageValue = double.parse(percentageWithoutSymbol);

    // Sumar el valor
    double result = percentageValue + valueToAdd;

    // Convertir el resultado a una cadena sin el símbolo de porcentaje
    String resultString = result.toStringAsFixed(1);

    return resultString;
  }

  Future<String> uploadJSONToIPFS(
      Map<String, dynamic> meta, String filename, String rqid) async {
    final apiKeyQuicknodeIPFS = dotenv.env['QUICKNODE_API_URL_IPFS'].toString();
    final apiUrl = 'https://api.quicknode.com/ipfs/rest/v1/s3/put-object';

    final deleting = await deleteFromIPFS(rqid);

    // Paso 1: Convertir el objeto "meta" en una cadena JSON
    final metaJson = jsonEncode(meta);

    try {
      // Paso 2: Crear un archivo temporal con la cadena JSON
      final tempDir = await Directory.systemTemp.createTemp();
      final tempFile = File('${tempDir.path}/temp_file.json');
      await tempFile.writeAsString(metaJson);

      // Paso 3: Subir el archivo temporal a IPFS utilizando la API de S3 de QuickNode
      final headers = {
        'x-api-key': apiKeyQuicknodeIPFS,
      };

      final request = http.MultipartRequest('POST', Uri.parse(apiUrl))
        ..headers.addAll(headers)
        ..files.add(await http.MultipartFile.fromPath('Body', tempFile.path))
        ..fields['Key'] = filename
        ..fields['ContentType'] = 'text';

      final response = await http.Response.fromStream(await request.send());

      // Paso 4: Obtener el CID del archivo subido
      final jsonResponse = jsonDecode(response.body);
      final cid = jsonResponse['cid'];

      // Eliminar el archivo temporal después de obtener el CID
      await tempFile.delete();

      return cid;
    } catch (e) {
      print('Error uploading JSON to IPFS: $e');
      return ''; // O puedes manejar el error de manera adecuada según tus necesidades
    }
  }

  Future<void> deleteFromIPFS(String requestId) async {
    final apiKeyQuicknodeIPFS = dotenv.env['QUICKNODE_API_URL_IPFS'].toString();
    final apiUrl = 'https://api.quicknode.com/ipfs/rest/v1/pinning/$requestId';

    try {
      final headers = {
        'x-api-key': apiKeyQuicknodeIPFS,
      };

      final response = await http.delete(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 204) {
        print('Object deleted successfully from IPFS.');
      } else {
        print('Error deleting object from IPFS: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting object from IPFS: $e');
    }
  }
}
