import 'dart:typed_data';

import 'package:hex/hex.dart';

class Hex {
  final Uint8List _bytes;
  final String _hexString;

  Hex._(this._bytes, this._hexString);

  factory Hex.fromUint8Array(Uint8List arr) {
    return Hex._(arr, HEX.encode(arr.toList()));
  }

  factory Hex.ensure(String hexString) {
    return Hex(hexString);
  }

  factory Hex(String hexString) {
    final normalized =
        hexString.startsWith("0x") ? hexString.substring(2) : hexString;
    return Hex._(Uint8List.fromList(HEX.decode(normalized)), normalized);
  }

  String hex() => "0x$_hexString";

  String noPrefix() => _hexString;

  @override
  String toString() => hex();

  String toShortString() {
    String trimmed = _hexString.replaceAll(RegExp("^0*"), "");
    return "0x$trimmed";
  }

  Uint8List toUint8Array() => _bytes;
}
