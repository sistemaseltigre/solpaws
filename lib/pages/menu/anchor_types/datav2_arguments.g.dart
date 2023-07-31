// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'datav2_arguments.dart';

// **************************************************************************
// BorshSerializableGenerator
// **************************************************************************

mixin _$DataV2Arguments {
  String get name => throw UnimplementedError();
  String get symbol => throw UnimplementedError();
  String get uri => throw UnimplementedError();
  BigInt get seller_fee_basis_points => throw UnimplementedError();
  BigInt get creators => throw UnimplementedError();
  BigInt get collection => throw UnimplementedError();
  BigInt get uses => throw UnimplementedError();

  Uint8List toBorsh() {
    final writer = BinaryWriter();

    const BString().write(writer, name);
    const BString().write(writer, symbol);
    const BString().write(writer, uri);
    const BU64().write(writer, seller_fee_basis_points);
    const BU64().write(writer, creators);
    const BU64().write(writer, collection);
    const BU64().write(writer, uses);

    return writer.toArray();
  }
}

class _DataV2Arguments extends DataV2Arguments {
  _DataV2Arguments({
    required this.name,
    required this.symbol,
    required this.uri,
    required this.seller_fee_basis_points,
    required this.creators,
    required this.collection,
    required this.uses,
  }) : super._();

  final String name;
  final String symbol;
  final String uri;
  final BigInt seller_fee_basis_points;
  final BigInt creators;
  final BigInt collection;
  final BigInt uses;
}

class BDataV2Arguments implements BType<DataV2Arguments> {
  const BDataV2Arguments();

  @override
  void write(BinaryWriter writer, DataV2Arguments value) {
    writer.writeStruct(value.toBorsh());
  }

  @override
  DataV2Arguments read(BinaryReader reader) {
    return DataV2Arguments(
      name: const BString().read(reader),
      symbol: const BString().read(reader),
      uri: const BString().read(reader),
      seller_fee_basis_points: const BU64().read(reader),
      creators: const BU64().read(reader),
      collection: const BU64().read(reader),
      uses: const BU64().read(reader),
    );
  }
}

DataV2Arguments _$DataV2ArgumentsFromBorsh(Uint8List data) {
  final reader = BinaryReader(data.buffer.asByteData());

  return const BDataV2Arguments().read(reader);
}
