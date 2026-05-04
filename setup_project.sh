#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# Property Installment Tracker — Flutter Project Bootstrap Script
#
# Usage:
#   1. Run: flutter create --org com.yourname --project-name proptrack proptrack
#   2. Copy all scaffold files into the proptrack/ folder
#   3. Run this script from inside the proptrack/ folder: bash setup_project.sh
# ─────────────────────────────────────────────────────────────────────────────

set -e
echo "🚀 Setting up Property Installment Tracker project structure..."

# ── Lib structure ─────────────────────────────────────────────────────────────

mkdir -p lib/core/constants
mkdir -p lib/core/errors
mkdir -p lib/core/network
mkdir -p lib/core/router
mkdir -p lib/core/theme
mkdir -p lib/core/utils
mkdir -p lib/core/extensions

# Features
for feature in auth properties installments ai_extraction receipts currency dashboard reports settings; do
  mkdir -p lib/features/$feature/domain/entities
  mkdir -p lib/features/$feature/domain/repositories
  mkdir -p lib/features/$feature/domain/usecases
  mkdir -p lib/features/$feature/data/datasources
  mkdir -p lib/features/$feature/data/models
  mkdir -p lib/features/$feature/data/repositories
  mkdir -p lib/features/$feature/presentation/pages
  mkdir -p lib/features/$feature/presentation/widgets
  mkdir -p lib/features/$feature/presentation/providers
done

mkdir -p lib/shared/widgets
mkdir -p lib/shared/providers

# ── Assets ────────────────────────────────────────────────────────────────────
mkdir -p assets/images
mkdir -p assets/icons
mkdir -p assets/fonts

# ── Tests ─────────────────────────────────────────────────────────────────────
for feature in auth properties installments ai_extraction receipts currency dashboard reports settings; do
  mkdir -p test/features/$feature/domain/usecases
  mkdir -p test/features/$feature/data/repositories
  mkdir -p test/features/$feature/presentation/providers
done
mkdir -p test/helpers
mkdir -p integration_test

# ── Supabase migrations ───────────────────────────────────────────────────────
mkdir -p supabase/migrations
mkdir -p supabase/functions/extract-installments
mkdir -p supabase/functions/send-reminder-email

# ── GitHub Actions CI ─────────────────────────────────────────────────────────
mkdir -p .github/workflows

# ── Create placeholder stub files ─────────────────────────────────────────────

# Core stubs
cat > lib/core/errors/failures.dart << 'EOF'
import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure(this.message);
  final String message;
  @override
  List<Object> get props => [message];
}

class ServerFailure     extends Failure { const ServerFailure(super.message); }
class NetworkFailure    extends Failure { const NetworkFailure(super.message); }
class StorageFailure    extends Failure { const StorageFailure(super.message); }
class ExtractionFailure extends Failure { const ExtractionFailure(super.message); }
class CacheFailure      extends Failure { const CacheFailure(super.message); }
class AuthFailure       extends Failure { const AuthFailure(super.message); }
EOF

cat > lib/core/errors/exceptions.dart << 'EOF'
class ServerException     implements Exception { const ServerException(this.message); final String message; }
class NetworkException    implements Exception { const NetworkException(this.message); final String message; }
class StorageException    implements Exception { const StorageException(this.message); final String message; }
class ExtractionException implements Exception { const ExtractionException(this.message); final String message; }
class CacheException      implements Exception { const CacheException(this.message); final String message; }
class AuthException       implements Exception { const AuthException(this.message); final String message; }
EOF

cat > lib/core/constants/supabase_constants.dart << 'EOF'
abstract final class SupabaseConstants {
  static const String propertiesTable   = 'properties';
  static const String installmentsTable = 'installments';
  static const String receiptsBucket    = 'receipts';
  static const String paymentPlansBucket = 'payment-plans';
  static const String extractFunctionUrl = 'extract-installments';
  static const int    signedUrlTtlSeconds = 300; // 5 minutes
}
EOF

cat > lib/core/constants/currency_constants.dart << 'EOF'
abstract final class CurrencyConstants {
  static const String baseCurrency = 'EGP';
  static const List<String> supportedCurrencies = [
    'EGP', 'AED', 'USD', 'EUR', 'TRY', 'SAR', 'GBP',
  ];
  static const int fxCacheDurationHours = 6;
}
EOF

cat > lib/core/router/route_names.dart << 'EOF'
abstract final class AppRoutes {
  static const String login             = '/login';
  static const String dashboard         = '/';
  static const String properties        = '/properties';
  static const String newProperty       = '/properties/new';
  static const String propertyDetail    = '/properties/:id';
  static const String editProperty      = '/properties/:id/edit';
  static const String extractionReview  = '/properties/:id/extract';
  static const String reports           = '/reports';
  static const String settings          = '/settings';
}
EOF

cat > lib/core/utils/currency_formatter.dart << 'EOF'
import 'package:intl/intl.dart';

/// Converts [amountEGP] to [targetCurrency] using [rates] (base: EGP)
/// and returns a locale-aware formatted string with tabular numbers.
String formatCurrency(
  double amountEGP,
  String targetCurrency,
  Map<String, double> rates,
) {
  final rate = rates[targetCurrency] ?? 1.0;
  final converted = amountEGP * rate;
  final formatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: _symbol(targetCurrency),
    decimalDigits: 2,
  );
  return formatter.format(converted);
}

String _symbol(String currency) => switch (currency) {
  'EGP' => 'E£ ',
  'AED' => 'AED ',
  'USD' => '\$ ',
  'EUR' => '€ ',
  'TRY' => '₺ ',
  'SAR' => 'SAR ',
  'GBP' => '£ ',
  _     => '$currency ',
};
EOF

# Test helpers
cat > test/helpers/mock_repositories.dart << 'EOF'
import 'package:mocktail/mocktail.dart';
import 'package:proptrack/features/auth/domain/repositories/auth_repository.dart';
import 'package:proptrack/features/properties/domain/repositories/property_repository.dart';
import 'package:proptrack/features/installments/domain/repositories/installment_repository.dart';

class MockAuthRepository       extends Mock implements AuthRepository {}
class MockPropertyRepository   extends Mock implements PropertyRepository {}
class MockInstallmentRepository extends Mock implements InstallmentRepository {}
EOF

# GitHub Actions CI workflow
cat > .github/workflows/ci.yml << 'EOF'
name: CI

on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main]

jobs:
  lint-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.x'
          channel: stable
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Run code generation
        run: dart run build_runner build --delete-conflicting-outputs

      - name: Analyse
        run: flutter analyze

      - name: Check formatting
        run: dart format --output=none --set-exit-if-changed lib/ test/

      - name: Run tests
        run: flutter test --coverage

      - name: Build web (smoke test)
        run: flutter build web --release
EOF

# .gitignore additions
cat >> .gitignore << 'EOF'

# Environment
.env

# Generated files
*.g.dart
*.freezed.dart
*.gen.dart

# Coverage
coverage/
EOF

echo ""
echo "✅ Project structure created successfully!"
echo ""
echo "Next steps:"
echo "  1. Copy pubspec.yaml, analysis_options.yaml, CLAUDE.md, .env.example into this folder"
echo "  2. Copy .env.example to .env and fill in your Supabase credentials"
echo "  3. Run: flutter pub get"
echo "  4. Run: dart run build_runner build --delete-conflicting-outputs"
echo "  5. Run: flutter analyze   (should pass with zero errors)"
echo "  6. Commit: git add . && git commit -m 'chore: Sprint 0 — project scaffold'"
echo ""
echo "📖 Read CLAUDE.md before writing any code — it contains all architecture rules."
