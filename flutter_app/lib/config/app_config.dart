/// Central configuration for HarmFilter.
///
/// ┌─────────────────────────────────────────────────────────────────────┐
/// │  BEFORE RUNNING THE APP, fill in the three values below.             │
/// └─────────────────────────────────────────────────────────────────────┘
///
/// 1. Supabase — create a free project at https://supabase.com, then copy
///    Project URL and the `anon` public key from Project Settings → API.
///
/// 2. API base URL — where your Flask model API (api.py) is reachable.
///    - Local testing on an Android emulator: http://10.0.2.2:5000
///      (10.0.2.2 is how the emulator reaches your PC's localhost)
///    - Local testing on a real phone / web: use your machine's LAN IP
///      (e.g. http://192.168.1.8:5000) or an ngrok URL (https://xxxx.ngrok-free.app)
///
/// You can also override the API URL at build time:
///   flutter run --dart-define=API_BASE_URL=https://your-api.example.com
class AppConfig {
  AppConfig._();

  // ── Supabase ────────────────────────────────────────────────────────
  static const String supabaseUrl = 'https://reboawqkpdxocdgjwbpf.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJlYm9hd3FrcGR4b2NkZ2p3YnBmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA1NzIwMjQsImV4cCI6MjEwNjE0ODAyNH0.W2_oh9dz933dIqjHD2UWkJVXlg1JGS58sJr6xbM8xQs';

  // ── Model API (Flask api.py) ────────────────────────────────────────
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000',
  );

  /// True once real credentials have been filled in (used to show a friendly
  /// setup message instead of a crash when the placeholders are untouched).
  static bool get isSupabaseConfigured =>
      supabaseUrl.startsWith('https://') &&
      !supabaseUrl.contains('YOUR-PROJECT') &&
      supabaseAnonKey.isNotEmpty &&
      !supabaseAnonKey.contains('YOUR-SUPABASE');
}
