import 'package:fpdart/fpdart.dart';
import 'package:proptrack/core/errors/failures.dart';
import 'package:proptrack/features/properties/domain/repositories/property_repository.dart';

class DeletePropertyUseCase {
  DeletePropertyUseCase(this._repository);

  final PropertyRepository _repository;

  Future<Either<Failure, Unit>> call(String id) =>
      _repository.deleteProperty(id);
}
