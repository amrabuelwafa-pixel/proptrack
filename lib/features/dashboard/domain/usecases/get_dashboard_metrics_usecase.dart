import 'package:fpdart/fpdart.dart';
import 'package:proptrack/core/errors/failures.dart';
import 'package:proptrack/features/dashboard/domain/entities/dashboard_metrics.dart';
import 'package:proptrack/features/properties/domain/repositories/property_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GetDashboardMetricsUseCase {
  final PropertyRepository _propertyRepository;
  final SupabaseClient _supabaseClient;

  GetDashboardMetricsUseCase(
    this._propertyRepository,
    this._supabaseClient,
  );

  Future<Either<Failure, DashboardMetrics>> call() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        return Left(AuthFailure('User not authenticated'));
      }

      // Get all properties for the user
      final propertiesResult = await _propertyRepository.getProperties();

      return propertiesResult.fold(
        (failure) => Left(failure),
        (properties) async {
          // Calculate total properties and total invested
          final totalProperties = properties.length;
          final totalInvested =
              properties.fold<double>(0, (sum, p) => sum + p.totalPrice);

          // Get installments data from Supabase
          final installmentsResponse = await _supabaseClient
              .from('installments')
              .select()
              .eq('user_id', userId);

          final now = DateTime.now();
          final thirtyDaysLater = now.add(const Duration(days: 30));

          int upcomingCount = 0;
          double upcomingAmount = 0;
          int overdueCount = 0;
          double overdueAmount = 0;

          for (final inst in installmentsResponse) {
            final dueDate = DateTime.parse(inst['due_date'] as String);
            final amount = (inst['amount'] as num).toDouble();
            final isPaid = inst['is_paid'] as bool? ?? false;

            if (!isPaid) {
              if (dueDate.isBefore(now)) {
                // Overdue
                overdueCount++;
                overdueAmount += amount;
              } else if (dueDate.isBefore(thirtyDaysLater)) {
                // Upcoming (within 30 days)
                upcomingCount++;
                upcomingAmount += amount;
              }
            }
          }

          return Right(
            DashboardMetrics(
              totalProperties: totalProperties,
              totalInvested: totalInvested,
              upcomingPaymentsCount: upcomingCount,
              upcomingPaymentsAmount: upcomingAmount,
              overduePaymentsCount: overdueCount,
              overduePaymentsAmount: overdueAmount,
            ),
          );
        },
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
