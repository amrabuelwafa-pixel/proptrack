import 'package:mocktail/mocktail.dart';
import 'package:proptrack/features/auth/domain/repositories/auth_repository.dart';
import 'package:proptrack/features/installments/domain/repositories/installment_repository.dart';
import 'package:proptrack/features/properties/domain/repositories/property_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockInstallmentRepository extends Mock implements InstallmentRepository {}

class MockPropertyRepository extends Mock implements PropertyRepository {}
