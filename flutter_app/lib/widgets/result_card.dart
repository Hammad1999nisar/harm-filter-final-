import 'package:flutter/material.dart';

import '../models/prediction.dart';
import '../theme/app_theme.dart';

/// Shows the classification verdict, confidence, and a bar per class.
class ResultCard extends StatelessWidget {
  final Prediction prediction;
  const ResultCard({super.key, required this.prediction});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forLabel(prediction.label);
    final icon = switch (prediction.label) {
      'Hate Speech' => Icons.dangerous_rounded,
      'Offensive Language' => Icons.warning_amber_rounded,
      _ => Icons.check_circle_rounded,
    };

    final extracted = prediction.extractedText;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Extracted text (image results only)
            if (extracted != null && extracted.trim().isNotEmpty) ...[
              Text(
                'Extracted text',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('“$extracted”',
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
              const SizedBox(height: 18),
            ],
            // Verdict banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 30),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prediction.label,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color: color,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        Text(
                          'Confidence: ${prediction.confidence.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Probability breakdown',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            _Bar('Hate Speech', prediction.hateSpeech, AppColors.hate),
            const SizedBox(height: 12),
            _Bar('Offensive Language', prediction.offensive, AppColors.offensive),
            const SizedBox(height: 12),
            _Bar('Neither', prediction.neither, AppColors.neither),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final double percent; // 0-100
  final Color color;
  const _Bar(this.label, this.percent, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Text('${percent.toStringAsFixed(1)}%',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: (percent / 100).clamp(0, 1)),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 10,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
      ],
    );
  }
}
