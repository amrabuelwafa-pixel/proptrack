import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OAuthCallbackPage extends StatefulWidget {
  const OAuthCallbackPage({super.key});

  @override
  State<OAuthCallbackPage> createState() => _OAuthCallbackPageState();
}

class _OAuthCallbackPageState extends State<OAuthCallbackPage> {
  @override
  void initState() {
    super.initState();
    _handleOAuthCallback();
  }

  Future<void> _handleOAuthCallback() async {
    try {
      // Get the current URL with the OAuth code
      final uri = Uri.parse(Uri.base.toString());

      // Exchange the authorization code for a session
      await Supabase.instance.client.auth.getSessionFromUrl(uri);

      // Check if session was successfully established
      final session = Supabase.instance.client.auth.currentSession;

      if (!mounted) return;

      if (session != null && session.user != null) {
        // Session established successfully, navigate to main app
        context.go('/properties');
      } else {
        // Session not established
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication failed: Unable to establish session'),
            backgroundColor: Colors.red,
          ),
        );
        // Redirect to login after a short delay
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) context.go('/login');
      }
    } on AuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign in error: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) context.go('/login');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error: $e'),
          backgroundColor: Colors.red,
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text(
            'Signing in...',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text(
            'Completing your authentication',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    ),
  );
}
