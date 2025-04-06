import 'dart:typed_data';

import 'package:aptos_core/src/crypto/ed25519/algorithm.dart';
import 'package:aptos_core/src/crypto/ed25519/public_key.dart';
import 'package:aptos_core/src/crypto/ed25519/signature.dart';
import 'package:aptos_core/src/crypto/interface.dart';
import 'package:aptos_core/src/model/hex.dart';

class Ed25519PrivateKey extends PrivateKey<Ed25519Signature, Ed25519PublicKey> {
  static const size = 32;

  final Hex _key;

  Ed25519PrivateKey({required Hex key}) : _key = key;

  @override
  Future<Ed25519PublicKey> getPublicKey() async {
    final pair = await Ed25519Algorithm.fromPrivateKey(_key.toUint8List());
    return pair.publicKey;
  }

  @override
  Uint8List toUint8List() => _key.toUint8List();

  @override
  Future<Ed25519Signature> signMessage(Hex message) async {
    final bytes = await Ed25519Algorithm.signMessage(
      message.toUint8List(),
      this,
    );
    return Ed25519Signature(signature: Hex.fromUint8Array(bytes));
  }
}
