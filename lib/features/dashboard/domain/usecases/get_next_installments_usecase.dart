import 'package:fpdart/fpdart.dart';
import 'package:proptrack/core/errors/failures.dart';
import 'package:proptrack/features/dashboard/domain/entities/upcoming_installment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GetNextInstallmentsUseCase {
  final SupabaseClient _supabaseClient;

  GetNextInstallmentsUseCase(this._supabaseClient);

  Future<Either<Failure, List<UpcomingInstallment>>> call() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        return Left(AuthFailure('User not authenticated'));
      }

      // Get installments with property names, ordered by due_date
      final response = await _supabaseClient
          .from('installments')
          .select(
            '''
            id,
            due_date,
            amount,
            is_paid,
            properties(name)
            '''
          )
          .eq('user_id', userId)
          .eq('is_paid', false)
          .order('due_date');

      final now = DateTime.now();
      final installments = <UpcomingInstallment>[];

      for (final inst in response) {
        final dueDate = DateTime.parse(inst['due_date'] as String);
        final isOverdue = dueDate.isBefore(now);

        installments.add(
          UpcomingInstallment(
            id: inst['id'] as String,
            propertyName: (inst['properties'] as Map?)?['name'] as String? ?? 'Unknown',
            dueDate: dueDate,
            amount: (inst['amount'] as num).toDouble(),
            isOverdue: isOverdue,
          ),
        );
      }

      // Return next 5 installments (sorted by due date)
      return Right(installments.take(5).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
