import 'dart:typed_data';

import 'package:aptos_core/src/bcs.dart';
import 'package:aptos_core/src/model/hex.dart';

abstract class Algorithm<
  Sig extends Signature,
  Public extends PublicKey<Sig>,
  Private extends PrivateKey<Sig, Public>
> {
  String get name;

  Future<Private> generatePrivateKey();

  Future<Private> getFromSeed(Uint8List seed);
}

class KeyPair<
  Sig extends Signature,
  Public extends PublicKey<Sig>,
  Private extends PrivateKey<Sig, Public>
> {
  final Public publicKey;
  final Private privateKey;

  KeyPair({required this.publicKey, required this.privateKey});
}

abstract class PrivateKey<
  Sig extends Signature,
  Public extends PublicKey<Sig>
> {
  Future<Public> getPublicKey();
  Uint8List toUint8List();
  Future<Sig> signMessage(Uint8List message);
}

class SignatureVerification<Sig extends Signature> {
  final Uint8List message;
  final Sig signature;

  SignatureVerification({required this.message, required this.signature});
}

abstract class PublicKey<Sig extends Signature> extends BCSSerializable {
  Future<bool> verifySignature(
    SignatureVerification<Sig> signatureVerification,
  );

  Uint8List toUint8List() => bcsToBytes();
}

abstract class Signature extends BCSSerializable {
  Uint8List toUint8List() => bcsToBytes();

  @override
  String toString() => toUint8List().toHexWithPrefix();
}
