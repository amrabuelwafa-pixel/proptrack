import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:proptrack/core/router/app_router.dart';
import 'package:proptrack/core/theme/app_theme.dart';
import 'package:proptrack/core/theme/theme_notifier.dart';
import 'package:proptrack/features/properties/data/models/property_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web/web.dart' as web;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use path-style URLs on web (no `#`).
  if (kIsWeb) {
    usePathUrlStrategy();
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

  // Initialize Supabase with hardcoded credentials.
  // PKCE flow is required for the web OAuth callback (?code=...) to be
  // exchangeable via getSessionFromUrl.
  await Supabase.initialize(
    url: 'https://vpcpedlvmzyfjzrczqqn.supabase.co',
    anonKey: 'sb_publishable_RmSLqvapeYH8uoL3xjZcSA_lJxrOj4Y',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  // Handle the OAuth redirect: when the URL contains ?code=..., exchange the
  // code for a session and clean the URL before the router runs.
  if (kIsWeb) {
    final href = web.window.location.href;
    final uri = Uri.parse(href);
    if (uri.queryParameters.containsKey('code')) {
      try {
        await Supabase.instance.client.auth.getSessionFromUrl(uri);
        debugPrint('OAuth code exchange succeeded');
      } catch (e, st) {
        debugPrint('OAuth code exchange failed: $e\n$st');
      }
      // Always strip the query so the router boots on a clean `/` and a future
      // refresh doesn't re-exchange the (now-spent) code.
      web.window.history.replaceState(null, '', '/');
    }
  }

  runApp(
    const ProviderScope(
      child: PropTrackApp(),
    ),
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
