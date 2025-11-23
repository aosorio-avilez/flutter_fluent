import 'package:flutter/material.dart'; // Para ByteData si es necesario
import 'package:flutter/services.dart';

class FakeAssetBundle extends AssetBundle {
  FakeAssetBundle(this.data);

  final Map<String, String> data;

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (data.containsKey(key)) {
      return data[key]!;
    }
    throw FlutterError('Asset not found: $key');
  }

  @override
  Future<ByteData> load(String key) async {
    // No lo necesitamos para JSONs, pero es requerido por la interfaz
    throw UnimplementedError();
  }
}
