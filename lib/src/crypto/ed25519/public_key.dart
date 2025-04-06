import 'dart:typed_data';

import 'package:aptos_core/aptos_core.dart';

class Ed25519PublicKey extends PublicKey<Ed25519Signature> {
  final Hex _key;

  static const size = 32;

  Ed25519PublicKey({required Hex key}) : _key = key;

  static const BCSSerializer<Ed25519PublicKey> bcsSerializer =
      _Ed25519PublicKeyBCSSerializer._();

  @override
  Uint8List toUint8List() => _key.toUint8List();

  @override
  void serializeBCS(Serializer serializer) =>
      bcsSerializer.serializeIn(serializer, this);

  @override
  Future<bool> verifySignature(
    SignatureVerification<Ed25519Signature> signatureVerification,
  ) async {
    return Ed25519Algorithm.verifySignature(
      signatureVerification.message,
      signatureVerification.signature,
      this,
    );
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
    serializer.serializeBytes(value._key.toUint8List());
  }
}
