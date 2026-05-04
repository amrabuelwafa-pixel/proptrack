import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:proptrack/core/router/app_router.dart';
import 'package:proptrack/core/theme/app_theme.dart';
import 'package:proptrack/core/theme/theme_notifier.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  // Load environment variables first (before Sentry)
  await dotenv.load();

  // Wrap app with Sentry for error reporting
  await SentryFlutter.init(
    (options) {
      options.dsn = dotenv.env['SENTRY_DSN'] ?? '';
      options.tracesSampleRate = 1.0;
    },
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize Hive for local storage
      await Hive.initFlutter();
      await Hive.openBox<dynamic>('settings');

      // Initialise Supabase
      await Supabase.initialize(
        url: dotenv.env['SUPABASE_URL']!,
        anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
      );

      runApp(
        const ProviderScope(
          child: PropTrackApp(),
        ),
      );
    },
  );
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
