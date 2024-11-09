// ignore_for_file: avoid-dynamic

part of 'har.dart';

class HarRequest {
  const HarRequest({
    required this.method,
    required this.url,
    this.httpVersion,
    this.queryString,
    this.headers,
  });

  factory HarRequest.fromJson(Map<String, dynamic> json) {
    final headers = (json['headers'] as List<dynamic>?)
        ?.map((dynamic e) => HarHeader.fromJson(e as Map<String, dynamic>))
        .toList();

    return HarRequest(
      method: json['method'] as String? ?? '',
      url: json['url'] as String? ?? '',
      httpVersion: json['httpVersion'] as String?,
      queryString: (json['queryString'] as List<dynamic>?)
          ?.map((dynamic e) => HarHeader.fromJson(e as Map<String, dynamic>))
          .toList(),
      headers: headers,
    );
  }

  final String method;
  final String url;
  final String? httpVersion;
  final List<HarHeader>? queryString;
  final List<HarHeader>? headers;
}
