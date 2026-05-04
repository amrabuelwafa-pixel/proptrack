import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRemoteDataSource {
  Future<User> signInWithGoogle();
  Future<User> signInWithApple();
  Future<void> signOut();
  Stream<AuthState> get authStateChanges;
  User? get currentUser;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _supabaseClient;

  AuthRemoteDataSourceImpl(this._supabaseClient);

  @override
  Future<User> signInWithGoogle() async {
    await _supabaseClient.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'com.example.proptrack://login-callback',
    );
    return _supabaseClient.auth.currentUser!;
  }

  @override
  Future<User> signInWithApple() async {
    await _supabaseClient.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'com.example.proptrack://login-callback',
    );
    return _supabaseClient.auth.currentUser!;
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
