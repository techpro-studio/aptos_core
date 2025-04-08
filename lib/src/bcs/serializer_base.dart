import 'dart:typed_data';

import 'package:aptos_core/src/bcs/deserializer.dart';
import 'package:aptos_core/src/bcs/serializer.dart';
import 'package:aptos_core/src/model/bytes.dart';

abstract class BCSSerializable {
  void serializeBCS(Serializer serializer);
}

extension SerializableExtension on BCSSerializable {
  Uint8List bcsToBytes() {
    final serializer = Serializer();
    serializeBCS(serializer);
    return serializer.getBytes();
  }

  String bcsToHex() => bcsToBytes().toHex();
}

abstract class BCSSerializer<T> {
  void serializeIn(Serializer serializer, T value);

  T deserializeIn(Deserializer deserializer);
}

extension BCSSerializerExt<T> on BCSSerializer<T> {
  Uint8List serialize(T value) {
    final serializer = Serializer();
    serializeIn(serializer, value);
    return serializer.getBytes();
  }

  void serializeOptionalIn(Serializer serializer, T? value) {
    serializer.serializeBool(value != null);
    if (value != null) {
      serializeIn(serializer, value);
    }
  }

  T? deserializeOptionalIn(Deserializer deserializer) {
    final exists = deserializer.deserializeBool();
    if (!exists) {
      return null;
    }
    return deserializeIn(deserializer);
  }

  T deserialize(Uint8List bytes) {
    final deserializer = Deserializer(bytes);
    return deserializeIn(deserializer);
  }
}
