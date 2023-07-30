import 'package:flutter/material.dart';
import 'package:solana/dto.dart';
import 'package:solana_web3/solana_web3.dart' as web3;
import 'package:solana/solana.dart' as solana;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:solana/anchor.dart' as solana_anchor;
import 'package:solana/encoder.dart' as solana_encoder;
import '../menu/anchor_types/nft_arguments.dart' as anchor_types;
import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart';

Future<void> createNft() async {
  debugPrint('Create NFT');

  //Create connnection with solana
  final client = solana.SolanaClient(
    rpcUrl: Uri.parse('https://api.devnet.solana.com'),
    websocketUrl: Uri.parse('wss://api.devnet.solana.com'),
  );

  const storage = FlutterSecureStorage();

  // Get main wallet key from storage
  final mainWalletKey = await storage.read(key: "solana_solpaws_wallet");

  // Decode key
  final decodeKeyTmp = web3.base58Decode(mainWalletKey!); // 64 bytes

  // Get private key 32 bytes
  final privKeyBytes = decodeKeyTmp.sublist(decodeKeyTmp.length - 32);

  // Create wallet
  final mainWalletSolana = await solana.Ed25519HDKeyPair.fromPrivateKeyBytes(
      privateKey: privKeyBytes); // with solana

  //check wallet balance
  final balance = client.rpcClient.getBalance(
      mainWalletSolana.publicKey.toBase58(),
      commitment: solana.Commitment.confirmed);
  final balanceTmp = await balance.value;

  if (balanceTmp < 0.25) {
    await client.requestAirdrop(
      lamports: 2 * solana.lamportsPerSol,
      address: mainWalletSolana.publicKey,
      commitment: Commitment.confirmed,
    );
  } else {
    // Create Metadata

    //Random number to metadata
    final random = Random();
    final newRandomNum = random.nextInt(5) + 1;

    // Get json file from assets
    final jsonString = await rootBundle.loadString('assets/json/nft$newRandomNum.json');
    final jsonData = json.decode(jsonString);

    // Quicknode IPFS Storage
    final jsonMetadataIPFS = [
      "QmQYGYfEtSUb4SDcDWKeBRJuZRAReG3BQrvxrbkv9mvAtA",
      "QmbMtRMssRKChra3r8zkcoqvBXqaUzEACn7J1HdQEyf9Tw",
      "QmZAXftEbPkZGiZTErEqFkXFmHbWrkWGKRFwXCo1KeRsSa",
      "QmRJg45Wn2SAxo85fqSTWFAWTTsY1rjE2VgggwCHRvSGk2",
      "QmPK8K7ZB6VjRCDt8HAtXCPnqPcV62iZKDDgsz9frACQni",
    ];

    final accountInfowallet = await client.rpcClient.getAccountInfo(
      mainWalletSolana.publicKey.toBase58(),
    );

    debugPrint(mainWalletSolana.publicKey.toBase58());
    debugPrint(accountInfowallet.toString());
    //progressNotifier.updateProgress("Creating accounts...");
    // Get the program id of the smart contract.
    const programId =
        '721ww32Q4wrDKt1vtzQC24NSgTjATaBTwDQeATSoDMyc'; //program nft all
    //const programId = 'AXyJQbBaY8EtJLcKcEtyXGjXLKP9qDWRNhduFzZ17jNe'; //program flutter
    final programIdPublicKey = solana.Ed25519HDPublicKey.fromBase58(programId);
    debugPrint('programIdPublicKey: $programIdPublicKey');

    // Get metaplex program id
    const metaplexProgramId = 'metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s';
    final metaplexProgramIdPublicKey =
        solana.Ed25519HDPublicKey.fromBase58(metaplexProgramId);
    debugPrint('metaplexProgramIdPublicKey: $metaplexProgramIdPublicKey');

    //Get ATA program id
    final ataProgramId = solana.Ed25519HDPublicKey.fromBase58(
        solana.AssociatedTokenAccountProgram.programId);
    debugPrint('ataProgramId: $ataProgramId');

    //Get rent program id
    final rentProgramId = solana.Ed25519HDPublicKey.fromBase58(
        "SysvarRent111111111111111111111111111111111");
    debugPrint('rentProgramId: $rentProgramId');

    //Get system program id
    final systemProgramId =
        solana.Ed25519HDPublicKey.fromBase58(solana.SystemProgram.programId);
    debugPrint('systemProgramId: $systemProgramId');

    //Get token program id
    final tokenProgramId =
        solana.Ed25519HDPublicKey.fromBase58(solana.TokenProgram.programId);
    debugPrint('tokenProgramId: $tokenProgramId');

    int id = Random().nextInt(999999999); // uniq id of nft

    // Get PDA mint account
    final nftMintPda = await solana.Ed25519HDPublicKey.findProgramAddress(
      seeds: [
        web3.Buffer.fromString("mint"),
        web3.Buffer.fromUint64(BigInt.from(id)),
      ],
      programId: programIdPublicKey,
    );
    debugPrint('nftMintPda: $nftMintPda');

    // Get PDA metadata account
    final nftMetadataPda = await solana.Ed25519HDPublicKey.findProgramAddress(
      seeds: [
        web3.Buffer.fromString("metadata"),
        metaplexProgramIdPublicKey.bytes,
        nftMintPda.bytes,
      ],
      programId: metaplexProgramIdPublicKey,
    );
    debugPrint('nftMetadataPda: $nftMetadataPda');

    final masterEditionAccountPda =
        await solana.Ed25519HDPublicKey.findProgramAddress(
      seeds: [
        web3.Buffer.fromString("metadata"),
        metaplexProgramIdPublicKey.bytes,
        nftMintPda.bytes,
        web3.Buffer.fromString("edition"),
      ],
      programId: metaplexProgramIdPublicKey,
    );
    debugPrint('masterEditionAccountPda: $masterEditionAccountPda');

    final tokenAccount = await solana.Ed25519HDPublicKey.findProgramAddress(
      seeds: [
        mainWalletSolana.publicKey.bytes,
        tokenProgramId.bytes,
        nftMintPda.bytes,
      ],
      programId: ataProgramId,
    );
    debugPrint('tokenAccount: $tokenAccount');
    //jsonMetadataIPFS
    final ipnftIPFS = jsonMetadataIPFS[newRandomNum];
    //debugPrint('https://$ipnftIPFS.ipfs.nftstorage.link/metadata.json');

    //progressNotifier.updateProgress("Send transaction to Solana Blockchain...");

    final instructions = [
      await solana_anchor.AnchorInstruction.forMethod(
        programId: programIdPublicKey,
        method: 'createnft',
        arguments: solana_encoder.ByteArray(
          anchor_types.NftArguments(
                  id: BigInt.from(id),
                  name: jsonData['name'],
                  symbol: jsonData["symbol"],
                  uri:
                      "https://quicknode.myfilebase.com/ipfs/$ipnftIPFS/",
                  price: BigInt.from(1),
                  cant: BigInt.from(1))
              .toBorsh()
              .toList(),
        ),
        accounts: <solana_encoder.AccountMeta>[
          solana_encoder.AccountMeta.writeable(
              pubKey: nftMintPda, isSigner: false),
          solana_encoder.AccountMeta.writeable(
              pubKey: tokenAccount, isSigner: false),
          solana_encoder.AccountMeta.readonly(
              pubKey: ataProgramId, isSigner: false),
          solana_encoder.AccountMeta.writeable(
              pubKey: mainWalletSolana.publicKey, isSigner: true),
          solana_encoder.AccountMeta.writeable(
              pubKey: mainWalletSolana.publicKey, isSigner: true),
          solana_encoder.AccountMeta.readonly(
              pubKey: rentProgramId, isSigner: false),
          solana_encoder.AccountMeta.readonly(
              pubKey: systemProgramId, isSigner: false),
          solana_encoder.AccountMeta.readonly(
              pubKey: tokenProgramId, isSigner: false),
          solana_encoder.AccountMeta.readonly(
              pubKey: metaplexProgramIdPublicKey, isSigner: false),
          solana_encoder.AccountMeta.writeable(
              pubKey: masterEditionAccountPda, isSigner: false),
          solana_encoder.AccountMeta.writeable(
              pubKey: nftMetadataPda, isSigner: false),
        ],
        namespace: 'global',
      ),
    ];
    final message = solana.Message(instructions: instructions);
    final signature = await client.sendAndConfirmTransaction(
      message: message,
      signers: [mainWalletSolana],
      commitment: solana.Commitment.confirmed,
    );
    debugPrint('Tx successful with hash: $signature');
  }
}
