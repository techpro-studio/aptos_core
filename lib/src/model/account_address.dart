import 'dart:typed_data';

import 'package:aptos_core/src/model.dart';
import 'package:bcs_serde/bcs_serde.dart';

class AccountAddress extends BCSSerializable {
  static const int length = 32;
  static const String _coreCodeAddress = "0x1";

  final Uint8List address;

  AccountAddress(this.address) {
    if (address.length != AccountAddress.length) {
      throw ArgumentError("Expected address of length 32");
    }
  }

  String hexAddress() => address.toHexWithPrefix();

  static AccountAddress coreCodeAddress() {
    return AccountAddress.fromHex(_coreCodeAddress);
  }

  static AccountAddress fromHex(String addr) {
    var address = addr.decodeHex().toHex();

    // If an address hex has odd number of digits, padd the hex string with 0
    // e.g. '1aa' would become '01aa'.
    if (address.length % 2 != 0) {
      address = "0$address";
    }

    Uint8List addressBytes = address.decodeHex();

    if (addressBytes.length > AccountAddress.length) {
      throw ArgumentError(
        "Hex string is too long. Address's length is 32 bytes.",
      );
    } else if (addressBytes.length == AccountAddress.length) {
      return AccountAddress(addressBytes);
    }

    final res = Uint8List(AccountAddress.length);
    res.setAll(AccountAddress.length - addressBytes.length, addressBytes);

    return AccountAddress(res);
  }

  static bool isValid(String addr) {
    // At least one zero is required
    if (addr.isEmpty) {
      return false;
    }

    var address = addr.decodeHex().toHex();

    // If an address hex has odd number of digits, padd the hex string with 0
    // e.g. '1aa' would become '01aa'.
    if (address.length % 2 != 0) {
      address = "0$address";
    }

    final addressBytes = address.decodeHex();

    return addressBytes.length <= AccountAddress.length;
  }

  static standardizeAddress(String address) {
    final lowercaseAddress = address.toLowerCase();
    final addressWithoutPrefix =
        lowercaseAddress.startsWith("0x")
            ? lowercaseAddress.substring(2)
            : lowercaseAddress;
    final addressWithPadding = addressWithoutPrefix.padLeft(64, "0");
    return "0x$addressWithPadding";
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountAddress &&
          runtimeType == other.runtimeType &&
          address == other.address;

  @override
  int get hashCode => address.hashCode;

  static const BCSSerializer<AccountAddress> bcsSerializer =
      _AccountAddressSerializer._();

  @override
  void serializeBCS(Serializer serializer) =>
      bcsSerializer.serializeIn(serializer, this);
}

class _AccountAddressSerializer implements BCSSerializer<AccountAddress> {
  const _AccountAddressSerializer._();

  @override
  AccountAddress deserializeIn(Deserializer deserializer) {
    return AccountAddress(
      deserializer.deserializeFixedBytes(AccountAddress.length),
    );
  }

  @override
  void serializeIn(Serializer serializer, AccountAddress value) {
    serializer.serializeFixedBytes(value.address);
  }
}
