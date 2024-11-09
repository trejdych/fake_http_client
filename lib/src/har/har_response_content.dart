part of 'har.dart';

class HarResponseContent {
  const HarResponseContent({
    required this.size,
    required this.mimeType,
    required this.text,
    this.encoding,
  });

  factory HarResponseContent.fromJson(Map<String, dynamic> json) {
    return HarResponseContent(
      size: json['size'] as int? ?? 0,
      mimeType: json['mimeType'] as String? ?? '',
      text: json['text'] as String? ?? '',
      encoding: json['encoding'] as String?,
    );
  }

  final int size;
  final String mimeType;
  final String text;
  final String? encoding;
}
