import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../fake_http_client.dart';

class FakeHttpResponse extends Stream<List<int>> implements HttpClientResponse {
  /// Creates a test response.
  ///
  /// The response [body] can be either a `String`, which will be utf8 encoded,
  /// or a `List<int>` - including `Uint8List` and other typed data objects.
  /// It defaults to the empty string, and will never be `null`;
  ///
  /// The [statusCode] defaults to ['HttpStatus.Ok'].
  ///
  /// [headers] are empty by default.  Multiple header values can be passed
  /// in a comma-separated string.
  factory FakeHttpResponse({
    Object? body,
    int statusCode = HttpStatus.ok,
    Map<String, List<String>> headers = const {},
    HttpClientResponseCompressionState compressionState =
        HttpClientResponseCompressionState.notCompressed,
  }) {
    assert(
      body is String || body is List<int>,
      'body must be a String or List<int>',
    );
    final codeUnits = switch (body) {
      final String s => utf8.encode(s),
      final List<int> l => l,
      _ => <int>[],
    };

    final HttpHeaders testHeaders = FakeHttpHeaders(headers);

    return FakeHttpResponse._(
      codeUnits,
      statusCode,
      testHeaders,
      compressionState,
    );
  }

  FakeHttpResponse._(
    this._body,
    this._statusCode,
    this._headers,
    this._compressionState,
  );

  final List<int> _body;
  final int _statusCode;
  final HttpHeaders _headers;
  final HttpClientResponseCompressionState _compressionState;

  @override
  final List<RedirectInfo> redirects = <RedirectInfo>[];

  @override
  final List<Cookie> cookies = <Cookie>[];

  @override
  int get statusCode => _statusCode;

  @override
  X509Certificate? get certificate => null;

  @override
  HttpConnectionInfo? get connectionInfo => null;

  @override
  int get contentLength => _body.length;

  @override
  Future<Socket> detachSocket() {
    throw UnsupportedError('');
  }

  @override
  HttpHeaders get headers => _headers;

  @override
  bool get isRedirect => false;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    // ignore: prefer-explicit-function-type
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(_body).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  bool get persistentConnection => false;

  @override
  String get reasonPhrase => '';

  @override
  Future<HttpClientResponse> redirect([
    String? method,
    Uri? url,
    bool? followLoops,
  ]) {
    throw UnsupportedError('');
  }

  @override
  HttpClientResponseCompressionState get compressionState => _compressionState;
}
