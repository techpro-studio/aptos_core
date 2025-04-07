import 'dart:typed_data';

import 'package:aptos_core/aptos_core.dart';

class EphemeralKeyPair extends BCSSerializable {
  final PrivateKey privateKey;
  final EphemeralPublicKey publicKey;
  final BigInt expiryDateSecs;
  final Uint8List blinder;
  final String nonce;

  bool get isExpired =>
      expiryDateSecs <
      BigInt.from(DateTime.now().millisecondsSinceEpoch ~/ 1000);

  static const blinderLength = 31;

  EphemeralKeyPair._({
    required this.publicKey,
    required this.privateKey,
    required this.expiryDateSecs,
    required this.blinder,
    required this.nonce,
  });

  factory EphemeralKeyPair.buildFrom(
    Ed25519PrivateKey privateKey, {
    BigInt? expiryDateSecs,
    Uint8List? blinder,
  }) {
    final publicKey = EphemeralPublicKey(
      variant: EphemeralPublicKeyVariant.ed25519,
      key: privateKey.getPublicKey(),
    );
    final newBlinder = blinder ?? generateRandomBytes(blinderLength);

    final expire =
        expiryDateSecs ??
        BigInt.from(
          secondsRoundedToClosestHour(
            (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 1_209_600,
          ),
        );

    final publicKeySerialized = EphemeralPublicKey.bcsSerializer.serialize(
      publicKey,
    );
    final fields = padAndPackBytesWithLen(publicKeySerialized, 93);
    fields.add(BigInt.from(publicKeySerialized.length));
    fields.add(expire);
    fields.add(newBlinder.toBigIntLE());
    final hash = poseidonHash(fields);

    final nonce = hash.toString();
    return EphemeralKeyPair._(
      publicKey: publicKey,
      privateKey: privateKey,
      expiryDateSecs: expire,
      blinder: newBlinder,
      nonce: nonce,
    );
  }

  static const BCSSerializer<EphemeralKeyPair> bcsSerializer =
      _EphemeralKeyPairBCSSerializer();

  @override
  void serializeBCS(Serializer serializer) =>
      bcsSerializer.serializeIn(serializer, this);
}

class _EphemeralKeyPairBCSSerializer
    implements BCSSerializer<EphemeralKeyPair> {
  const _EphemeralKeyPairBCSSerializer();

  @override
  EphemeralKeyPair deserializeIn(Deserializer deserializer) {
    final type = deserializer.deserializeUleb128AsU32();
    if (type != EphemeralPublicKeyVariant.ed25519.value) {
      throw UnimplementedError();
    }
    final privateKey = Ed25519PrivateKey(key: deserializer.deserializeBytes());
    final expiryDateSecs = deserializer.deserializeU64();
    final blinder = deserializer.deserializeFixedBytes(
      EphemeralKeyPair.blinderLength,
    );

    return EphemeralKeyPair.buildFrom(
      privateKey,
      expiryDateSecs: expiryDateSecs,
      blinder: blinder,
    );
  }

  @override
  void serializeIn(Serializer serializer, EphemeralKeyPair value) {
    serializer.serializeU32AsUleb128(value.publicKey.variant.value);
    serializer.serializeBytes(value.privateKey.toUint8List());
    serializer.serializeU64(value.expiryDateSecs);
    serializer.serializeFixedBytes(value.blinder);
  }
}
