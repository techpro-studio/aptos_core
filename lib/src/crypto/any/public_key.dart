import 'package:aptos_core/src/bcs.dart';
import 'package:aptos_core/src/crypto/any/signature.dart';
import 'package:aptos_core/src/crypto/ed25519/public_key.dart';
import 'package:aptos_core/src/crypto/interface.dart';
import 'package:aptos_core/src/crypto/keyless/public_key.dart';

enum AnyPublicKeyVariant {
  keyless._(3),
  ed25519._(0),
  secp256k1._(1),
  federatedKeyless._(4);

  const AnyPublicKeyVariant._(int value) : _underline = value;

  final int _underline;

  int get value => _underline;
}

class AnyPublicKey extends PublicKey<AnySignature> {
  final AnyPublicKeyVariant variant;
  final PublicKey key;

  AnyPublicKey({required this.variant, required this.key});

  static const BCSSerializer<AnyPublicKey> bcsSerializer =
      _AnyPublicKeySerializer._();

  @override
  void serializeBCS(Serializer serializer) =>
      bcsSerializer.serializeIn(serializer, this);

  @override
  Future<bool> verifySignature(
    SignatureVerification<AnySignature> signatureVerification,
  ) {
    return key.verifySignature(
      SignatureVerification(
        message: signatureVerification.message,
        signature: signatureVerification.signature.signature,
      ),
    );
  }
}

class _AnyPublicKeySerializer implements BCSSerializer<AnyPublicKey> {
  const _AnyPublicKeySerializer._();

  @override
  AnyPublicKey deserializeIn(Deserializer deserializer) {
    final variant = deserializer.deserializeUleb128AsU32();
    if (variant == AnyPublicKeyVariant.keyless._underline) {
      final keyless = KeylessPublicKey.bcsSerializer.deserializeIn(
        deserializer,
      );
      return AnyPublicKey(variant: AnyPublicKeyVariant.keyless, key: keyless);
    } else if (variant == AnyPublicKeyVariant.ed25519._underline) {
      final ed25519 = Ed25519PublicKey.bcsSerializer.deserializeIn(
        deserializer,
      );
      return AnyPublicKey(variant: AnyPublicKeyVariant.ed25519, key: ed25519);
    }
    throw UnimplementedError();
  }

  @override
  void serializeIn(Serializer serializer, AnyPublicKey value) {
    serializer.serializeU32AsUleb128(value.variant._underline);
    if (value.variant == AnyPublicKeyVariant.keyless) {
      KeylessPublicKey.bcsSerializer.serializeIn(
        serializer,
        value.key as KeylessPublicKey,
      );
    } else if (value.variant == AnyPublicKeyVariant.ed25519) {
      Ed25519PublicKey.bcsSerializer.serializeIn(
        serializer,
        value.key as Ed25519PublicKey,
      );
    } else {
      throw UnimplementedError();
    }
  }
}
