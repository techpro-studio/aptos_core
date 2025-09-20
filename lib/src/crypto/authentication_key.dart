import 'dart:typed_data';

import 'package:aptos_core/aptos_core.dart';
import 'package:bcs_serde/bcs_serde.dart';

class AuthenticationKey implements BCSSerializable {
  static const int size = 32;

  final Uint8List _key;

  AuthenticationKey._({required Uint8List key})
    : assert(key.length == size, 'Invalid key length'),
      _key = key;

  AccountAddress get derivedAddress => AccountAddress(_key);

  factory AuthenticationKey.fromSchemeAndBytes(
    SigningScheme scheme,
    Uint8List bytes,
  ) {
    final hashInput = bytes.toList();
    hashInput.add(scheme.value);
    final hash = Uint8List.fromList(hashInput).sha3Digest();
    return AuthenticationKey._(key: hash);
  }

  static const BCSSerializer<AuthenticationKey> bcsSerializer =
      _AuthenticationKeyBcsSerializer._();

  @override
  void serializeBCS(Serializer serializer) =>
      bcsSerializer.serializeIn(serializer, this);
}

class _AuthenticationKeyBcsSerializer
    implements BCSSerializer<AuthenticationKey> {
  const _AuthenticationKeyBcsSerializer._();

  @override
  AuthenticationKey deserializeIn(Deserializer deserializer) {
    return AuthenticationKey._(
      key: deserializer.deserializeFixedBytes(AuthenticationKey.size),
    );
  }

  @override
  void serializeIn(Serializer serializer, AuthenticationKey value) {
    serializer.serializeFixedBytes(value._key);
  }
}
