import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_header.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthService.instance.signIn(
        email: _email.text.trim(),
        password: _password.text,
      );
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  const BrandHeader(
                    subtitle:
                        'AI-powered detection of hate speech & offensive language',
                  ),
                  const SizedBox(height: 32),
                  _buildLoginForm(context),
                  const SizedBox(height: 36),
                  _sectionDivider(context, 'What you can do'),
                  const SizedBox(height: 18),
                  _buildFeatureCards(context),
                  const SizedBox(height: 28),
                  _sectionDivider(context, 'The three categories'),
                  const SizedBox(height: 18),
                  _buildCategories(context),
                  const SizedBox(height: 28),
                  _sectionDivider(context, 'How it works'),
                  const SizedBox(height: 18),
                  _buildSteps(context),
                  const SizedBox(height: 28),
                  Text(
                    'Sign in or create an account to get started.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Login form ────────────────────────────────────────────────────────
  Widget _buildLoginForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.mail_outline_rounded),
            ),
            validator: (v) =>
                (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _password,
            obscureText: _obscure,
            autofillHints: const [AutofillHints.password],
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(_obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (v) =>
                (v == null || v.length < 6) ? 'Min 6 characters' : null,
            onFieldSubmitted: (_) => _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            _ErrorBanner(_error!),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.4, color: Colors.white),
                  )
                : const Text('Sign In'),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account?",
                  style: Theme.of(context).textTheme.bodyMedium),
              TextButton(
                onPressed: _loading
                    ? null
                    : () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const SignupScreen()),
                        ),
                child: const Text('Sign up'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Info sections ─────────────────────────────────────────────────────
  Widget _sectionDivider(BuildContext context, String title) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Expanded(child: Divider(color: color.withValues(alpha: 0.25))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        Expanded(child: Divider(color: color.withValues(alpha: 0.25))),
      ],
    );
  }

  Widget _buildFeatureCards(BuildContext context) {
    return Column(
      children: [
        _FeatureCard(
          icon: Icons.text_fields_rounded,
          color: AppColors.primary,
          title: 'Text analysis',
          body: 'Type or paste any text and get an instant classification with '
              'confidence scores.',
        ),
        const SizedBox(height: 12),
        _FeatureCard(
          icon: Icons.image_outlined,
          color: AppColors.accent,
          title: 'Meme / image analysis',
          body: 'Upload a meme — the app reads the text from the image (OCR) and '
              'analyzes it automatically.',
        ),
        const SizedBox(height: 12),
        _FeatureCard(
          icon: Icons.insights_rounded,
          color: AppColors.offensive,
          title: 'Explainable results',
          body: 'See the full probability breakdown across all three categories, '
              'not just a single label.',
        ),
      ],
    );
  }

  Widget _buildCategories(BuildContext context) {
    return Column(
      children: [
        _CategoryRow(
          color: AppColors.hate,
          icon: Icons.dangerous_rounded,
          title: 'Hate Speech',
          body: 'Attacks or promotes violence against a group of people.',
        ),
        const SizedBox(height: 10),
        _CategoryRow(
          color: AppColors.offensive,
          icon: Icons.warning_amber_rounded,
          title: 'Offensive Language',
          body: 'Rude or abusive language that is not targeted hate.',
        ),
        const SizedBox(height: 10),
        _CategoryRow(
          color: AppColors.neither,
          icon: Icons.check_circle_rounded,
          title: 'Neither',
          body: 'Neutral content that is safe and non-offensive.',
        ),
      ],
    );
  }

  Widget _buildSteps(BuildContext context) {
    return Column(
      children: const [
        _StepRow(number: '1', text: 'Create an account or sign in.'),
        _StepRow(number: '2', text: 'Choose Text or Image mode.'),
        _StepRow(number: '3', text: 'Enter text or upload a meme.'),
        _StepRow(
            number: '4',
            text: 'Get the verdict with confidence and probabilities.'),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _FeatureCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(body, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String body;
  const _CategoryRow({
    required this.color,
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: color, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(body, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String number;
  final String text;
  const _StepRow({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
              ),
              shape: BoxShape.circle,
            ),
            child: Text(number,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.onErrorContainer, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
