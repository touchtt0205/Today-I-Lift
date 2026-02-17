import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final _client = Supabase.instance.client;

  Future<void> login(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> loginWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.flutter://login-callback',
      queryParams: {'prompt': 'select_account'},
    );
  }

  Future<void> signUp(String email, String password) async {
    await _client.auth.signUp(email: email, password: password);
  }
}
