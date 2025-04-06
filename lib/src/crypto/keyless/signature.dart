import 'package:aptos_core/src/bcs.dart';
import 'package:aptos_core/src/crypto/ephemeral.dart';
import 'package:aptos_core/src/crypto/interface.dart';
import 'package:aptos_core/src/crypto/keyless/ephemeral_certificate.dart';

class KeylessSignature extends Signature {
  final EphemeralCertificate ephemeralCertificate;
  final String jwtHeader;
  final BigInt expiryDateSecs;
  final EphemeralPublicKey ephemeralPublicKey;
  final EphemeralSignature ephemeralSignature;

  KeylessSignature({
    required this.ephemeralCertificate,
    required this.jwtHeader,
    required this.expiryDateSecs,
    required this.ephemeralPublicKey,
    required this.ephemeralSignature,
  });

  static const BCSSerializer<KeylessSignature> bcsSerializer =
      _KeylessSignatureSerializer._();

  @override
  void serializeBCS(Serializer serializer) =>
      bcsSerializer.serializeIn(serializer, this);
}

class _KeylessSignatureSerializer implements BCSSerializer<KeylessSignature> {
  const _KeylessSignatureSerializer._();

  @override
  KeylessSignature deserializeIn(Deserializer deserializer) {
    final certificate = EphemeralCertificate.bcsSerializer.deserializeIn(
      deserializer,
    );
    final jwtHeader = deserializer.deserializeStr();
    final expiryDateSecs = deserializer.deserializeU64();
    final ephemeralPublicKey = EphemeralPublicKey.bcsSerializer.deserializeIn(
      deserializer,
    );
    final ephemeralSignature = EphemeralSignature.bcsSerializer.deserializeIn(
      deserializer,
    );
    return KeylessSignature(
      ephemeralCertificate: certificate,
      jwtHeader: jwtHeader,
      expiryDateSecs: expiryDateSecs,
      ephemeralPublicKey: ephemeralPublicKey,
      ephemeralSignature: ephemeralSignature,
    );
  }

  @override
  void serializeIn(Serializer serializer, KeylessSignature value) {
    EphemeralCertificate.bcsSerializer.serializeIn(
      serializer,
      value.ephemeralCertificate,
    );
    serializer.serializeStr(value.jwtHeader);
    serializer.serializeU64(value.expiryDateSecs);
    EphemeralPublicKey.bcsSerializer.serializeIn(
      serializer,
      value.ephemeralPublicKey,
    );
    EphemeralSignature.bcsSerializer.serializeIn(
      serializer,
      value.ephemeralSignature,
    );
  }
}
