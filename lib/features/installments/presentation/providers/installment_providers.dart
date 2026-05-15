import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proptrack/core/providers/supabase_provider.dart';
import 'package:proptrack/features/installments/data/datasources/installment_remote_datasource.dart';
import 'package:proptrack/features/installments/data/repositories/installment_repository_impl.dart';
import 'package:proptrack/features/installments/domain/entities/installment_entity.dart';
import 'package:proptrack/features/installments/domain/repositories/installment_repository.dart';
import 'package:proptrack/features/installments/domain/usecases/get_installments_by_property_usecase.dart';
import 'package:proptrack/features/installments/domain/usecases/toggle_installment_paid_usecase.dart';

final installmentRemoteDataSourceProvider =
    Provider<InstallmentRemoteDataSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return InstallmentRemoteDataSourceImpl(client);
});

final installmentRepositoryProvider = Provider<InstallmentRepository>((ref) {
  final dataSource = ref.watch(installmentRemoteDataSourceProvider);
  return InstallmentRepositoryImpl(dataSource);
});

final getInstallmentsByPropertyUseCaseProvider =
    Provider<GetInstallmentsByPropertyUseCase>((ref) {
  final repository = ref.watch(installmentRepositoryProvider);
  return GetInstallmentsByPropertyUseCase(repository);
});

final toggleInstallmentPaidUseCaseProvider =
    Provider<ToggleInstallmentPaidUseCase>((ref) {
  final repository = ref.watch(installmentRepositoryProvider);
  return ToggleInstallmentPaidUseCase(repository);
});

class _InstallmentNotifier
    extends StateNotifier<AsyncValue<List<InstallmentEntity>>> {
  _InstallmentNotifier(this._ref, this._propertyId)
      : super(const AsyncLoading()) {
    _load();
  }

  final Ref _ref;
  final String _propertyId;

  Future<void> _load() async {
    try {
      state = const AsyncLoading();
      final useCase = _ref.read(getInstallmentsByPropertyUseCaseProvider);
      final result = await useCase(_propertyId);
      state = result.fold(
        (failure) =>
            AsyncError<List<InstallmentEntity>>(failure, StackTrace.current),
        (installments) => AsyncData(installments),
      );
    } on Exception catch (e, st) {
      state = AsyncError<List<InstallmentEntity>>(e, st);
    }
  }

  Future<bool> togglePaid(String id, bool isPaid) async {
    try {
      final useCase = _ref.read(toggleInstallmentPaidUseCaseProvider);
      final result = await useCase(id, isPaid);
      return result.fold(
        (failure) {
          state =
              AsyncError<List<InstallmentEntity>>(failure, StackTrace.current);
          return false;
        },
        (_) {
          _load();
          return true;
        },
      );
    } on Exception {
      return false;
    }
  }
}

final installmentNotifierProvider = StateNotifierProvider.family<
    _InstallmentNotifier, AsyncValue<List<InstallmentEntity>>, String>(
  (ref, propertyId) => _InstallmentNotifier(ref, propertyId),
);
