import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:proptrack/core/router/app_router.dart';
import 'package:proptrack/core/theme/app_theme.dart';
import 'package:proptrack/core/theme/theme_notifier.dart';
import 'package:proptrack/features/properties/data/models/property_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage (skip on web)
  try {
    await Hive.initFlutter();
    Hive.registerAdapter(PropertyModelAdapter());
    await Hive.openBox<dynamic>('settings');
    await Hive.openBox<dynamic>('properties');
  } on Exception catch (e) {
    debugPrint('Warning: Could not initialize Hive: $e');
  }

  // Initialize Supabase with hardcoded credentials
  await Supabase.initialize(
    url: 'https://vpcpedlvmzyfjzrczqqn.supabase.co',
    anonKey: 'sb_publishable_RmSLqvapeYH8uoL3xjZcSA_lJxrOj4Y',
  );

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
