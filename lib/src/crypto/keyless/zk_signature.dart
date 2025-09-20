import 'package:aptos_core/aptos_core.dart';
import 'package:bcs_serde/bcs_serde.dart';

class ZeroKnowledgeSignature extends Signature {
  final ZkProof proof;
  final BigInt expHorizonSecs;
  final String? extraField;
  final String? overrideAudVal;
  final EphemeralSignature? trainingWheelsSignature;

  ZeroKnowledgeSignature({
    required this.proof,
    required this.expHorizonSecs,
    required this.extraField,
    required this.overrideAudVal,
    required this.trainingWheelsSignature,
  });

  static const BCSSerializer<ZeroKnowledgeSignature> bcsSerializer =
      _ZeroKnowledgeSignatureSerializer._();

  @override
  void serializeBCS(Serializer serializer) =>
      bcsSerializer.serializeIn(serializer, this);
}

class _ZeroKnowledgeSignatureSerializer
    implements BCSSerializer<ZeroKnowledgeSignature> {
  const _ZeroKnowledgeSignatureSerializer._();
  @override
  ZeroKnowledgeSignature deserializeIn(Deserializer deserializer) {
    final proof = ZkProof.bcsSerializer.deserializeIn(deserializer);
    final expHorizonSecs = deserializer.deserializeU64();
    final extraField = deserializer.deserializeOptionalStr();
    final overrideAudVal = deserializer.deserializeOptionalStr();
    final trainingWheelsSignature = EphemeralSignature.bcsSerializer
        .deserializeOptionalIn(deserializer);
    return ZeroKnowledgeSignature(
      proof: proof,
      expHorizonSecs: expHorizonSecs,
      extraField: extraField,
      overrideAudVal: overrideAudVal,
      trainingWheelsSignature: trainingWheelsSignature,
    );
  }

  @override
  void serializeIn(Serializer serializer, ZeroKnowledgeSignature value) {
    ZkProof.bcsSerializer.serializeIn(serializer, value.proof);
    serializer.serializeU64(value.expHorizonSecs);
    serializer.serializeOptionalStr(value.extraField);
    serializer.serializeOptionalStr(value.overrideAudVal);
    EphemeralSignature.bcsSerializer.serializeOptionalIn(
      serializer,
      value.trainingWheelsSignature,
    );
  }
}
