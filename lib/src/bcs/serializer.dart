import 'dart:convert';
import 'dart:typed_data';

import 'package:aptos_core/src/bcs/consts.dart';

class Serializer {
  Uint8List buffer = Uint8List(64);
  int offset = 0;

  void _ensureBufferWillHandleSize(int bytes) {
    while (buffer.length < offset + bytes) {
      final newBuffer = Uint8List(buffer.lengthInBytes * 2);
      newBuffer.setAll(0, buffer);
      buffer = newBuffer;
    }
  }

  void serialize(Uint8List values) {
    _ensureBufferWillHandleSize(values.length);
    buffer.setAll(offset, values);
    offset += values.length;
  }

  void serializeStr(String value) {
    serializeBytes(Uint8List.fromList(utf8.encode(value)));
  }

  void serializeOptionalStr(String? value) {
    if (value != null) {
      serializeBool(true);
      serializeBytes(Uint8List.fromList(utf8.encode(value)));
    } else {
      serializeBool(false);
    }
  }

  void serializeBytes(Uint8List value) {
    serializeU32AsUleb128(value.length);
    serialize(value);
  }

  void serializeOptionalFixedBytes(Uint8List? value) {
    if (value != null) {
      serializeBool(true);
      serializeFixedBytes(value);
    } else {
      serializeBool(false);
    }
  }

  void serializeFixedBytes(Uint8List value) {
    serialize(value);
  }

  void serializeBool(bool value) {
    final byteValue = value ? 1 : 0;
    serialize(Uint8List.fromList([byteValue]));
  }

  void serializeU8(int value) {
    checkNumberRange(BigInt.from(value), BigInt.zero, BigInt.from(maxU8Number));

    serialize(Uint8List.fromList([value]));
  }

  void serializeU16(int value) {
    checkNumberRange(
      BigInt.from(value),
      BigInt.zero,
      BigInt.from(maxU16Number),
    );

    int bytesLength = 2;
    _ensureBufferWillHandleSize(bytesLength);
    final bd = ByteData.sublistView(buffer);
    bd.setUint16(offset, value, Endian.little);
    offset += bytesLength;
  }

  void serializeU32(int value) {
    checkNumberRange(
      BigInt.from(value),
      BigInt.zero,
      BigInt.from(maxU32Number),
    );

    int bytesLength = 4;
    _ensureBufferWillHandleSize(bytesLength);
    final bd = ByteData.sublistView(buffer);
    bd.setUint32(offset, value, Endian.little);
    offset += bytesLength;
  }

  void serializeU64(BigInt value) {
    checkNumberRange(value, BigInt.zero, maxU64BigInt);

    final low = value & BigInt.from(maxU32Number);
    final high = value >> 32;

    // write little endian number
    serializeU32(low.toInt());
    serializeU32(high.toInt());
  }

  void serializeU128(BigInt value) {
    checkNumberRange(value, BigInt.zero, maxU128BigInt);

    final low = value & maxU64BigInt;
    final high = value >> 64;

    // write little endian number
    serializeU64(low);
    serializeU64(high);
  }

  void serializeU256(BigInt value) {
    checkNumberRange(value, BigInt.zero, maxU256BigInt);

    final low = value & maxU128BigInt;
    final high = value >> 128;

    // write little endian number
    serializeU128(low);
    serializeU128(high);
  }

  void serializeU32AsUleb128(int val) {
    checkNumberRange(BigInt.from(val), BigInt.zero, BigInt.from(maxU32Number));

    var value = val;
    var valueArray = <int>[];
    while (value >>> 7 != 0) {
      valueArray.add((value & 0x7f) | 0x80);
      value >>>= 7;
    }
    valueArray.add(value);
    serialize(Uint8List.fromList(valueArray));
  }

  Uint8List getBytes() {
    return buffer.sublist(0, offset);
  }

  void checkNumberRange(
    BigInt value,
    BigInt minValue,
    BigInt maxValue, [
    String? message,
  ]) {
    if (value > maxValue || value < minValue) {
      throw ArgumentError(message ?? "Value is out of range");
    }
  }
}
