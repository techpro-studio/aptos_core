import 'dart:convert';
import 'dart:typed_data';

import 'package:aptos_core/aptos_core.dart';
import 'package:poseidon/poseidon.dart';

const poseidonNumToHashFN = [
  poseidon1,
  poseidon2,
  poseidon3,
  poseidon4,
  poseidon5,
  poseidon6,
  poseidon7,
  poseidon8,
  poseidon9,
  poseidon10,
  poseidon11,
  poseidon12,
  poseidon13,
  poseidon14,
  poseidon15,
  poseidon16,
];

BigInt poseidonHash(List<BigInt> inputs) {
  try {
    if (inputs.length <= poseidonNumToHashFN.length) {
      Function hashFN = poseidonNumToHashFN[inputs.length - 1];
      return hashFN(inputs);
    } else if (inputs.length <= 32) {
      List<BigInt> hash1 = inputs.sublist(0, 16);
      List<BigInt> hash2 = inputs.sublist(16);
      return poseidonHash([poseidonHash(hash1), poseidonHash(hash2)]);
    } else {
      throw Exception(
        'Yet to implement: Unable to hash a vector of length ${inputs.length}',
      );
    }
  } catch (e) {
    throw Exception('poseidonHash error: $e');
  }
}

BigInt hashStringWithLen(String str, int maxSize) =>
    hashBytesWithLen(utf8.encode(str), maxSize);

BigInt hashBytesWithLen(Uint8List bytes, int maxSize) {
  final packed = padAndPackBytesWithLen(bytes, maxSize);
  return poseidonHash(packed);
}

List<BigInt> padAndPackBytesWithLen(Uint8List bytes, int maxSize) {
  final padAndPacked = padAndPackBytes(bytes, maxSize);
  padAndPacked.add(BigInt.from(bytes.length));
  return padAndPacked;
}

List<BigInt> padAndPackBytes(Uint8List bytes, int maxSize) {
  final padded = bytes.paddedWithZero(maxSize);
  return packBytes(padded);
}

List<BigInt> packBytes(Uint8List bytes) {
  return bytes.getChunked(31).map((e) => e.toBigIntLE()).toList();
}
