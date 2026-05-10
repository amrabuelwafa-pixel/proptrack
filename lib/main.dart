import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:proptrack/core/router/app_router.dart';
import 'package:proptrack/core/theme/app_theme.dart';
import 'package:proptrack/core/theme/theme_notifier.dart';
import 'package:proptrack/features/properties/data/models/property_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  try {
    // Initialize Flutter bindings
    WidgetsFlutterBinding.ensureInitialized();

    // Load environment variables (may fail on web)
    try {
      await dotenv.load();
    } on Exception catch (e) {
      debugPrint('Warning: Could not load .env file: $e');
    }

    // Initialize Hive for local storage (skip on web)
    try {
      await Hive.initFlutter();
      Hive.registerAdapter(PropertyModelAdapter());
      await Hive.openBox<dynamic>('settings');
      await Hive.openBox<dynamic>('properties');
    } on Exception catch (e) {
      debugPrint('Warning: Could not initialize Hive: $e');
    }

    // Get Supabase credentials from .env or environment
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ??
        const String.fromEnvironment('SUPABASE_URL');
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ??
        const String.fromEnvironment('SUPABASE_ANON_KEY');

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception('Missing Supabase credentials. Check .env file or environment variables.');
    }

    // Initialize Supabase
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    runApp(
      const ProviderScope(
        child: PropTrackApp(),
      ),
    );
  } catch (e, stackTrace) {
    // Log error for debugging
    debugPrint('Fatal error during app initialization: $e');
    debugPrint('StackTrace: $stackTrace');
    rethrow;
  }
}

class PropTrackApp extends ConsumerWidget {
  const PropTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Property Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
