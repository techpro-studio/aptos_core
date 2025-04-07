import 'dart:typed_data';

import 'package:aptos_core/src/bcs.dart';
import 'package:aptos_core/src/crypto/authentication_key.dart';
import 'package:aptos_core/src/model/bytes.dart';

abstract class Algorithm<
  Sig extends Signature,
  Public extends PublicKey<Sig>,
  Private extends PrivateKey<Sig, Public>
> {
  String get name;

  Private generatePrivateKey();

  Private privateKeyFromSeed(Uint8List seed);
}

abstract class PrivateKey<
  Sig extends Signature,
  Public extends PublicKey<Sig>
> {
  Public getPublicKey();
  Uint8List toUint8List();
  Sig signMessage(Uint8List message);
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

abstract class AccountPublicKey<Sig extends Signature> extends PublicKey<Sig> {
  AuthenticationKey get authKey;
}
