import '../repositories/auth_repository.dart';

class AuthService {
  final _repo = AuthRepository();

  Future<void> login(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      throw Exception('Email or password is empty');
    }

    await _repo.login(email.trim(), password);
  }

  Future<void> loginWithGoogle() {
    return _repo.loginWithGoogle();
  }

  Future<void> signUp(String email, String password) async {
    if (email.trim().isEmpty || password.length < 6) {
      throw Exception('Invalid email or password too short');
    }

    await _repo.signUp(email.trim(), password);
  }

  Future<void> deleteAccount() {
    return _repo.deleteAccount();
  }
}
