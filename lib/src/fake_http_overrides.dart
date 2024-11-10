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

  final FakeHttpRequestMapper? onRequest;
  final ResponseManager _responseManager;

  static Future<FakeHttpOverrides> createFromFile(
    String path, {
    FakeHttpRequestMapper? onRequest,
  }) async {
    final file = File(path);

    return FakeHttpOverrides(
      harContent: jsonDecode(await file.readAsString()) as Map<String, dynamic>,
      onRequest: onRequest,
    );
  }

  final Map<String, dynamic> harContent;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return FakeHttpClient(
      onRequest: (uri, method) async {
        if (onRequest?.call(uri, method) case final request?) {
          return request;
        }

        return _responseManager.getRequest(method: method, uri: uri);
      },
    );
  }
}
