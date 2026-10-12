# HarmFilter — Flutter App

A mobile/web front-end for the HarmFilter hate-speech detection system.
It provides **Supabase email/password authentication** and a **text-analysis**
screen that classifies input as **Hate Speech**, **Offensive Language**, or
**Neither** by calling the project's Flask model API (`api.py`).

Built with Flutter 3.29 · Material 3 · Supabase · Google Fonts.

---

## 1. Prerequisites

- Flutter SDK 3.29+ (`flutter --version`)
- A running instance of the model API (`api.py` in the repo root)
- A free Supabase project (https://supabase.com)

## 2. Configure

Open **`lib/config/app_config.dart`** and fill in:

```dart
static const String supabaseUrl = 'https://YOUR-PROJECT.supabase.co';
static const String supabaseAnonKey = 'YOUR-SUPABASE-ANON-KEY';
```
(Find both in your Supabase dashboard → Project Settings → API.)

Set the API URL for your setup:
- **Android emulator:** `http://10.0.2.2:5000` (the default — reaches your PC's localhost)
- **Real phone / web:** your PC's LAN IP (e.g. `http://192.168.1.8:5000`) or an ngrok URL
- Or override at run time: `--dart-define=API_BASE_URL=https://your-api.example.com`

## 3. Start the model API (in the repo root)

```bash
python api.py            # serves http://0.0.0.0:5000
```

## 4. Run the app

```bash
flutter pub get
flutter run              # pick a device/emulator, or `-d chrome` for web
```

> Note: authentication needs Supabase configured. Until you add the keys, the
> app shows a friendly setup screen instead of the login page.

---

## Project structure

```
lib/
├── main.dart                     # App entry, Supabase init, theming, auth gate
├── config/app_config.dart        # Supabase + API URL (EDIT THIS)
├── theme/app_theme.dart          # Colour palette + Material 3 themes
├── models/prediction.dart        # API response model
├── services/
│   ├── auth_service.dart         # Supabase auth wrapper
│   └── classify_service.dart     # Calls the Flask /predict API
├── screens/
│   ├── auth_gate.dart            # Login vs Home based on session
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── home_screen.dart          # Text input + analyze + results
│   └── setup_needed_screen.dart  # Shown until Supabase keys are added
└── widgets/
    ├── brand_header.dart
    └── result_card.dart          # Verdict + confidence + probability bars
```

## Design

- **Palette:** indigo/violet primary (`#5B4EE9`) with a teal accent (`#14B8A6`).
- **Semantic colours:** Hate = red, Offensive = amber, Neither = green.
- Light & dark themes follow the system setting.
