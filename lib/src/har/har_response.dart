part of 'har.dart';

class HarResponse {
  const HarResponse({
    required this.status,
    required this.content,
    required this.headers,
  });

  factory HarResponse.fromJson(Map<String, dynamic> json) {
    final headers = (json['headers'] as List<dynamic>?)
        ?.map((e) => HarHeader.fromJson(e as Map<String, dynamic>))
        .toList();

    return HarResponse(
      status: json['status'] as String? ?? '',
      content: HarResponseContent.fromJson(
        json['content'] as Map<String, dynamic>? ?? const {},
      ),
      headers: headers ?? const [],
    );
  }

  final String status;
  final HarResponseContent content;
  final List<HarHeader> headers;
}
