import 'package:bcs_serde/bcs_serde.dart';
import 'package:aptos_core/src/crypto/ed25519/signature.dart';
import 'package:aptos_core/src/crypto/interface.dart';
import 'package:aptos_core/src/crypto/keyless/signature.dart';

enum AnySignatureVariant {
  keyless._(3),
  ed25519._(0),
  secp256k1._(1);

  const AnySignatureVariant._(int value) : _underline = value;

  final int _underline;

  int get value => _underline;
}

class AnySignature extends Signature {
  final AnySignatureVariant variant;
  final Signature signature;

  AnySignature({required this.variant, required this.signature});

  static const BCSSerializer<AnySignature> bcsSerializer =
      _AnySignatureSerializer._();

  @override
  void serializeBCS(Serializer serializer) =>
      bcsSerializer.serializeIn(serializer, this);
}

class _AnySignatureSerializer implements BCSSerializer<AnySignature> {
  const _AnySignatureSerializer._();

  @override
  AnySignature deserializeIn(Deserializer deserializer) {
    final variant = deserializer.deserializeUleb128AsU32();
    if (AnySignatureVariant.ed25519._underline == variant) {
      return AnySignature(
        variant: AnySignatureVariant.ed25519,
        signature: Ed25519Signature.bcsSerializer.deserializeIn(deserializer),
      );
    } else if (AnySignatureVariant.keyless._underline == variant) {
      return AnySignature(
        variant: AnySignatureVariant.keyless,
        signature: KeylessSignature.bcsSerializer.deserializeIn(deserializer),
      );
    }
    throw UnimplementedError();
  }

  @override
  void serializeIn(Serializer serializer, AnySignature value) {
    throw UnimplementedError();
  }
}
