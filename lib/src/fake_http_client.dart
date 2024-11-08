import 'dart:async';
import 'dart:io';

import '../fake_http_client.dart';
import 'response_manager.dart';

class FakeHttpClient implements HttpClient {
  FakeHttpClient({
    required this.onRequest,
    required this.responseManager,
  });

  final ResponseManager responseManager;

  final Future<HttpClientRequest?> Function(
    Uri uri,
    String method,
  ) onRequest;

  @override
  bool autoUncompress = true;

  @override
  Duration idleTimeout = const Duration(minutes: 5);

  @override
  int? maxConnectionsPerHost;

  @override
  String? userAgent;

  @override
  void addCredentials(
    Uri url,
    String realm,
    HttpClientCredentials credentials,
  ) {}

  @override
  void addProxyCredentials(
    String host,
    int port,
    String realm,
    HttpClientCredentials credentials,
  ) {}

  @override
  Future<bool> Function(Uri url, String scheme, String? realm)? authenticate;

  @override
  Future<bool> Function(
    String host,
    int port,
    String scheme,
    String? realm,
  )? authenticateProxy;

  @override
  String Function(Uri url)? findProxy;

  @override
  bool Function(X509Certificate cert, String host, int port)?
      badCertificateCallback;

  @override
  void close({bool force = false}) {}

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) {
    throw UnsupportedError('');
  }

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) => openUrl('DELETE', url);

  @override
  Future<HttpClientRequest> get(String host, int port, String path) {
    throw UnsupportedError('');
  }

  @override
  Future<HttpClientRequest> getUrl(Uri url) => openUrl('GET', url);

  @override
  Future<HttpClientRequest> head(String host, int port, String path) {
    throw UnsupportedError('');
  }

  @override
  Future<HttpClientRequest> headUrl(Uri url) => openUrl('HEAD', url);

  @override
  Future<HttpClientRequest> open(
    String method,
    String host,
    int port,
    String path,
  ) {
    throw UnsupportedError('');
  }

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    final request = await onRequest(url, method);

    if (request != null) {
      return request;
    }

    return FakeHttpRequest(
      method: method,
      uri: url,
      manager: responseManager,
    );
  }

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) {
    throw UnsupportedError('');
  }

  @override
  Future<HttpClientRequest> patchUrl(Uri url) => openUrl('PATCH', url);

  @override
  Future<HttpClientRequest> post(String host, int port, String path) {
    throw UnsupportedError('');
  }

  @override
  Future<HttpClientRequest> postUrl(Uri url) => openUrl('POST', url);

  @override
  Future<HttpClientRequest> put(String host, int port, String path) {
    throw UnsupportedError('');
  }

  @override
  Future<HttpClientRequest> putUrl(Uri url) => openUrl('PUT', url);

  @override
  Duration? connectionTimeout;

  @override
  // ignore: avoid_setters_without_getters
  set connectionFactory(
    Future<ConnectionTask<Socket>> Function(
      Uri url,
      String? proxyHost,
      int? proxyPort,
    )? f,
  ) {}

  @override
  // ignore: avoid_setters_without_getters
  set keyLog(void Function(String line)? callback) {}
}
