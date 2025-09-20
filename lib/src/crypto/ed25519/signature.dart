import 'dart:typed_data';

import 'package:bcs_serde/bcs_serde.dart';
import 'package:aptos_core/src/crypto/interface.dart';

class Ed25519Signature extends Signature {
  final Uint8List _signature;
  static const size = 64;

  static const BCSSerializer<Ed25519Signature> bcsSerializer =
      _Ed25519SignatureSerializer._();

  @override
  toUint8List() => _signature;

  Ed25519Signature({required Uint8List signature}) : _signature = signature;

  @override
  void serializeBCS(Serializer serializer) =>
      bcsSerializer.serializeIn(serializer, this);
}

class _Ed25519SignatureSerializer implements BCSSerializer<Ed25519Signature> {
  const _Ed25519SignatureSerializer._();

  @override
  Ed25519Signature deserializeIn(Deserializer deserializer) {
    return Ed25519Signature(signature: deserializer.deserializeBytes());
  }

  @override
  void serializeIn(Serializer serializer, Ed25519Signature value) {
    serializer.serializeBytes(value._signature);
  }
}
