import 'package:bcs_serde/bcs_serde.dart';
import 'package:aptos_core/src/crypto/ed25519/signature.dart';
import 'package:aptos_core/src/crypto/ephemeral/const.dart';
import 'package:aptos_core/src/crypto/interface.dart';

class EphemeralSignature extends Signature {
  final EphemeralSignatureVariant variant;
  final Signature signature;

  static const BCSSerializer<EphemeralSignature> bcsSerializer =
      _EphemeralSignatureSerializer._();

  EphemeralSignature({required this.variant, required this.signature});

  @override
  void serializeBCS(Serializer serializer) {
    bcsSerializer.serializeIn(serializer, this);
  }
}

class _EphemeralSignatureSerializer
    implements BCSSerializer<EphemeralSignature> {
  const _EphemeralSignatureSerializer._();

  @override
  EphemeralSignature deserializeIn(Deserializer deserializer) {
    final variant = deserializer.deserializeUleb128AsU32();
    if (EphemeralPublicKeyVariant.ed25519.value == variant) {
      return EphemeralSignature(
        signature: Ed25519Signature.bcsSerializer.deserializeIn(deserializer),
        variant: EphemeralSignatureVariant.ed25519,
      );
    }
    throw UnimplementedError();
  }

  @override
  void serializeIn(Serializer serializer, EphemeralSignature value) {
    serializer.serializeU32AsUleb128(value.variant.value);
    if (EphemeralSignatureVariant.ed25519 == value.variant) {
      Ed25519Signature.bcsSerializer.serializeIn(
        serializer,
        value.signature as Ed25519Signature,
      );
    } else {
      throw UnimplementedError();
    }
  }
}
