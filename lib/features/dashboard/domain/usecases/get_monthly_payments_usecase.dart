import 'package:fpdart/fpdart.dart';
import 'package:proptrack/core/errors/failures.dart';
import 'package:proptrack/features/dashboard/domain/entities/monthly_payments.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Returns [monthsBack] monthly buckets (oldest first → current month).
/// For each month, `paid` sums installments with `paid_at` in that month,
/// and `due` sums installments with `due_date` in that month.
class GetMonthlyPaymentsUseCase {
  GetMonthlyPaymentsUseCase(this._supabaseClient);

  final SupabaseClient _supabaseClient;

  Future<Either<Failure, List<MonthlyPaymentBucket>>> call({
    int monthsBack = 6,
  }) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        return Left(AuthFailure('User not authenticated'));
      }

      final now = DateTime.now();
      final start = DateTime(now.year, now.month - (monthsBack - 1));
      final end = DateTime(now.year, now.month + 1); // exclusive upper

      final rows = await _supabaseClient
          .from('installments')
          .select('amount, due_date, paid_at, is_paid')
          .eq('user_id', userId);

      // Pre-seed buckets so empty months still render.
      final buckets = <DateTime, _Acc>{};
      for (var i = 0; i < monthsBack; i++) {
        final m = DateTime(start.year, start.month + i);
        buckets[m] = _Acc();
      }

      bool inWindow(DateTime d) => !d.isBefore(start) && d.isBefore(end);
      DateTime monthOf(DateTime d) => DateTime(d.year, d.month);

      for (final row in rows) {
        final amount = (row['amount'] as num).toDouble();
        final dueRaw = row['due_date'] as String?;
        final paidRaw = row['paid_at'] as String?;
        final isPaid = row['is_paid'] as bool? ?? false;

        if (dueRaw != null) {
          final due = DateTime.parse(dueRaw);
          if (inWindow(due)) {
            buckets[monthOf(due)]?.due += amount;
          }
        }
        if (isPaid && paidRaw != null) {
          final paid = DateTime.parse(paidRaw);
          if (inWindow(paid)) {
            buckets[monthOf(paid)]?.paid += amount;
          }
        }
      }

      final out = buckets.entries
          .map(
            (e) => MonthlyPaymentBucket(
              month: e.key,
              paid: e.value.paid,
              due: e.value.due,
            ),
          )
          .toList()
        ..sort((a, b) => a.month.compareTo(b.month));

      return Right(out);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class _Acc {
  double paid = 0;
  double due = 0;
}
