import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/app_config.dart';
import 'screens/auth_gate.dart';
import 'screens/setup_needed_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool supabaseReady = false;
  if (AppConfig.isSupabaseConfigured) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
    supabaseReady = true;
  }

  runApp(HarmFilterApp(supabaseReady: supabaseReady));
}

class HarmFilterApp extends StatelessWidget {
  final bool supabaseReady;
  const HarmFilterApp({super.key, required this.supabaseReady});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HarmFilter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: supabaseReady ? const AuthGate() : const SetupNeededScreen(),
    );
  }
}
