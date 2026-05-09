import 'package:proptrack/features/installments/data/models/installment_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class InstallmentRemoteDataSource {
  Future<List<InstallmentModel>> getByPropertyId(String propertyId);
  Future<InstallmentModel> togglePaid(String id, bool isPaid);
}

class InstallmentRemoteDataSourceImpl implements InstallmentRemoteDataSource {
  final SupabaseClient _client;

  InstallmentRemoteDataSourceImpl(this._client);

  @override
  Future<List<InstallmentModel>> getByPropertyId(String propertyId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _client
        .from('installments')
        .select()
        .eq('property_id', propertyId)
        .eq('user_id', userId)
        .order('due_date');

    return (response as List<dynamic>).map((json) => InstallmentModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<InstallmentModel> togglePaid(String id, bool isPaid) async {
    final response = await _client
        .from('installments')
        .update({
          'is_paid': isPaid,
          'paid_at': isPaid ? DateTime.now().toIso8601String() : null,
        })
        .eq('id', id)
        .select()
        .single();

    return InstallmentModel.fromJson(response);
  }
}
