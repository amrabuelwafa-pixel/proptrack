import 'package:fpdart/fpdart.dart';
import 'package:proptrack/core/errors/failures.dart';
import 'package:proptrack/features/installments/data/datasources/installment_remote_datasource.dart';
import 'package:proptrack/features/installments/domain/entities/installment_entity.dart';
import 'package:proptrack/features/installments/domain/repositories/installment_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InstallmentRepositoryImpl implements InstallmentRepository {
  final InstallmentRemoteDataSource _dataSource;

  InstallmentRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<InstallmentEntity>>> getByPropertyId(String propertyId) async {
    try {
      final installments = await _dataSource.getByPropertyId(propertyId);
      return Right(installments.map((m) => m.toEntity()).toList());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, InstallmentEntity>> togglePaid(String id, bool isPaid) async {
    try {
      final installment = await _dataSource.togglePaid(id, isPaid);
      return Right(installment.toEntity());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
