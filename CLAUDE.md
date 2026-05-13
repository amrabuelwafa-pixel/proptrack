# Property Installment Tracker — Claude Code Context

> **Read this file before touching any code.**
> It is the single source of truth for architecture decisions, conventions, and patterns used in this project.

---

## Project Summary

A cross-platform Flutter application (iOS, Android, Web) that helps a single real-estate investor manage long-term installment payment plans. Key capabilities: AI-assisted PDF/image/Excel extraction via Gemini, multi-currency display, receipt archiving, and branded PDF/Excel report export.

**Prototype:** Built on Lovable (React/PWA) at https://home-due-tracker.lovable.app  
**Backend:** Supabase (PostgreSQL + Storage + Edge Functions) — direct connection, not via Lovable  
**AI:** Google Gemini 2.5 Flash (multimodal) — called server-side via Supabase Edge Function only

---

## Architecture: Clean Architecture

```
Domain Layer     → Pure Dart. Zero Flutter/Supabase imports. Entities, Use Cases, Repository interfaces.
Data Layer       → Implements domain interfaces. Supabase, Dio, Hive, Gemini. DTOs ↔ Entities.
Presentation     → Flutter UI + Riverpod providers. Calls use cases. Never touches data sources directly.
Core             → Shared utilities: theme, router, constants, error types, formatters.
```

**Dependency Rule:** Domain ← Data ← Presentation. Never the reverse.

---

## Folder Structure

```
lib/
├── core/                        # Constants, errors, router, theme, utils, extensions
├── features/
│   ├── auth/                    # Google & Apple OAuth via Supabase
│   ├── properties/              # Property CRUD + progress ring
│   ├── installments/            # Installment lifecycle + auto-status
│   ├── ai_extraction/           # Gemini-powered document parsing
│   ├── receipts/                # Receipt upload + signed URL retrieval
│   ├── currency/                # FX rates + display conversion
│   ├── dashboard/               # Portfolio KPIs + upcoming window
│   ├── reports/                 # Filtered reports + PDF/Excel export
│   └── settings/                # User preferences
└── shared/                      # Shared widgets + session provider
```

Each feature has: `domain/` (entities, repository interface, use cases) + `data/` (datasources, models, repo impl) + `presentation/` (pages, widgets, providers).

---

## State Management: Riverpod 2.x

- Use `@riverpod` annotation with code generation (`build_runner`)
- Pages are `ConsumerWidget` or `ConsumerStatefulWidget`
- All async CRUD → `AsyncNotifier<T>`
- Auth state → `StreamProvider` from `supabase.auth.onAuthStateChange`
- Simple selection state (currency, upcoming window) → `StateProvider`
- **Never** put business logic inside a widget. Extract to a provider or use case.

### Standard Notifier Pattern
```dart
@riverpod
class PropertyNotifier extends _$PropertyNotifier {
  @override
  Future<List<PropertyEntity>> build() => _fetchAll();

  Future<void> create(CreatePropertyParams params) async {
    state = const AsyncLoading();
    final result = await ref.read(createPropertyUseCaseProvider).call(params);
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (_)        => state = AsyncData(await _fetchAll()),
    );
  }
}
```

---

## Error Handling

- All use cases return `Either<Failure, T>` from the `fpdart` package
- **Never** throw exceptions across layers — wrap in `Left(Failure)`
- Failures are a sealed class hierarchy in `core/errors/failures.dart`
- Widgets handle errors via `AsyncValue.when(error: (e, _) => ErrorView(e))`

```dart
// Failure hierarchy (core/errors/failures.dart)
sealed class Failure extends Equatable {
  const Failure(this.message);
  final String message;
}
class ServerFailure    extends Failure { ... }
class NetworkFailure   extends Failure { ... }
class StorageFailure   extends Failure { ... }
class ExtractionFailure extends Failure { ... }
```

---

## Naming Conventions

| Artefact | Convention | Example |
|---|---|---|
| Files | `snake_case` | `property_repository_impl.dart` |
| Classes | `PascalCase` | `PropertyRepositoryImpl` |
| Providers | `camelCase` + Provider | `propertyListProvider` |
| Notifiers | PascalCase + Notifier | `PropertyNotifier` |
| Use Cases | PascalCase verb-noun | `CreatePropertyUseCase` |
| Entities | PascalCase + Entity | `PropertyEntity` |
| Models (DTOs) | PascalCase + Model | `PropertyModel` |
| Repository interfaces | …+ Repository | `PropertyRepository` |
| Repository impls | …+ RepositoryImpl | `PropertyRepositoryImpl` |
| Remote data sources | …+ RemoteDataSource | `PropertyRemoteDataSource` |
| Local data sources | …+ LocalDataSource | `FxLocalDataSource` |
| Pages | …+ Page | `PropertiesListPage` |

---

## Database Schema (Supabase)

### Table: `properties`
| Column | Type | Notes |
|---|---|---|
| id | uuid PK | gen_random_uuid() |
| user_id | uuid | RLS: must equal auth.uid() |
| name | text | required |
| developer | text | nullable |
| location | text | nullable |
| total_price | numeric(15,2) | stored in EGP |
| notes | text | nullable |
| payment_plan_file | text | storage path |
| created_at | timestamptz | default now() |
| updated_at | timestamptz | trigger-managed |

