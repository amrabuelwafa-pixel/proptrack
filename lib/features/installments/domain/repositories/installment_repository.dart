import 'package:fpdart/fpdart.dart';
import 'package:proptrack/core/errors/failures.dart';
import 'package:proptrack/features/installments/domain/entities/installment_entity.dart';

abstract interface class InstallmentRepository {
  Future<Either<Failure, List<InstallmentEntity>>> getByPropertyId(String propertyId);
  Future<Either<Failure, InstallmentEntity>> togglePaid(String id, bool isPaid);
}
