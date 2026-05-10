import 'package:supabase_flutter/supabase_flutter.dart';


abstract interface class AuthRemoteDataSource {
  Future<User> signInWithGoogle();
  Future<User> signInWithApple();
  Future<User> signInWithEmail(String email, String password);
  Future<User> signUpWithEmail(String email, String password);
  Future<void> resetPasswordForEmail(String email);
  Future<void> signOut();
  Stream<AuthState> get authStateChanges;
  User? get currentUser;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _supabaseClient;

  AuthRemoteDataSourceImpl(this._supabaseClient);

  @override
  Future<User> signInWithGoogle() async {
    final redirectUrl = _getRedirectUrl();
    await _supabaseClient.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirectUrl,
    );
    return _supabaseClient.auth.currentUser!;
  }

  @override
  Future<User> signInWithApple() async {
    final redirectUrl = _getRedirectUrl();
    await _supabaseClient.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: redirectUrl,
    );
    return _supabaseClient.auth.currentUser!;
  }

  String _getRedirectUrl() {
    const isWeb = bool.fromEnvironment('dart.library.html');
    if (isWeb) {
      return '${Uri.base.origin}/auth/callback';
    }
    return 'com.example.proptrack://login-callback';
  }

  String _getResetRedirectUrl() {
    const isWeb = bool.fromEnvironment('dart.library.html');
    if (isWeb) {
      return '${Uri.base.origin}/auth/callback';
    }
    return 'com.example.proptrack://login-callback';
  }

  @override
  Future<User> signInWithEmail(String email, String password) async {
    await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return _supabaseClient.auth.currentUser!;
  }

  @override
  Future<User> signUpWithEmail(String email, String password) async {
    final response = await _supabaseClient.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: _getResetRedirectUrl(),
    );
    return response.user!;
  }

  @override
  Future<void> resetPasswordForEmail(String email) async {
    await _supabaseClient.auth.resetPasswordForEmail(
      email,
      redirectTo: _getResetRedirectUrl(),
    );
  }

  @override
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  @override
  Stream<AuthState> get authStateChanges =>
      _supabaseClient.auth.onAuthStateChange;

  @override
  User? get currentUser => _supabaseClient.auth.currentUser;
}
