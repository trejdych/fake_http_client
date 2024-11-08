part of 'har.dart';

class HarEntry {
  const HarEntry({
    required this.startedDateTime,
    required this.time,
    required this.request,
    required this.response,
  });

  factory HarEntry.fromJson(Map<String, dynamic> json) {
    return HarEntry(
      startedDateTime: DateTime.parse(json['startedDateTime'] as String),
      time: switch (json['time']) {
        final int time => time,
        final double time => time.toInt(),
        _ => 0,
      },
      request: HarRequest.fromJson(json['request'] as Map<String, dynamic>),
      response: HarResponse.fromJson(json['response'] as Map<String, dynamic>),
    );
  }

  final DateTime startedDateTime;
  final int time;
  final HarRequest request;
  final HarResponse response;
}
