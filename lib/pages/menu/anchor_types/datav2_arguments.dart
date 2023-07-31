import 'package:borsh_annotation/borsh_annotation.dart';

part 'datav2_arguments.g.dart';

@BorshSerializable()
class DataV2Arguments with _$DataV2Arguments {
  factory DataV2Arguments({
    @BString() required String name,
    @BString() required String symbol,
    @BString() required String uri,
    @BU64() required BigInt seller_fee_basis_points,
    @BU64() required BigInt creators,
    @BU64() required BigInt collection,
    @BU64() required BigInt uses,
  }) = _DataV2Arguments;

  const DataV2Arguments._();

  factory DataV2Arguments.fromBorsh(Uint8List data) =>
       _$DataV2ArgumentsFromBorsh(data);
}