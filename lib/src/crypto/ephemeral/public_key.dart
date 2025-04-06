import 'package:aptos_core/src/bcs.dart';
import 'package:aptos_core/src/crypto/ed25519/public_key.dart';
import 'package:aptos_core/src/crypto/ephemeral/const.dart';
import 'package:aptos_core/src/crypto/ephemeral/signature.dart';
import 'package:aptos_core/src/crypto/interface.dart';

class EphemeralPublicKey extends PublicKey<EphemeralSignature> {
  final EphemeralPublicKeyVariant variant;
  final PublicKey key;

  static const BCSSerializer<EphemeralPublicKey> bcsSerializer =
      _EphemeralPublicKeySerializer._();

  EphemeralPublicKey({required this.variant, required this.key});

  @override
  void serializeBCS(Serializer serializer) {
    bcsSerializer.serializeIn(serializer, this);
  }

  @override
  Future<bool> verifySignature(
    SignatureVerification<EphemeralSignature> signatureVerification,
  ) {
    return key.verifySignature(
      SignatureVerification(
        message: signatureVerification.message,
        signature: signatureVerification.signature.signature,
      ),
    );
  }
}

class _EphemeralPublicKeySerializer
    implements BCSSerializer<EphemeralPublicKey> {
  const _EphemeralPublicKeySerializer._();

  @override
  EphemeralPublicKey deserializeIn(Deserializer deserializer) {
    final variant = deserializer.deserializeUleb128AsU32();
    if (EphemeralPublicKeyVariant.ed25519.value == variant) {
      return EphemeralPublicKey(
        key: Ed25519PublicKey.bcsSerializer.deserializeIn(deserializer),
        variant: EphemeralPublicKeyVariant.ed25519,
      );
    }
    throw UnimplementedError();
  }

  @override
  void serializeIn(Serializer serializer, EphemeralPublicKey value) {
    serializer.serializeU32AsUleb128(value.variant.value);
    if (EphemeralPublicKeyVariant.ed25519 == value.variant) {
      Ed25519PublicKey.bcsSerializer.serializeIn(
        serializer,
        value.key as Ed25519PublicKey,
      );
    } else {
      throw UnimplementedError();
    }
  }
}
