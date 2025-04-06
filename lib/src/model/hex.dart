import 'dart:typed_data';

import 'package:hex/hex.dart';

extension HexExtension on Uint8List {
  String toHex() => HEX.encode(toList());

  String toHexWithPrefix() => "0x${toHex()}";

  String toShortHex() {
    final hex = toHex();
    String trimmed = hex.replaceAll(RegExp("^0*"), "");
    return "0x$trimmed";
  }
}

extension HexStringExtension on String {
  Uint8List decodeHex() {
    final normalized = startsWith("0x") ? substring(2) : this;
    return Uint8List.fromList(HEX.decode(normalized));
  }
}
