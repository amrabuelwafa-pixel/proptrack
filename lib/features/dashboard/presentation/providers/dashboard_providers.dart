import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proptrack/core/providers/supabase_provider.dart';
import 'package:proptrack/features/dashboard/domain/entities/dashboard_metrics.dart';
import 'package:proptrack/features/dashboard/domain/entities/upcoming_installment.dart';
import 'package:proptrack/features/dashboard/domain/usecases/get_dashboard_metrics_usecase.dart';
import 'package:proptrack/features/dashboard/domain/usecases/get_next_installments_usecase.dart';
import 'package:proptrack/features/properties/presentation/providers/property_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final dashboardMetricsProvider = FutureProvider<DashboardMetrics>((ref) async {
  final supabaseClient = ref.watch(supabaseClientProvider);
  final propertyRepository = ref.watch(propertyRepositoryProvider);

  final useCase = GetDashboardMetricsUseCase(propertyRepository, supabaseClient);
  final result = await useCase();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (metrics) => metrics,
  );
});

final nextInstallmentsProvider =
    FutureProvider<List<UpcomingInstallment>>((ref) async {
  final supabaseClient = ref.watch(supabaseClientProvider);

  final useCase = GetNextInstallmentsUseCase(supabaseClient);
  final result = await useCase();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (installments) => installments,
  );
});
