import 'package:flutter/material.dart';

import '../widgets/brand_header.dart';

/// Shown when Supabase credentials in app_config.dart are still placeholders.
class SetupNeededScreen extends StatelessWidget {
  const SetupNeededScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const BrandHeader(subtitle: 'One quick setup step'),
                  const SizedBox(height: 28),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add your Supabase keys',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            '1. Create a free project at supabase.com\n'
                            '2. Open Project Settings → API\n'
                            '3. Paste the Project URL and anon public key into:\n'
                            '     lib/config/app_config.dart\n'
                            '4. Restart the app',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
