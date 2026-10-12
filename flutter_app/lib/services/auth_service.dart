import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper around Supabase auth so the UI never touches the SDK directly.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final SupabaseClient _client = Supabase.instance.client;

  /// Emits on every sign-in / sign-out so the app can react (see AuthGate).
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;
  bool get isSignedIn => currentSession != null;

  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  /// Returns true if a session was created immediately, false if the project
  /// requires email confirmation (user must click the link in their inbox).
  Future<bool> signUp({required String email, required String password}) async {
    final res = await _client.auth.signUp(email: email, password: password);
    return res.session != null;
  }

  Future<void> signOut() => _client.auth.signOut();
}
