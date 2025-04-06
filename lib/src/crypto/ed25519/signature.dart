import 'package:aptos_core/src/bcs.dart';
import 'package:aptos_core/src/crypto/interface.dart';
import 'package:aptos_core/src/model/hex.dart';

class Ed25519Signature extends Signature {
  final Hex _signature;
  static const size = 64;

  static const BCSSerializer<Ed25519Signature> bcsSerializer =
      _Ed25519SignatureSerializer._();

  Ed25519Signature({required Hex signature}) : _signature = signature;

  @override
  void serializeBCS(Serializer serializer) =>
      bcsSerializer.serializeIn(serializer, this);
}

class _Ed25519SignatureSerializer implements BCSSerializer<Ed25519Signature> {
  const _Ed25519SignatureSerializer._();

  @override
  Ed25519Signature deserializeIn(Deserializer deserializer) {
    return Ed25519Signature(
      signature: Hex.fromUint8Array(deserializer.deserializeBytes()),
    );
  }

  @override
  void serializeIn(Serializer serializer, Ed25519Signature value) {
    serializer.serializeBytes(value._signature.toUint8Array());
  }
}
