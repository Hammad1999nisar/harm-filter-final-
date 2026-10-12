import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/prediction.dart';
import '../services/auth_service.dart';
import '../services/classify_service.dart';
import '../widgets/result_card.dart';

enum AnalysisMode { text, image }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AnalysisMode _mode = AnalysisMode.text;

  // Text mode
  final _controller = TextEditingController();

  // Image mode
  final _picker = ImagePicker();
  Uint8List? _imageBytes;
  String _imageName = 'image.jpg';

  bool _loading = false;
  String? _error;
  Prediction? _result;

  static const _examples = [
    'I love learning about machine learning',
    'That is so stupid and annoying',
    'They should all go back where they came from',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _resetResult() {
    setState(() {
      _error = null;
      _result = null;
    });
  }

  Future<void> _analyzeText() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final p = await ClassifyService.instance.classify(_controller.text);
      setState(() => _result = p);
    } on ClassifyException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 90);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = picked.name;
        _error = null;
        _result = null;
      });
    } catch (_) {
      setState(() => _error = 'Could not open the image picker.');
    }
  }

  Future<void> _analyzeImage() async {
    if (_imageBytes == null) {
      setState(() => _error = 'Please choose an image first.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final p =
          await ClassifyService.instance.classifyImage(_imageBytes!, _imageName);
      setState(() => _result = p);
    } on ClassifyException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmSignOut() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again to continue.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sign out')),
        ],
      ),
    );
    if (yes == true) await AuthService.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final email = AuthService.instance.currentUser?.email ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('HarmFilter'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: _confirmSignOut,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (email.isNotEmpty)
                    Text(
                      'Signed in as $email',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    'Analyze content',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Detect Hate Speech, Offensive Language, or Neither — from text or a meme image.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 18),
                  // Mode toggle
                  SegmentedButton<AnalysisMode>(
                    segments: const [
                      ButtonSegment(
                        value: AnalysisMode.text,
                        label: Text('Text'),
                        icon: Icon(Icons.text_fields_rounded),
                      ),
                      ButtonSegment(
                        value: AnalysisMode.image,
                        label: Text('Image'),
                        icon: Icon(Icons.image_outlined),
                      ),
                    ],
                    selected: {_mode},
                    onSelectionChanged: (s) {
                      setState(() => _mode = s.first);
                      _resetResult();
                    },
                  ),
                  const SizedBox(height: 18),
                  if (_mode == AnalysisMode.text)
                    _buildTextMode(context)
                  else
                    _buildImageMode(context),
                  const SizedBox(height: 20),
                  if (_error != null) _ErrorBox(_error!),
                  if (_result != null) ResultCard(prediction: _result!),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextMode(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          minLines: 4,
          maxLines: 8,
          textInputAction: TextInputAction.newline,
          decoration: const InputDecoration(
            hintText: 'Type or paste text here to check for hate speech…',
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final ex in _examples)
              ActionChip(
                label: Text(
                  ex.length > 28 ? '${ex.substring(0, 28)}…' : ex,
                  style: const TextStyle(fontSize: 12),
                ),
                onPressed:
                    _loading ? null : () => setState(() => _controller.text = ex),
              ),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _loading ? null : _analyzeText,
          icon: _loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.4, color: Colors.white),
                )
              : const Icon(Icons.search_rounded),
          label: Text(_loading ? 'Analyzing…' : 'Analyze Text'),
        ),
      ],
    );
  }

  Widget _buildImageMode(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: _loading ? null : () => _pickImage(ImageSource.gallery),
          child: Container(
            height: 220,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: scheme.outlineVariant,
                width: 1.4,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: _imageBytes == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined,
                          size: 44, color: scheme.primary),
                      const SizedBox(height: 10),
                      Text('Tap to choose a meme / image',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 2),
                      Text('The text will be read from the image and analyzed',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant)),
                    ],
                  )
                : Image.memory(_imageBytes!, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _loading ? null : () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Gallery'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _loading ? null : () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Camera'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: _loading ? null : _analyzeImage,
          icon: _loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.4, color: Colors.white),
                )
              : const Icon(Icons.search_rounded),
          label: Text(_loading ? 'Reading & analyzing…' : 'Analyze Image'),
        ),
      ],
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
