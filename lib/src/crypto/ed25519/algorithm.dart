import 'dart:typed_data';

import 'package:aptos_core/src/crypto/ed25519/private_key.dart';
import 'package:aptos_core/src/crypto/ed25519/public_key.dart';
import 'package:aptos_core/src/crypto/ed25519/signature.dart';
import 'package:aptos_core/src/crypto/interface.dart';
import 'package:ed25519_edwards/ed25519_edwards.dart' as ed;

class Ed25519Algorithm
    implements
        Algorithm<Ed25519Signature, Ed25519PublicKey, Ed25519PrivateKey> {
  @override
  Ed25519PrivateKey generatePrivateKey() {
    final key = ed.generateKey();
    return _extractPrivateKey(key.privateKey);
  }

  @override
  Ed25519PrivateKey privateKeyFromSeed(Uint8List seed) => fromSeed(seed);

  static Ed25519PrivateKey _extractPrivateKey(ed.PrivateKey privateKey) =>
      Ed25519PrivateKey(key: ed.seed(privateKey));

  static Ed25519PrivateKey fromSeed(Uint8List bytes) {
    final key = ed.newKeyFromSeed(bytes);
    return _extractPrivateKey(key);
  }

  static Ed25519PublicKey publicFromPrivateKey(Ed25519PrivateKey privateKey) {
    final key = ed.newKeyFromSeed(privateKey.toUint8List());
    return Ed25519PublicKey(key: Uint8List.fromList(ed.public(key).bytes));
  }

  static Uint8List signMessage(
    Uint8List message,
    Ed25519PrivateKey privateKey,
  ) {
    final key = ed.newKeyFromSeed(privateKey.toUint8List());
    return ed.sign(key, message);
  }

  static bool verifySignature(
    Uint8List message,
    Ed25519Signature signature,
    Ed25519PublicKey publicKey,
  ) {
    return ed.verify(
      ed.PublicKey(publicKey.toUint8List()),
      message,
      signature.toUint8List(),
    );
  }

  @override
  String get name => "ed25519";
}
