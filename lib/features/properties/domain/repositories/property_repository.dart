import 'package:fpdart/fpdart.dart';
import 'package:proptrack/core/errors/failures.dart';

abstract interface class PropertyRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getProperties();
  Future<Either<Failure, Map<String, dynamic>>> getPropertyById(String id);
  Future<Either<Failure, Map<String, dynamic>>> createProperty(
    Map<String, dynamic> data,
  );
  Future<Either<Failure, Map<String, dynamic>>> updateProperty(
    String id,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, Unit>> deleteProperty(String id);
}
