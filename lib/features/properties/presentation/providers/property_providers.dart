import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:proptrack/core/providers/supabase_provider.dart';
import 'package:proptrack/features/properties/data/datasources/property_local_datasource.dart';
import 'package:proptrack/features/properties/data/datasources/property_remote_datasource.dart';
import 'package:proptrack/features/properties/data/repositories/property_repository_impl.dart';
import 'package:proptrack/features/properties/domain/entities/property_entity.dart';
import 'package:proptrack/features/properties/domain/repositories/property_repository.dart';
import 'package:proptrack/features/properties/domain/usecases/create_property_usecase.dart';
import 'package:proptrack/features/properties/domain/usecases/delete_property_usecase.dart';
import 'package:proptrack/features/properties/domain/usecases/get_properties_usecase.dart';
import 'package:proptrack/features/properties/domain/usecases/get_property_by_id_usecase.dart';
import 'package:proptrack/features/properties/domain/usecases/update_property_usecase.dart';

final propertyRemoteDataSourceProvider =
    Provider<PropertyRemoteDataSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return PropertyRemoteDataSourceImpl(client);
});

final propertyLocalDataSourceProvider =
    Provider<PropertyLocalDataSource>((ref) {
  final box = Hive.box<dynamic>('properties');
  return PropertyLocalDataSourceImpl(box);
});

final propertyRepositoryProvider = Provider<PropertyRepository>((ref) {
  final remoteDataSource = ref.watch(propertyRemoteDataSourceProvider);
  final localDataSource = ref.watch(propertyLocalDataSourceProvider);
  return PropertyRepositoryImpl(remoteDataSource, localDataSource);
});

final getPropertiesUseCaseProvider = Provider<GetPropertiesUseCase>((ref) {
  final repository = ref.watch(propertyRepositoryProvider);
  return GetPropertiesUseCase(repository);
});

final getPropertyByIdUseCaseProvider = Provider<GetPropertyByIdUseCase>((ref) {
  final repository = ref.watch(propertyRepositoryProvider);
  return GetPropertyByIdUseCase(repository);
});

final createPropertyUseCaseProvider = Provider<CreatePropertyUseCase>((ref) {
  final repository = ref.watch(propertyRepositoryProvider);
  return CreatePropertyUseCase(repository);
});

final updatePropertyUseCaseProvider = Provider<UpdatePropertyUseCase>((ref) {
  final repository = ref.watch(propertyRepositoryProvider);
  return UpdatePropertyUseCase(repository);
});

final deletePropertyUseCaseProvider = Provider<DeletePropertyUseCase>((ref) {
  final repository = ref.watch(propertyRepositoryProvider);
  return DeletePropertyUseCase(repository);
});

class _PropertyNotifier
    extends StateNotifier<AsyncValue<List<PropertyEntity>>> {
  _PropertyNotifier(this._ref) : super(const AsyncLoading()) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    try {
      state = const AsyncLoading();
      final useCase = _ref.read(getPropertiesUseCaseProvider);
      final result = await useCase();
      state = result.fold(
        (failure) =>
            AsyncError<List<PropertyEntity>>(failure, StackTrace.current),
        (properties) => AsyncData(properties),
      );
    } on Exception catch (e, st) {
      state = AsyncError<List<PropertyEntity>>(e, st);
    }
  }

  Future<bool> create(CreatePropertyParams params) async {
    try {
      final useCase = _ref.read(createPropertyUseCaseProvider);
      final result = await useCase(params);
      return result.fold(
        (failure) {
          state = AsyncError<List<PropertyEntity>>(failure, StackTrace.current);
          return false;
        },
        (_) {
          _load();
          return true;
        },
      );
    } on Exception {
      return false;
    }
  }

  Future<bool> update(UpdatePropertyParams params) async {
    try {
      final useCase = _ref.read(updatePropertyUseCaseProvider);
      final result = await useCase(params);
      return result.fold(
        (failure) {
          state = AsyncError<List<PropertyEntity>>(failure, StackTrace.current);
          return false;
        },
        (_) {
          _load();
          return true;
        },
      );
    } on Exception {
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      final useCase = _ref.read(deletePropertyUseCaseProvider);
      final result = await useCase(id);
      return result.fold(
        (failure) {
          state = AsyncError<List<PropertyEntity>>(failure, StackTrace.current);
          return false;
        },
        (_) {
          _load();
          return true;
        },
      );
    } on Exception {
      return false;
    }
  }
}

final propertyNotifierProvider =
    StateNotifierProvider<_PropertyNotifier, AsyncValue<List<PropertyEntity>>>(
  (ref) => _PropertyNotifier(ref),
);

final selectedPropertyProvider = Provider.family<PropertyEntity?, String>(
  (ref, id) {
    final properties = ref.watch(propertyNotifierProvider);
    return properties.whenData((list) {
      try {
        return list.firstWhere((p) => p.id == id);
      } catch (e) {
        return null;
      }
    }).value;
  },
);
