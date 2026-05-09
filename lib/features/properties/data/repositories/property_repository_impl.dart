import 'package:fpdart/fpdart.dart';
import 'package:proptrack/core/errors/failures.dart';
import 'package:proptrack/features/properties/data/datasources/property_local_datasource.dart';
import 'package:proptrack/features/properties/data/datasources/property_remote_datasource.dart';
import 'package:proptrack/features/properties/domain/entities/property_entity.dart';
import 'package:proptrack/features/properties/domain/repositories/property_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PropertyRepositoryImpl implements PropertyRepository {
  final PropertyRemoteDataSource _remoteDataSource;
  final PropertyLocalDataSource _localDataSource;

  PropertyRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<Failure, List<PropertyEntity>>> getProperties() async {
    try {
      final properties = await _remoteDataSource.getProperties();
      await _localDataSource.saveAll(properties);
      return Right(properties.map((m) => m.toEntity()).toList());
    } on PostgrestException catch (e) {
      final cached = await _localDataSource.getAll();
      if (cached.isNotEmpty) {
        return Right(cached.map((m) => m.toEntity()).toList());
      }
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      final cached = await _localDataSource.getAll();
      if (cached.isNotEmpty) {
        return Right(cached.map((m) => m.toEntity()).toList());
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PropertyEntity>> getPropertyById(String id) async {
    try {
      final property = await _remoteDataSource.getPropertyById(id);
      return Right(property.toEntity());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PropertyEntity>> createProperty(
    CreatePropertyParams params,
  ) async {
    try {
      final property = await _remoteDataSource.createProperty(
        name: params.name,
        developer: params.developer,
        location: params.location,
        totalPrice: params.totalPrice,
        currency: params.currency,
        handoverDate: params.handoverDate,
        notes: params.notes,
      );
      return Right(property.toEntity());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PropertyEntity>> updateProperty(
    UpdatePropertyParams params,
  ) async {
    try {
      final property = await _remoteDataSource.updateProperty(
        id: params.id,
        name: params.name,
        developer: params.developer,
        location: params.location,
        totalPrice: params.totalPrice,
        currency: params.currency,
        handoverDate: params.handoverDate,
        notes: params.notes,
      );
      return Right(property.toEntity());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteProperty(String id) async {
    try {
      await _remoteDataSource.deleteProperty(id);
      return const Right(unit);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
