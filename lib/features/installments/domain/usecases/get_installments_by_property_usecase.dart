import 'package:fpdart/fpdart.dart';
import 'package:proptrack/core/errors/failures.dart';
import 'package:proptrack/features/installments/domain/entities/installment_entity.dart';
import 'package:proptrack/features/installments/domain/repositories/installment_repository.dart';

class GetInstallmentsByPropertyUseCase {
  final InstallmentRepository _repository;

  GetInstallmentsByPropertyUseCase(this._repository);

  Future<Either<Failure, List<InstallmentEntity>>> call(String propertyId) =>
      _repository.getByPropertyId(propertyId);
}
