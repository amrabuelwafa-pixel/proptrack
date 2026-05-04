import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proptrack/core/router/route_names.dart';
import 'package:proptrack/features/auth/presentation/pages/login_page.dart';
import 'package:proptrack/features/auth/presentation/pages/register_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final publicRoutes = {AppRoutes.login, AppRoutes.register, AppRoutes.forgotPassword};

  return GoRouter(
    redirect: (context, state) async {
      final currentUser = Supabase.instance.client.auth.currentUser;
      final isLoggedIn = currentUser != null;
      final isOnPublicRoute = publicRoutes.contains(state.uri.path);

      if (!isLoggedIn && !isOnPublicRoute) {
        return AppRoutes.login;
      }

      if (isLoggedIn && state.uri.path == AppRoutes.login) {
        return AppRoutes.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Forgot Password — Coming Soon')),
        ),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Dashboard — Coming in Sprint 2')),
        ),
      ),
    ],
  );
}
