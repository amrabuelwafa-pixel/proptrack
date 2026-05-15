import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:proptrack/features/auth/presentation/pages/login_page.dart';
import 'package:proptrack/features/auth/presentation/pages/register_page.dart';
import 'package:proptrack/features/properties/presentation/pages/properties_page.dart';
import 'package:proptrack/features/properties/presentation/pages/property_detail_page.dart';
import 'package:proptrack/features/shell/presentation/pages/app_shell.dart';

part 'app_router.g.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

@riverpod
GoRouter appRouter(AppRouterRef ref) => GoRouter(
      initialLocation: '/login',
      refreshListenable: GoRouterRefreshStream(
        Supabase.instance.client.auth.onAuthStateChange,
      ),
      redirect: (context, state) {
        final session = Supabase.instance.client.auth.currentSession;
        final isLogin = state.matchedLocation == '/login';
        final isRegister = state.matchedLocation == '/register';

        if (session == null && !isLogin && !isRegister) {
          return '/login';
        }

        if (session != null && isLogin) {
          return '/';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const AppShell(),
        ),
        GoRoute(
          path: '/properties',
          builder: (context, state) => const PropertiesPage(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return PropertyDetailPage(propertyId: id);
              },
            ),
          ],
        ),
      ],
    );
