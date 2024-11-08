part of 'har.dart';

class HarResponseContent {
  const HarResponseContent({
    required this.size,
    required this.mimeType,
    required this.text,
  });

  factory HarResponseContent.fromJson(Map<String, dynamic> json) {
    return HarResponseContent(
      size: json['size'] as int? ?? 0,
      mimeType: json['mimeType'] as String? ?? '',
      text: json['text'] as String? ?? '',
    );
  }

  final int size;
  final String mimeType;
  final String text;
}
