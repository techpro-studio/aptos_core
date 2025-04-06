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
  Future<Ed25519PrivateKey> generatePrivateKey() async {
    final algo = crypto_lib.Ed25519();
    final pair = await algo.newKeyPair();
    return await _extractPrivateKey(pair);
  }

  @override
  Future<Ed25519PrivateKey> getFromSeed(Uint8List seed) => fromSeed(seed);

  static Future<Ed25519PrivateKey> _extractPrivateKey(
    crypto_lib.SimpleKeyPair pair,
  ) async {
    final privateKey = await pair.extractPrivateKeyBytes();
    return Ed25519PrivateKey(
      key: Hex.fromUint8Array(Uint8List.fromList(privateKey)),
    );
  }

  static Future<Ed25519PrivateKey> fromSeed(Uint8List bytes) async {
    final algo = crypto_lib.Ed25519();
    final pair = await algo.newKeyPairFromSeed(bytes);
    return await _extractPrivateKey(pair);
  }

  static Future<Ed25519PublicKey> publicFromPrivateKey(
    Ed25519PrivateKey privateKey,
  ) async {
    final algo = crypto_lib.Ed25519();
    final pair = await algo.newKeyPairFromSeed(privateKey.toUint8List());
    final publicKey = await pair.extractPublicKey();
    return Ed25519PublicKey(
      key: Hex.fromUint8Array(Uint8List.fromList(publicKey.bytes)),
    );
  }

  static Future<Uint8List> signMessage(
    Uint8List message,
    Ed25519PrivateKey privateKey,
  ) async {
    final algo = crypto_lib.Ed25519();
    final publicKey = await privateKey.getPublicKey();
    final libKeyPair = crypto_lib.SimpleKeyPairData(
      privateKey.toUint8List(),
      publicKey: crypto_lib.SimplePublicKey(
        publicKey.toUint8List(),
        type: crypto_lib.KeyPairType.ed25519,
      ),
      type: crypto_lib.KeyPairType.ed25519,
    );
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
