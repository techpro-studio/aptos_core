import 'package:aptos_core/src/bcs.dart';
import 'package:aptos_core/src/crypto/keyless/groth16_zkp.dart';

enum ZkpVariant {
  groth16._(0);

  const ZkpVariant._(int value) : _internal = value;

  final int _internal;
}

class ZkProof {
  final dynamic proof;
  final ZkpVariant variant;

  ZkProof({required this.proof, required this.variant});

  static const BCSSerializer<ZkProof> bcsSerializer = _ZkProofSerializer._();
}

class _ZkProofSerializer implements BCSSerializer<ZkProof> {
  const _ZkProofSerializer._();

  @override
  ZkProof deserializeIn(Deserializer deserializer) {
    final variant = deserializer.deserializeUleb128AsU32();
    if (ZkpVariant.groth16._internal == variant) {
      return ZkProof(
        proof: Groth16Zkp.bcsSerializer.deserializeIn(deserializer),
        variant: ZkpVariant.groth16,
      );
    }
    throw UnimplementedError();
  }

  @override
  void serializeIn(Serializer serializer, ZkProof value) {
    serializer.serializeU32AsUleb128(value.variant._internal);
    if (ZkpVariant.groth16 == value.variant) {
      Groth16Zkp.bcsSerializer.serializeIn(serializer, value.proof);
    } else {
      throw UnimplementedError();
    }
  }
}
