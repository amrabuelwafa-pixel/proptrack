import 'package:fpdart/fpdart.dart';
import 'package:proptrack/core/errors/failures.dart';
import 'package:proptrack/features/properties/domain/entities/property_entity.dart';

abstract interface class PropertyRepository {
  Future<Either<Failure, List<PropertyEntity>>> getProperties();
  Future<Either<Failure, PropertyEntity>> getPropertyById(String id);
  Future<Either<Failure, PropertyEntity>> createProperty(
    CreatePropertyParams params,
  );
  Future<Either<Failure, PropertyEntity>> updateProperty(
    UpdatePropertyParams params,
  );
  Future<Either<Failure, Unit>> deleteProperty(String id);
}

class CreatePropertyParams {
  final String name;
  final String? developer;
  final String? location;
  final double totalPrice;
  final String currency;
  final DateTime? handoverDate;
  final String? notes;

  CreatePropertyParams({
    required this.name,
    this.developer,
    this.location,
    required this.totalPrice,
    required this.currency,
    this.handoverDate,
    this.notes,
  });
}

class UpdatePropertyParams {
  final String id;
  final String name;
  final String? developer;
  final String? location;
  final double totalPrice;
  final String currency;
  final DateTime? handoverDate;
  final String? notes;

  UpdatePropertyParams({
    required this.id,
    required this.name,
    this.developer,
    this.location,
    required this.totalPrice,
    required this.currency,
    this.handoverDate,
    this.notes,
  });
}
