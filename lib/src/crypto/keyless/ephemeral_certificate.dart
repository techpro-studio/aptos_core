import 'package:bcs_serde/bcs_serde.dart';
import 'package:aptos_core/src/crypto/keyless/zk_signature.dart';

enum EphemeralCertificateVariant {
  zkProof._(0);

  const EphemeralCertificateVariant._(int value) : _internal = value;

  final int _internal;
}

class EphemeralCertificate {
  final dynamic signature;
  final EphemeralCertificateVariant variant;

  static const BCSSerializer<EphemeralCertificate> bcsSerializer =
      _EphemeralCertificateSerializer._();

  EphemeralCertificate({required this.signature, required this.variant});
}

class _EphemeralCertificateSerializer
    implements BCSSerializer<EphemeralCertificate> {
  const _EphemeralCertificateSerializer._();

  @override
  EphemeralCertificate deserializeIn(Deserializer deserializer) {
    final type = deserializer.deserializeUleb128AsU32();
    if (EphemeralCertificateVariant.zkProof._internal == type) {
      return EphemeralCertificate(
        signature: ZeroKnowledgeSignature.bcsSerializer.deserializeIn(
          deserializer,
        ),
        variant: EphemeralCertificateVariant.zkProof,
      );
    }
    throw UnimplementedError();
  }

  @override
  void serializeIn(Serializer serializer, EphemeralCertificate value) {
    serializer.serializeU32AsUleb128(value.variant._internal);
    if (value.variant == EphemeralCertificateVariant.zkProof) {
      ZeroKnowledgeSignature.bcsSerializer.serializeIn(
        serializer,
        value.signature,
      );
    } else {
      throw UnimplementedError();
    }
  }
}
