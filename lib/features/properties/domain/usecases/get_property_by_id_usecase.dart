import 'package:fpdart/fpdart.dart';
import 'package:proptrack/core/errors/failures.dart';
import 'package:proptrack/features/properties/domain/entities/property_entity.dart';
import 'package:proptrack/features/properties/domain/repositories/property_repository.dart';

class GetPropertyByIdUseCase {
  GetPropertyByIdUseCase(this._repository);

  final PropertyRepository _repository;

  Future<Either<Failure, PropertyEntity>> call(String id) =>
      _repository.getPropertyById(id);
}
