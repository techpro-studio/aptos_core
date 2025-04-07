import 'dart:typed_data';

import 'package:aptos_core/src/crypto/ed25519/algorithm.dart';
import 'package:aptos_core/src/crypto/ed25519/public_key.dart';
import 'package:aptos_core/src/crypto/ed25519/signature.dart';
import 'package:aptos_core/src/crypto/interface.dart';
import 'package:aptos_core/src/model/bytes.dart';

class Ed25519PrivateKey extends PrivateKey<Ed25519Signature, Ed25519PublicKey> {
  static const size = 32;

  final Uint8List _key;

  Ed25519PrivateKey({required Uint8List key}) : _key = key;

  @override
  Future<Ed25519PublicKey> getPublicKey() async =>
      Ed25519Algorithm.publicFromPrivateKey(this);

  @override
  Uint8List toUint8List() => _key;

  @override
  String toString() => _key.toHexWithPrefix();

  @override
  Future<Ed25519Signature> signMessage(Uint8List message) async {
    final bytes = await Ed25519Algorithm.signMessage(message, this);
    return Ed25519Signature(signature: bytes);
  }
}