### Table: `installments`
| Column | Type | Notes |
|---|---|---|
| id | uuid PK | |
| user_id | uuid | RLS: must equal auth.uid() |
| property_id | uuid FK | → properties.id |
| name | text | required |
| amount | numeric(12,2) | in EGP |
| due_date | date | required |
| payment_date | date | nullable — if set → status = paid |
| type | enum | monthly, quarterly, yearly, one_time, custom |
| status | enum | paid, pending, overdue — **auto-derived, never set manually** |
| receipt_file | text | storage path |

### Storage Buckets
- `payment-plans` — private — path: `{user_id}/{property_id}/{filename}`
- `receipts` — private — path: `{user_id}/{installment_id}/{filename}`
- All file access via signed URLs with TTL ≤ 5 minutes

---

## Security Rules (NEVER violate these)

1. **No secrets in client code.** Supabase URL + anon key only. Gemini key lives in Edge Function env.
2. **All tables have RLS.** Every query is scoped by `user_id = auth.uid()`.
3. **No public storage buckets.** Always retrieve files via signed URLs.
4. **Status is derived.** `installment.status` is never set manually — it is computed from `payment_date` and `due_date`.
5. **No raw SQL from the Flutter client.** Use Supabase SDK (PostgREST) only.
6. **No `print()` in production.** Use the `logger` package with release-mode suppression.

---

## Key Providers to Know

| Provider | Type | Purpose |
|---|---|---|
| `supabaseClientProvider` | `Provider` | Supabase singleton |
| `authStateProvider` | `StreamProvider` | Auth state stream (used by router guard) |
| `selectedCurrencyProvider` | `StateProvider<String>` | EGP, AED, USD, etc. |
| `fxRatesProvider` | `FutureProvider<Map<String,double>>` | Cached FX rates (Hive fallback) |
| `propertyListProvider` | `AsyncNotifierProvider` | All properties for current user |
| `installmentListProvider(propertyId)` | `AsyncNotifierProvider` | Installments for a property |
| `portfolioSummaryProvider` | `FutureProvider` | Dashboard KPIs |

---

## Navigation (go_router)

Routes are defined in `core/router/app_router.dart`. All routes except `/login` are guarded. The router reads `authStateProvider` and redirects unauthenticated users to `/login`.

```
/login              → LoginPage
/                   → DashboardPage
/properties         → PropertiesListPage
/properties/new     → AddPropertyPage
/properties/:id     → PropertyDetailPage
/properties/:id/edit         → EditPropertyPage
/properties/:id/extract      → ExtractionReviewPage
/reports            → ReportsPage
/settings           → SettingsPage
```

---

## AI Extraction (Gemini)

- **Client never calls Gemini directly.** File is uploaded to Supabase Storage, then the Edge Function `extract-installments` is called.
- Edge Function: `POST /functions/v1/extract-installments` with `multipart/form-data`
- Returns: `[ { name: string, amount: number, due_date: string, type: string } ]`
- User MUST review and confirm extracted rows before `BatchInsertInstallmentsUseCase` is called.

---

## Multi-Currency Rules

- All amounts stored in **EGP** in the database.
- FX rates fetched from Open Exchange Rates API, cached in Hive, refreshed every 6 hours.
- Conversion is **client-side only** — no DB values are modified.
- `formatCurrency(amountEGP, targetCurrency, rates)` lives in `core/utils/currency_formatter.dart`.
- Currency switching must not trigger any network requests — must re-render in < 100 ms.

---

## Testing Rules

- Unit test every use case, repository impl, and model.
- Widget test every page and shared widget.
- Mock repositories using `mocktail`.
- Test files mirror the source path with `_test.dart` suffix.
- Run tests: `flutter test --coverage`
- Minimum 80% coverage on domain and data layers.

---

## Code Generation

After adding or modifying Riverpod providers, models, or Retrofit clients, run:
```bash
dart run build_runner build --delete-conflicting-outputs
```

Generated files (`*.g.dart`, `*.freezed.dart`) are gitignored and must not be edited manually.

---

## Environment Setup

Copy `.env.example` to `.env` and fill in:
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SENTRY_DSN=your-sentry-dsn
FX_API_KEY=your-open-exchange-rates-key
```

Load in `main.dart` via `flutter_dotenv` before `Supabase.initialize()`.

### Web Development Server

**IMPORTANT:** This Flutter web app always runs on **port 3000**.

**Run command:**
```bash
flutter run -d chrome --web-port=3000
```

**Whenever referencing localhost URLs**, always use **`http://localhost:3000`** — never other ports (3001, 8080, etc.). This applies to:
- Supabase redirect URLs (Site URL and Redirect URLs in dashboard)
- OAuth callback URLs (Google Cloud Console, GitHub, etc.)
- Local development URLs in documentation
- Password reset redirect URLs
- Deep linking configuration

---

## Important Constraints (from SRS)

- Single admin per deployment — no multi-tenant flows, no sign-up screen.
- `installment.status` is derived, never user-editable.
- AI extraction requires explicit user confirmation before persistence.
- Mobile-first: all tap targets ≥ 44×44 px.
- Both light and dark themes must meet WCAG AA contrast.
- Arabic content must render RTL.
