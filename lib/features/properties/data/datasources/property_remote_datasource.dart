import 'package:proptrack/features/properties/data/models/property_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class PropertyRemoteDataSource {
  Future<List<PropertyModel>> getProperties();
  Future<PropertyModel> getPropertyById(String id);
  Future<PropertyModel> createProperty({
    required String name,
    String? developer,
    String? location,
    required double totalPrice,
    required String currency,
    DateTime? handoverDate,
    String? notes,
  });
  Future<PropertyModel> updateProperty({
    required String id,
    required String name,
    String? developer,
    String? location,
    required double totalPrice,
    required String currency,
    DateTime? handoverDate,
    String? notes,
  });
  Future<void> deleteProperty(String id);
}

class PropertyRemoteDataSourceImpl implements PropertyRemoteDataSource {
  final SupabaseClient _client;

  PropertyRemoteDataSourceImpl(this._client);

  @override
  Future<List<PropertyModel>> getProperties() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _client
        .from('properties')
        .select('*, installments(amount, is_paid)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((json) => PropertyModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PropertyModel> getPropertyById(String id) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _client
        .from('properties')
        .select('*, installments(amount, is_paid)')
        .eq('id', id)
        .eq('user_id', userId)
        .single();

    return PropertyModel.fromJson(response);
  }

  @override
  Future<PropertyModel> createProperty({
    required String name,
    String? developer,
    String? location,
    required double totalPrice,
    required String currency,
    DateTime? handoverDate,
    String? notes,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _client
        .from('properties')
        .insert({
          'user_id': userId,
          'name': name,
          'developer': developer,
          'location': location,
          'total_price': totalPrice,
          'currency': currency,
          'handover_date': handoverDate?.toIso8601String(),
          'notes': notes,
        })
        .select('*, installments(amount, is_paid)')
        .single();

    return PropertyModel.fromJson(response);
  }

  @override
  Future<PropertyModel> updateProperty({
    required String id,
    required String name,
    String? developer,
    String? location,
    required double totalPrice,
    required String currency,
    DateTime? handoverDate,
    String? notes,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _client
        .from('properties')
        .update({
          'name': name,
          'developer': developer,
          'location': location,
          'total_price': totalPrice,
          'currency': currency,
          'handover_date': handoverDate?.toIso8601String(),
          'notes': notes,
        })
        .eq('id', id)
        .eq('user_id', userId)
        .select('*, installments(amount, is_paid)')
        .single();

    return PropertyModel.fromJson(response);
  }

  @override
  Future<void> deleteProperty(String id) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _client
        .from('properties')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }
}
