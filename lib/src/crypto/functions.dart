import 'dart:math' as math;
import 'dart:typed_data';

Uint8List generateRandomBytes(int length) {
  final random = math.Random.secure();
  return Uint8List.fromList(
    List<int>.generate(length, (_) => random.nextInt(256)),
  );
}

extension UIntListExt on Uint8List {
  List<Uint8List> getChunked(int chunkSize) {
    final result = <Uint8List>[];
    for (int i = 0; i < length; i += chunkSize) {
      result.add(sublist(i, math.min(i + chunkSize, length)));
    }
    return result;
  }

  Uint8List paddedWithZero(int length) {
    final padded = Uint8List.fromList(List.filled(length, 0));
    padded.setAll(0, this);
    return padded;
  }

  BigInt toBigIntLE() {
    final beBytes = reversed.toList();
    BigInt result = BigInt.zero;
    for (int byte in beBytes) {
      result = (result << 8) | BigInt.from(byte);
    }
    return result;
  }
}

extension BigIntExt on BigInt {
  Uint8List toBytesLE(int length) {
    final bytes = Uint8List(length);
    BigInt val = this;
    for (int i = 0; i < length; i++) {
      bytes[i] = (val & BigInt.from(0xff)).toInt();
      val = val >> 8;
    }
    return bytes;
  }
}

int secondsRoundedToClosestHour(int seconds) {
  final date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  final rounded = DateTime(date.year, date.month, date.day, date.hour);
  return rounded.millisecondsSinceEpoch ~/ 1000;
}
