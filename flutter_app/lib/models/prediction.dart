/// Result of a hate-speech classification, mirroring the Flask API response:
/// {
///   "label": "...", "confidence": 87.4,
///   "probabilities": {"hate_speech": .., "offensive_language": .., "neither": ..}
/// }
class Prediction {
  final String label; // "Hate Speech" | "Offensive Language" | "Neither"
  final double confidence; // percent for `label`
  final double hateSpeech; // percent
  final double offensive; // percent
  final double neither; // percent
  final String? extractedText; // present for image results (OCR output)
  final String? note; // e.g. "No readable text was found in the image."

  const Prediction({
    required this.label,
    required this.confidence,
    required this.hateSpeech,
    required this.offensive,
    required this.neither,
    this.extractedText,
    this.note,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    final probs = (json['probabilities'] as Map?) ?? const {};
    double d(dynamic v) => (v is num) ? v.toDouble() : 0.0;
    return Prediction(
      label: (json['label'] ?? 'Neither').toString(),
      confidence: d(json['confidence']),
      hateSpeech: d(probs['hate_speech']),
      offensive: d(probs['offensive_language']),
      neither: d(probs['neither']),
      extractedText: json['extracted_text']?.toString(),
      note: json['note']?.toString(),
    );
  }
}
