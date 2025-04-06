import 'dart:typed_data';

import 'package:aptos_core/src/bcs.dart';

class G1Bytes implements BCSSerializable {
  final Uint8List bytes;
  static const size = 32;

  G1Bytes._({required this.bytes});

  factory G1Bytes(Uint8List bytes) {
    if (bytes.length != size) {
      throw ArgumentError('Invalid size');
    }
    return G1Bytes._(bytes: bytes);
  }

  static const BCSSerializer<G1Bytes> bcsSerializer = _G1BytesSerializer._();

  @override
  void serializeBCS(Serializer serializer) {
    bcsSerializer.serializeIn(serializer, this);
  }
}

class _G1BytesSerializer implements BCSSerializer<G1Bytes> {
  const _G1BytesSerializer._();
  @override
  G1Bytes deserializeIn(Deserializer deserializer) {
    return G1Bytes(deserializer.deserializeFixedBytes(G1Bytes.size));
  }

  @override
  void serializeIn(Serializer serializer, G1Bytes value) {
    serializer.serializeFixedBytes(value.bytes);
  }
}

class G2Bytes implements BCSSerializable {
  final Uint8List bytes;
  static const size = 64;

  G2Bytes._({required this.bytes});

  factory G2Bytes(Uint8List bytes) {
    if (bytes.length != size) {
      throw ArgumentError('Invalid size');
    }
    return G2Bytes._(bytes: bytes);
  }

  static const BCSSerializer<G2Bytes> bcsSerializer = _G2BytesSerializer._();

  @override
  void serializeBCS(Serializer serializer) {
    bcsSerializer.serializeIn(serializer, this);
  }
}

class _G2BytesSerializer implements BCSSerializer<G2Bytes> {
  const _G2BytesSerializer._();
  @override
  G2Bytes deserializeIn(Deserializer deserializer) {
    return G2Bytes(deserializer.deserializeFixedBytes(G2Bytes.size));
  }

  @override
  void serializeIn(Serializer serializer, G2Bytes value) {
    serializer.serializeFixedBytes(value.bytes);
  }
}

class Groth16Zkp {
  final G1Bytes a;
  final G2Bytes b;
  final G1Bytes c;

  static const BCSSerializer<Groth16Zkp> bcsSerializer =
      _Groth16ZkpSerializer._();

  Groth16Zkp({required this.a, required this.b, required this.c});
}

class _Groth16ZkpSerializer implements BCSSerializer<Groth16Zkp> {
  const _Groth16ZkpSerializer._();
  @override
  Groth16Zkp deserializeIn(Deserializer deserializer) {
    final a = G1Bytes.bcsSerializer.deserializeIn(deserializer);
    final b = G2Bytes.bcsSerializer.deserializeIn(deserializer);
    final c = G1Bytes.bcsSerializer.deserializeIn(deserializer);
    return Groth16Zkp(a: a, b: b, c: c);
  }

  @override
  void serializeIn(Serializer serializer, Groth16Zkp value) {
    value.a.serializeBCS(serializer);
    value.b.serializeBCS(serializer);
    value.c.serializeBCS(serializer);
  }
}
