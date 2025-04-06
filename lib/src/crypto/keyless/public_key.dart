import 'dart:typed_data';

import 'package:aptos_core/src/bcs.dart';
import 'package:aptos_core/src/crypto/interface.dart';

class KeylessPublicKey extends PublicKey implements BCSSerializable {
  final String iss;
  final Uint8List idCommitment;

  static const BCSSerializer<KeylessPublicKey> bcsSerializer =
      _KeylessPublicKeySerializer._();

  KeylessPublicKey({required this.iss, required this.idCommitment});

  @override
  void serializeBCS(Serializer serializer) {
    bcsSerializer.serializeIn(serializer, this);
  }

  @override
  Future<bool> verifySignature(
    SignatureVerification<Signature> signatureVerification,
  ) {
    throw UnimplementedError();
  }
}

class _KeylessPublicKeySerializer implements BCSSerializer<KeylessPublicKey> {
  const _KeylessPublicKeySerializer._();
  @override
  KeylessPublicKey deserializeIn(Deserializer deserializer) {
    final iss = deserializer.deserializeStr();
    final idCommitment = deserializer.deserializeBytes();
    return KeylessPublicKey(iss: iss, idCommitment: idCommitment);
  }

  @override
  void serializeIn(Serializer serializer, KeylessPublicKey value) {
    serializer.serializeStr(value.iss);
    serializer.serializeBytes(value.idCommitment);
  }
}
