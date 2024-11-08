import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../fake_http_client.dart';
import 'fake_http_client.dart';
import 'fake_http_headers.dart';

/// A fake [HttpClientResponse] to return in a [RequestCallback].
///
/// A test response can be created with [FakeHttpResponse()]. This allows
/// you to specify the body, [statusCode], and [headers].
/// Other properties of a [HttpClientResponse] are faked are not currently
/// customizable:
///   * [contentLength] is calculated based on the provided body size.
///   * [redirects] and [cookies] are always the empty list.
///   * [reasonPhrase], [certificate], and [connectionInfo] are always `null`.
///   * [isRedirect] and [persistentConnection] are always false.
///
/// The methods [redirect] and [detachSocket] throw an [UnsupportedError] if
/// called.
///
/// See also:
///
///   * [FakeHttpClient]
///   * [HttpClient]
class FakeHttpResponse extends Stream<List<int>> implements HttpClientResponse {
  /// Creates a test response.
  ///
  /// The response [body] can be either a `String`, which will be utf8 encoded,
  /// or a `List<int>` - including `Uint8List` and other typed data objects.
  /// It defaults to the empty string, and will never be `null`;
  ///
  /// The [statusCode] defaults to [HttpStatus.Ok].
  ///
  /// [headers] are empty by default.  Multiple header values can be passed
  /// in a comma-separated string.
  factory FakeHttpResponse({
    dynamic body,
    int statusCode = HttpStatus.ok,
    Map<String, List<String>> headers = const {},
    HttpClientResponseCompressionState compressionState =
        HttpClientResponseCompressionState.notCompressed,
  }) {
    body ??= '';
    assert(
      body is String || body is List<int>,
      'body must be a String or List<int>',
    );
    List<int> codeUnits;
    if (body is String) {
      codeUnits = utf8.encode(body);
    } else {
      codeUnits = body as List<int>;
    }
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
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable(<List<int>>[_body]).listen(
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
