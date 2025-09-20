import 'package:bcs_serde/bcs_serde.dart';
import 'package:aptos_core/src/crypto/any/public_key.dart';
import 'package:aptos_core/src/crypto/any/signature.dart';
import 'package:aptos_core/src/crypto/ed25519/public_key.dart';
import 'package:aptos_core/src/crypto/ed25519/signature.dart';
import 'package:aptos_core/src/crypto/interface.dart';
import 'package:bcs_serde/bcs_serde.dart';

enum SigningScheme {
  ed25519._(0),
  multiEd25519._(1),
  singleKey._(2),
  multiKey._(3);

  const SigningScheme._(int value) : _underline = value;

  final int _underline;

  int get value => _underline;
}

class PublicKeySerializer implements BCSSerializer<PublicKey> {
  static const BCSSerializer<PublicKey> bcsSerializer = PublicKeySerializer._();

  const PublicKeySerializer._();

  @override
  PublicKey deserializeIn(Deserializer deserializer) {
    final type = deserializer.deserializeUleb128AsU32();
    if (type == SigningScheme.ed25519._underline) {
      return Ed25519PublicKey.bcsSerializer.deserializeIn(deserializer);
    } else if (type == SigningScheme.singleKey._underline) {
      return AnyPublicKey.bcsSerializer.deserializeIn(deserializer);
    }
    throw UnimplementedError();
  }

  @override
  void serializeIn(Serializer serializer, PublicKey value) {
    if (value is Ed25519PublicKey) {
      serializer.serializeU32AsUleb128(SigningScheme.ed25519._underline);
    } else if (value is AnyPublicKey) {
      serializer.serializeU32AsUleb128(SigningScheme.singleKey._underline);
    } else {
      throw UnimplementedError();
    }
    value.serializeBCS(serializer);
  }
}

class SignatureSerializer implements BCSSerializer<Signature> {
  static const BCSSerializer<Signature> bcsSerializer = SignatureSerializer._();

  const SignatureSerializer._();

  @override
  Signature deserializeIn(Deserializer deserializer) {
    final type = deserializer.deserializeUleb128AsU32();
    if (type == SigningScheme.ed25519._underline) {
      return Ed25519Signature.bcsSerializer.deserializeIn(deserializer);
    } else if (type == SigningScheme.singleKey._underline) {
      return AnySignature.bcsSerializer.deserializeIn(deserializer);
    }
    throw UnimplementedError();
  }

  @override
  void serializeIn(Serializer serializer, Signature value) {
    if (value is Ed25519PublicKey) {
      serializer.serializeU32AsUleb128(SigningScheme.ed25519._underline);
    } else if (value is AnyPublicKey) {
      serializer.serializeU32AsUleb128(SigningScheme.singleKey._underline);
    } else {
      throw UnimplementedError();
    }
    value.serializeBCS(serializer);
  }
}
