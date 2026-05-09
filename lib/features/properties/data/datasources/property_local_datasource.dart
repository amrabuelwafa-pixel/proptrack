import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:proptrack/features/properties/data/models/property_model.dart';

abstract interface class PropertyLocalDataSource {
  Future<List<PropertyModel>> getAll();
  Future<void> saveAll(List<PropertyModel> properties);
  Future<void> clear();
}

class PropertyLocalDataSourceImpl implements PropertyLocalDataSource {
  PropertyLocalDataSourceImpl(this._box);

  final Box<dynamic> _box;
  static const String _cacheKey = 'properties_cache';

  @override
  Future<List<PropertyModel>> getAll() async {
    try {
      final cached = _box.get(_cacheKey) as String?;
      if (cached == null) return [];

      final json = jsonDecode(cached) as List<dynamic>;
      return json
          .map((item) => PropertyModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveAll(List<PropertyModel> properties) async {
    try {
      final json = jsonEncode(properties.map((p) => p.toJson()).toList());
      await _box.put(_cacheKey, json);
    } catch (e) {
      // Silently fail — cache is optional
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _box.delete(_cacheKey);
    } catch (e) {
      // Silently fail
    }
  }
}
