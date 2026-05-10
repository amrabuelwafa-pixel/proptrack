import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proptrack/core/router/route_names.dart';
import 'package:proptrack/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:proptrack/features/auth/presentation/pages/login_page.dart';
import 'package:proptrack/features/auth/presentation/pages/oauth_callback_page.dart';
import 'package:proptrack/features/auth/presentation/pages/register_page.dart';
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
  };

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
