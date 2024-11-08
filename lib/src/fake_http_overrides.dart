import 'dart:convert';
import 'dart:io';

import '../fake_http_client.dart';
import 'response_manager.dart';

typedef FakeHttpRequestMapper = HttpClientRequest? Function(
  Uri uri,
  String method,
);

class FakeHttpOverrides extends HttpOverrides {
  FakeHttpOverrides({
    required this.harContent,
    this.onRequest,
  }) : _responseManager =
            ResponseManager(harRoot: HarRoot.fromJson(harContent));

  FakeHttpOverrides.onRequest(this.onRequest)
      : harContent = {},
        _responseManager =
            ResponseManager(harRoot: const HarRoot(log: HarLog(entries: [])));

  final FakeHttpRequestMapper? onRequest;
  final ResponseManager _responseManager;

  static Future<FakeHttpOverrides> createFromFile(
    File file, {
    FakeHttpRequestMapper? onRequest,
  }) async {
    if (!const bool.fromEnvironment('dart.vm.product')) {
      final client = FakeHttpOverrides(
        harContent: jsonDecode(file.readAsStringSync()) as Map<String, dynamic>,
        onRequest: onRequest,
      );

      return client;
    }
    throw UnsupportedError(
      'FakeHttpOverrides.createFromFile is not supported in release mode',
    );
  }

  final Map<String, dynamic> harContent;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return FakeHttpClient(
      responseManager: _responseManager,
      onRequest: (uri, method) async {
        if (onRequest?.call(uri, method) case final request?) {
          return request;
        }

        return null;
      },
    );
  }
}
