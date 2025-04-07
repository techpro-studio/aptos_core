import 'dart:typed_data';

import 'package:aptos_core/aptos_core.dart';

import 'const.dart' as c;

class KeylessPublicKey extends AccountPublicKey<KeylessSignature>
    implements BCSSerializable {
  final String iss;
  final Uint8List idCommitment;

  static const idCommitmentLength = 32;

  static const BCSSerializer<KeylessPublicKey> bcsSerializer =
      _KeylessPublicKeySerializer._();

  KeylessPublicKey({required this.iss, required this.idCommitment});

  factory KeylessPublicKey.fromJWTAndPepper(
    String jwt,
    Uint8List pepper, {
    String uidKey = 'sub',
  }) {
    final jwtBody = jwt.getJWTBody(uidKey: uidKey);

    final fields = [
      pepper.toBigIntLE(),
      hashStringWithLen(jwtBody.aud, c.maxAudValBytes),
      hashStringWithLen(jwtBody.uidVal, c.maxUidValBytes),
      hashStringWithLen(uidKey, c.maxUidKeyBytes),
    ];
    final hash = poseidonHash(fields);
    final commitment = hash.toBytesLE(idCommitmentLength);

    return KeylessPublicKey(iss: jwtBody.iss, idCommitment: commitment);
  }

  @override
  AuthenticationKey get authKey {
    final serializer = Serializer();
    serializer.serializeU32AsUleb128(AnyPublicKeyVariant.keyless.value);
    serializer.serializeFixedBytes(bcsToBytes());
    return AuthenticationKey.fromSchemeAndBytes(
      SigningScheme.singleKey,
      serializer.getBytes(),
    );
  }

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
