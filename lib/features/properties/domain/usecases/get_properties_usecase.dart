import 'package:fpdart/fpdart.dart';
import 'package:proptrack/core/errors/failures.dart';
import 'package:proptrack/features/properties/domain/entities/property_entity.dart';
import 'package:proptrack/features/properties/domain/repositories/property_repository.dart';

class GetPropertiesUseCase {
  GetPropertiesUseCase(this._repository);

  final PropertyRepository _repository;

  Future<Either<Failure, List<PropertyEntity>>> call() =>
      _repository.getProperties();
}
