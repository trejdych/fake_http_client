// ignore_for_file: avoid-dynamic

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
      status: switch (json['status']) {
        final int status => status,
        final String status => int.tryParse(status) ?? 0,
        _ => 0,
      },
      content: HarResponseContent.fromJson(
        json['content'] as Map<String, dynamic>? ?? const {},
      ),
      headers: headers ?? const [],
    );
  }

  final int status;
  final HarResponseContent content;
  final List<HarHeader> headers;
}
