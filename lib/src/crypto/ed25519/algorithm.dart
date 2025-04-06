import 'dart:typed_data';

import 'package:aptos_core/src/crypto/ed25519/private_key.dart';
import 'package:aptos_core/src/crypto/ed25519/public_key.dart';
import 'package:aptos_core/src/crypto/ed25519/signature.dart';
import 'package:aptos_core/src/crypto/interface.dart';
import 'package:aptos_core/src/model/hex.dart';
import 'package:cryptography/cryptography.dart' as crypto_lib;

class Ed25519Algorithm
    implements
        Algorithm<Ed25519Signature, Ed25519PublicKey, Ed25519PrivateKey> {
  @override
  Future<KeyPair<Ed25519Signature, Ed25519PublicKey, Ed25519PrivateKey>>
  generateKeyPair() async {
    final algo = crypto_lib.Ed25519();
    final pair = await algo.newKeyPair();
    return await _extractPairFromLib(pair);
  }

  static Future<KeyPair<Ed25519Signature, Ed25519PublicKey, Ed25519PrivateKey>>
  _extractPairFromLib(crypto_lib.SimpleKeyPair pair) async {
    final publicKey = await pair.extractPublicKey();
    final privateKey = await pair.extractPrivateKeyBytes();
    return KeyPair(
      publicKey: Ed25519PublicKey(
        key: Hex.fromUint8Array(Uint8List.fromList(publicKey.bytes)),
      ),
      privateKey: Ed25519PrivateKey(
        key: Hex.fromUint8Array(Uint8List.fromList(privateKey)),
      ),
    );
  }

  static Future<KeyPair<Ed25519Signature, Ed25519PublicKey, Ed25519PrivateKey>>
  fromPrivateKey(Uint8List bytes) async {
    final algo = crypto_lib.Ed25519();
    final pair = await algo.newKeyPairFromSeed(bytes);
    return await _extractPairFromLib(pair);
  }

  static crypto_lib.SimpleKeyPairData _getLibPair(KeyPair pair) {
    return crypto_lib.SimpleKeyPairData(
      pair.privateKey.toUint8List(),
      publicKey: crypto_lib.SimplePublicKey(
        pair.publicKey.toUint8List(),
        type: crypto_lib.KeyPairType.ed25519,
      ),
      type: crypto_lib.KeyPairType.ed25519,
    );
  }

  static Future<Uint8List> signMessage(
    Uint8List message,
    Ed25519PrivateKey privateKey,
  ) async {
    final pair = await Ed25519Algorithm.fromPrivateKey(
      privateKey.toUint8List(),
    );
    final algo = crypto_lib.Ed25519();
    final libKeyPair = _getLibPair(pair);
    final signed = await algo.sign(message, keyPair: libKeyPair);
    return Uint8List.fromList(signed.bytes);
  }

  static Future<bool> verifySignature(
    Uint8List message,
    Ed25519Signature signature,
    Ed25519PublicKey publicKey,
  ) {
    final algo = crypto_lib.Ed25519();
    final libPublicKey = crypto_lib.SimplePublicKey(
      publicKey.toUint8List(),
      type: crypto_lib.KeyPairType.ed25519,
    );
    final libSignature = crypto_lib.Signature(
      signature.toUint8List().toList(),
      publicKey: libPublicKey,
    );
    return algo.verify(message, signature: libSignature);
  }

  @override
  String get name => "ed25519";
}
