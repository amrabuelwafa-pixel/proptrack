import 'package:fpdart/fpdart.dart';
import 'package:proptrack/core/errors/failures.dart';

abstract interface class InstallmentRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getInstallments({
    String? propertyId,
  });
  Future<Either<Failure, Map<String, dynamic>>> createInstallment(
    Map<String, dynamic> data,
  );
  Future<Either<Failure, Map<String, dynamic>>> updateInstallment(
    String id,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, Unit>> deleteInstallment(String id);
  Future<Either<Failure, Unit>> markAsPaid(String id, DateTime paymentDate);
}
