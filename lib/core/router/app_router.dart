import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:proptrack/core/router/route_names.dart';
import 'package:proptrack/features/auth/presentation/pages/auth_loading_page.dart';
import 'package:proptrack/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:proptrack/features/auth/presentation/pages/login_page.dart';
import 'package:proptrack/features/auth/presentation/pages/oauth_callback_page.dart';
import 'package:proptrack/features/auth/presentation/pages/register_page.dart';
import 'package:proptrack/features/auth/presentation/providers/auth_providers.dart';
import 'package:proptrack/features/properties/presentation/pages/add_property_page.dart';
import 'package:proptrack/features/properties/presentation/pages/edit_property_page.dart';
import 'package:proptrack/features/properties/presentation/pages/property_detail_page.dart';
import 'package:proptrack/features/shell/presentation/pages/app_shell.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final publicRoutes = {
    AppRoutes.login,
    AppRoutes.register,
    AppRoutes.forgotPassword,
    '/auth/callback',
    '/',
  };

  return GoRouter(
    redirect: (context, state) async {
      try {
        final uri = state.uri;

        // If there's an OAuth code in the URL, let Supabase process it
        if (uri.queryParameters.containsKey('code')) {
          debugPrint('OAuth code detected, allowing Supabase to process');
          return null;
        }

        // If there's an OAuth error, redirect to login
        if (uri.queryParameters.containsKey('error')) {
          debugPrint('OAuth error detected: ${uri.queryParameters['error']}');
          return '/login';
        }

        // Watch auth state - handles the race condition
        final authStateAsync = ref.watch(authStateProvider);

        // While auth state is loading, show loading screen
        if (authStateAsync.isLoading) {
          debugPrint('Auth state is loading, showing loading screen');
          return '/auth/loading';
        }

        // If there's an auth error, go to login
        if (authStateAsync.hasError) {
          debugPrint('Auth state error: ${authStateAsync.error}');
          return '/login';
        }

        // Get the current user from auth state
        final currentUser = Supabase.instance.client.auth.currentUser;
        final isLoggedIn = currentUser != null;
        final isOnPublicRoute = publicRoutes.contains(state.uri.path);

        // Not logged in and not on a public route → go to login
        if (!isLoggedIn && !isOnPublicRoute) {
          debugPrint('User not logged in, redirecting to login');
          return AppRoutes.login;
        }

        // Logged in and on login page → go to dashboard
        if (isLoggedIn && state.uri.path == AppRoutes.login) {
          debugPrint('User logged in, redirecting from login to dashboard');
          return AppRoutes.dashboard;
        }

        return null;
      } on Exception catch (e) {
        debugPrint('Router redirect error: $e');
        return AppRoutes.login;
      }
    },
    routes: [
      GoRoute(
        path: '/auth/loading',
        name: 'loading',
        builder: (context, state) => const AuthLoadingPage(),
      ),
      GoRoute(
        path: '/',
        name: 'root',
        builder: (context, state) => const OAuthCallbackPage(),
      ),
      GoRoute(
        path: '/auth/callback',
        name: 'callback',
        builder: (context, state) => const OAuthCallbackPage(),
      ),
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
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        redirect: (context, state) => AppRoutes.properties,
      ),
      GoRoute(
        path: AppRoutes.properties,
        name: 'properties',
        builder: (context, state) => const AppShell(),
        routes: [
          GoRoute(
            path: 'new',
            name: 'newProperty',
            builder: (context, state) => const AddPropertyPage(),
          ),
          GoRoute(
            path: ':id',
            name: 'propertyDetail',
            builder: (context, state) => PropertyDetailPage(
              propertyId: state.pathParameters['id']!,
            ),
            routes: [
              GoRoute(
                path: 'edit',
                name: 'editProperty',
                builder: (context, state) => EditPropertyPage(
                  propertyId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
