import 'package:aptos_core/aptos_core.dart';
import 'package:aptos_core/src/bcs.dart';
import 'package:aptos_core/src/crypto/ed25519/signature.dart';
import 'package:aptos_core/src/crypto/interface.dart';

class Ed25519PublicKey extends PublicKey<Ed25519Signature> {
  final Hex _key;

  static const size = 32;

  Ed25519PublicKey({required Hex key}) : _key = key;

  static const BCSSerializer<Ed25519PublicKey> bcsSerializer =
      _Ed25519PublicKeyBCSSerializer._();

  @override
  void serializeBCS(Serializer serializer) =>
      bcsSerializer.serializeIn(serializer, this);

  @override
  Future<bool> verifySignature(
    SignatureVerification<Ed25519Signature> signatureVerification,
  ) async {
    return false;
  }
}

class _Ed25519PublicKeyBCSSerializer
    implements BCSSerializer<Ed25519PublicKey> {
  const _Ed25519PublicKeyBCSSerializer._();

  @override
  Ed25519PublicKey deserializeIn(Deserializer deserializer) {
    return Ed25519PublicKey(
      key: Hex.fromUint8Array(deserializer.deserializeBytes()),
    );
  }

  @override
  void serializeIn(Serializer serializer, Ed25519PublicKey value) {
    serializer.serializeBytes(value._key.toUint8Array());
  }
}
