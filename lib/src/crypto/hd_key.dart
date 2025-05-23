import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

class KeyData {
  final List<int> key;
  final List<int> chainCode;

  const KeyData({required this.key, required this.chainCode});
}

const String ED25519_CURVE = 'ed25519 seed';

const int HARDENED_OFFSET = 0x80000000;

// Supported curve
const _ED25519HD ED25519_HD_KEY = _ED25519HD();

/// Implementation of ED25519 private key derivation from master private key
class _ED25519HD {
  static final _pathRegex = RegExp(r"^(m\/)?(\d+'?\/)*\d+'?$");

  const _ED25519HD();

  KeyData derivePath(
    String path,
    List<int> seedBytes, {
    int offset = HARDENED_OFFSET,
  }) {
    if (!_ED25519HD._pathRegex.hasMatch(path)) {
      throw ArgumentError(
        "Invalid derivation path. Expected BIP32 path format",
      );
    }

    KeyData master = getMasterKeyFromSeed(seedBytes);

    List<String> segments = path.split('/');
    segments = segments.sublist(1);

    KeyData result = master;

    for (String segment in segments) {
      int index = int.parse(segment.substring(0, segment.length - 1));
      result = _getCKDPriv(result, index + offset);
    }

    return result;
  }

  KeyData getMasterKeyFromSeed(
    List<int> seedBytes, {
    String masterSecret = ED25519_CURVE,
  }) => _getKeys(seedBytes, utf8.encode(masterSecret));

  KeyData _getCKDPriv(KeyData data, int index) {
    Uint8List dataBytes = Uint8List(37);
    dataBytes[0] = 0x00;
    dataBytes.setRange(1, 33, data.key);
    dataBytes.buffer.asByteData().setUint32(33, index);
    return _getKeys(dataBytes, data.chainCode);
  }

  KeyData _getKeys(List<int> data, List<int> keyParameter) {
    final hmac = Hmac(sha512, keyParameter);
    final mac = hmac.convert(data);

    final I = mac.bytes;
    final IL = I.sublist(0, 32);
    final IR = I.sublist(32);

    return KeyData(key: IL, chainCode: IR);
  }
}
