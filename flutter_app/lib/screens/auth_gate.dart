import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

/// Decides which screen to show based on the Supabase session, and rebuilds
/// automatically on sign-in / sign-out.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: AuthService.instance.onAuthStateChange,
      builder: (context, snapshot) {
        final signedIn = AuthService.instance.isSignedIn;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: signedIn ? const HomeScreen() : const LoginScreen(),
        );
      },
    );
  }
}
