import 'package:fpdart/fpdart.dart';
import 'package:proptrack/core/errors/failures.dart';
import 'package:proptrack/features/installments/domain/entities/installment_entity.dart';
import 'package:proptrack/features/installments/domain/repositories/installment_repository.dart';

class ToggleInstallmentPaidUseCase {
  final InstallmentRepository _repository;

  ToggleInstallmentPaidUseCase(this._repository);

  Future<Either<Failure, InstallmentEntity>> call(String id, bool isPaid) =>
      _repository.togglePaid(id, isPaid);
}
