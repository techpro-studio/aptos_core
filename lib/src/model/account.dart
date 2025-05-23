import 'dart:typed_data';

import 'package:aptos_core/aptos_core.dart';
import 'package:aptos_core/src/crypto/hd_key.dart';
import 'package:bip39_mnemonic/bip39_mnemonic.dart' as bip39;

class SingleKeyAccount implements BCSSerializable {
  final Ed25519PrivateKey privateKey;
  final AccountAddress address;
  final AnyPublicKey publicKey;

  factory SingleKeyAccount.generateFromSeed(Uint8List seed) {
    final Ed25519Algorithm algorithm = Ed25519Algorithm();
    final Ed25519PrivateKey privateKey = algorithm.privateKeyFromSeed(seed);
    final publicKey = AnyPublicKey(
      variant: AnyPublicKeyVariant.ed25519,
      key: privateKey.getPublicKey(),
    );

    return SingleKeyAccount._(
      privateKey: privateKey,
      publicKey: publicKey,
      address: publicKey.authKey.derivedAddress,
    );
  }

  static const defaultDerivationPath = "m/44'/637'/0'/0'/0'";

  factory SingleKeyAccount.generate() {
    final Ed25519Algorithm algorithm = Ed25519Algorithm();
    final Ed25519PrivateKey privateKey = algorithm.generatePrivateKey();
    final publicKey = AnyPublicKey(
      variant: AnyPublicKeyVariant.ed25519,
      key: privateKey.getPublicKey(),
    );

    return SingleKeyAccount._(
      privateKey: privateKey,
      publicKey: publicKey,
      address: publicKey.authKey.derivedAddress,
    );
  }

  factory SingleKeyAccount.fromDerivationPath(
    String mnemonics, {
    String derivationPath = defaultDerivationPath,
  }) {
    final mnemonic = bip39.Mnemonic.fromSentence(
      mnemonics,
      bip39.Language.english,
    );
    final data = ED25519_HD_KEY.derivePath(derivationPath, mnemonic.seed);
    return SingleKeyAccount.generateFromSeed(Uint8List.fromList(data.key));
  }

  SingleKeyAccount._({
    required this.privateKey,
    required this.publicKey,
    required this.address,
  });

  static const BCSSerializer<SingleKeyAccount> bcsSerializer =
      _SingleKeyAccountSerializer();

  @override
  void serializeBCS(Serializer serializer) {
    bcsSerializer.serializeIn(serializer, this);
  }
}

class _SingleKeyAccountSerializer implements BCSSerializer<SingleKeyAccount> {
  const _SingleKeyAccountSerializer();

  @override
  SingleKeyAccount deserializeIn(Deserializer deserializer) {
    final privateKeyBytes = deserializer.deserializeBytes();
    final publicKey = AnyPublicKey.bcsSerializer.deserializeIn(deserializer);
    final address = AccountAddress.bcsSerializer.deserializeIn(deserializer);
    return SingleKeyAccount._(
      privateKey: Ed25519PrivateKey(key: privateKeyBytes),
      publicKey: publicKey,
      address: address,
    );
  }

  @override
  void serializeIn(Serializer serializer, SingleKeyAccount value) {
    serializer.serializeBytes(value.privateKey.toUint8List());
    value.publicKey.serializeBCS(serializer);
    value.address.serializeBCS(serializer);
  }
}
