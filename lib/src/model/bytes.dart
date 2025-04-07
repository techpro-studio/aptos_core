import 'dart:typed_data';

import 'package:hex/hex.dart';
import 'package:sha3/sha3.dart';

extension HexExtension on Uint8List {
  String toHex() => HEX.encode(toList());

  String toHexWithPrefix() => "0x${toHex()}";

  String toShortHex() {
    final hex = toHex();
    String trimmed = hex.replaceAll(RegExp("^0*"), "");
    return "0x$trimmed";
  }
}

extension SHA3Digest on Uint8List {
  Uint8List sha3Digest() {
    var sha3 = SHA3(256, SHA3_PADDING, 256);
    sha3.update(this);
    var hash = sha3.digest();
    return Uint8List.fromList(hash);
  }
}

extension HexStringExtension on String {
  Uint8List decodeHex() {
    final normalized = startsWith("0x") ? substring(2) : this;
    return Uint8List.fromList(HEX.decode(normalized));
  }
}
