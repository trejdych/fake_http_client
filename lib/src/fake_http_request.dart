import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../fake_http_client.dart';
import 'response_manager.dart';

/// A fake implementation of [HttpClientRequest].
///
/// It is not necessary to use this class directly. Instead, code should be
/// written as if it is dealing with a regular [HttpHeaders].
///
/// See also:
///
///   * [HttpClientRequest]

/// HTTP request for a client connection.
///
/// To set up a request, set the headers using the headers property
/// provided in this class and write the data to the body of the request.
/// `HttpClientRequest` is an [IOSink]. Use the methods from IOSink,
/// such as `writeCharCode()`, to write the body of the HTTP
/// request. When one of the IOSink methods is used for the first
/// time, the request header is sent. Calling any methods that
/// change the header after it is sent throws an exception.
///
/// When writing string data through the [IOSink] the
/// encoding used is determined from the "charset" parameter of
/// the "Content-Type" header.
///
/// ```dart import:convert
/// var client = HttpClient();
/// HttpClientRequest request = await client.get('localhost', 80, '/file.txt');
/// request.headers.contentType =
///     ContentType('application', 'json', charset: 'utf-8');
/// request.write('text content👍🎯'); // Strings written will be UTF-8 encoded.
/// ```
///
/// If no charset is provided the default of ISO-8859-1 (Latin 1) is used.
///
/// ```dart
/// var client = HttpClient();
/// HttpClientRequest request = await client.get('localhost', 80, '/file.txt');
/// request.headers.add(HttpHeaders.contentTypeHeader, "text/plain");
/// request.write('blåbærgrød'); // Strings written will be ISO-8859-1 encoded
/// ```
///
/// An exception is thrown if you use an unsupported encoding and the
/// `write()` method being used takes a string parameter.
class FakeHttpRequest implements HttpClientRequest {
  FakeHttpRequest({
    required this.method,
    required this.uri,
    this.manager,
    this.harResponse,
    this.contentLength = -1,
    this.delay,
    this.cookies = const [],
    this.connectionInfo,
  });

  factory FakeHttpRequest.imagePng({required Uri uri, String method = 'GET'}) =>
      FakeHttpRequest(
        method: method,
        uri: uri,
        contentLength: 8,
        harResponse: const HarResponse(
          status: 200,
          headers: [
            HarHeader(name: 'Content-Type', value: 'image/png'),
          ],
          content: HarResponseContent(
            mimeType: 'image/png',
            size: 8,
            text:
                'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/wcAAwAB/6Wk8QAAAABJRU5ErkJggg==', // Base64 encoded 1x1 PNG image
            encoding: 'base64',
          ),
        ),
      );

  factory FakeHttpRequest.json({
    required Uri uri,
    required Map<String, dynamic> body,
    String method = 'GET',
    int statusCode = 200,
  }) {
    final encodedBody = json.encode(body);

    return FakeHttpRequest(
      method: method,
      uri: uri,
      contentLength: utf8.encode(encodedBody).length,
      harResponse: HarResponse(
        status: statusCode,
        headers: [
          const HarHeader(name: 'Content-Type', value: 'application/json'),
        ],
        content: HarResponseContent(
          mimeType: 'application/json',
          size: utf8.encode(encodedBody).length,
          text: encodedBody,
        ),
      ),
    );
  }

  final ResponseManager? manager;
  final HarResponse? harResponse;
  final Duration? delay;

  Completer<List<int>>? _bytesCompleter;
  final _completer = Completer<HttpClientResponse>();

  /// The requested persistent connection state.
  ///
  /// The default value is `true`.
  @override
  bool persistentConnection = true;

  /// Whether to follow redirects automatically.
  ///
  /// Set this property to `false` if this request should not
  /// automatically follow redirects. The default is `true`.
  ///
  /// Automatic redirect will only happen for "GET" and "HEAD" requests
  /// and only for the status codes [HttpStatus.movedPermanently]
  /// (301), [HttpStatus.found] (302),
  /// [HttpStatus.movedTemporarily] (302, alias for
  /// [HttpStatus.found]), [HttpStatus.seeOther] (303),
  /// [HttpStatus.temporaryRedirect] (307) and
  /// [HttpStatus.permanentRedirect] (308). For
  /// [HttpStatus.seeOther] (303) automatic redirect will also happen
  /// for "POST" requests with the method changed to "GET" when
  /// following the redirect.
  ///
  /// All headers added to the request will be added to the redirection
  /// request(s) except when forwarding sensitive headers like
  /// "Authorization", "WWW-Authenticate", and "Cookie". Those headers
  /// will be skipped if following a redirect to a domain that is not a
  /// subdomain match or exact match of the initial domain.
  /// For example, a redirect from "foo.com" to either "foo.com" or
  /// "sub.foo.com" will forward the sensitive headers, but a redirect to
  /// "bar.com" will not.
  ///
  /// Any body send with the request will not be part of the redirection
  /// request(s).
  ///
  /// For precise control of redirect handling, set this property to `false`
  /// and make a separate HTTP request to process the redirect. For example:
  ///
  /// ```dart
  /// final client = HttpClient();
  /// var uri = Uri.parse("http://localhost/");
  /// var request = await client.getUrl(uri);
  /// request.followRedirects = false;
  /// var response = await request.close();
  /// while (response.isRedirect) {
  ///   response.drain();
  ///   final location = response.headers.value(HttpHeaders.locationHeader);
  ///   if (location != null) {
  ///     uri = uri.resolve(location);
  ///     request = await client.getUrl(uri);
  ///     // Set the body or headers as desired.
  ///     request.followRedirects = false;
  ///     response = await request.close();
  ///   }
  /// }
  /// // Do something with the final response.
  /// ```
  @override
  bool followRedirects = true;

  /// Set this property to the maximum number of redirects to follow
  /// when [followRedirects] is `true`. If this number is exceeded
  /// an error event will be added with a [RedirectException].
  ///
  /// The default value is 5.
  @override
  int maxRedirects = 5;

  /// The method of the request.
  @override
  final String method;

  /// The uri of the request.
  @override
  final Uri uri;

  /// Gets and sets the content length of the request.
  ///
  /// If the size of the request is not known in advance set content length to
  /// -1, which is also the default.
  @override
  int contentLength;

  /// Gets or sets if the [HttpClientRequest] should buffer output.
  ///
  /// Default value is `true`.
  ///
  /// __Note__: Disabling buffering of the output can result in very poor
  /// performance, when writing many small chunks.
  @override
  bool bufferOutput = true;

  /// Returns the client request headers.
  ///
  /// The client request headers can be modified until the client
  /// request body is written to or closed. After that they become
  /// immutable.
  @override
  HttpHeaders get headers => FakeHttpHeaders(
      // Map.fromEntries(
      //   harResponse.headers.map((e) => MapEntry(e.name, [e.value])),
      // ),
      );

  /// Cookies to present to the server (in the 'cookie' header).
  @override
  final List<Cookie> cookies;

  /// An [HttpClientResponse] future that will complete once the response is
  /// available.
  ///
  /// If an error occurs before the response is available, this future will
  /// complete with an error.
  @override
  Future<HttpClientResponse> get done => _completer.future;

  /// Close the request for input. Returns the value of [done].
  @override
  Future<HttpClientResponse> close() async {
    if (delay case final delay?) {
      await Future<void>.delayed(delay);
    }
    if (_completer.isCompleted) {
      return done;
    }

    final requestBody = switch (await _bytesCompleter?.future) {
      final bytes? => encoding.decode(bytes),
      _ => null,
    };

    final harResponse = this.harResponse ??
        await manager?.getResponse(
          method: method,
          uri: uri,
          body: requestBody,
        );
    if (harResponse == null) {
      throw StateError('No response found for $method $uri');
    }

    final body = switch (harResponse.content) {
      HarResponseContent(:final text, encoding: 'base64') =>
        base64.decode(text),
      HarResponseContent(:final text, encoding: 'utf-8') => text,
      HarResponseContent(:final text) => encoding.encode(text),
    };

    final headers = Map.fromEntries(
      harResponse.headers.map((e) => MapEntry(e.name, [e.value])),
    );
    final response = FakeHttpResponse(
      statusCode: harResponse.status,
      body: body,
      headers: headers,
    );

    _completer.complete(response);

    return done;
  }

  /// Gets information about the client connection.
  ///
  /// Returns `null` if the socket is not available.
  @override
  final HttpConnectionInfo? connectionInfo;

  /// Aborts the client connection.
  ///
  /// If the connection has not yet completed, the request is aborted and the
  /// [done] future (also returned by [close]) is completed with the provided
  /// [exception] and [stackTrace].
  /// If [exception] is omitted, it defaults to an [HttpException], and if
  /// [stackTrace] is omitted, it defaults to [StackTrace.empty].
  ///
  /// If the [done] future has already completed, aborting has no effect.
  ///
  /// Using the [IOSink] methods (e.g., [write] and [add]) has no effect after
  /// the request has been aborted
  ///
  /// ```dart import:async
  /// var client = HttpClient();
  /// HttpClientRequest request = await client.get('localhost', 80, '/file.txt');
  /// request.write('request content');
  /// Timer(Duration(seconds: 1), () {
  ///   request.abort();
  /// });
  /// request.close().then((response) {
  ///   // If response comes back before abort, this callback will be called.
  /// }, onError: (e) {
  ///   // If abort() called before response is available, onError will fire.
  /// });
  /// ```
  @override
  void abort([Object? exception, StackTrace? stackTrace]) {}

  @override
  Encoding encoding = utf8;

  @override
  void add(List<int> data) {
    // TODO: implement add
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    // TODO: implement addError
  }

  @override
  Future<void> addStream(Stream<List<int>> stream) async {
    _bytesCompleter ??= Completer<List<int>>();
    final bytes = <int>[];

    await stream.forEach(bytes.addAll);

    _bytesCompleter?.complete(bytes);
  }

  @override
  Future<Object> flush() {
    // TODO: implement flush
    throw UnimplementedError();
  }

  @override
  void write(Object? object) {
    // TODO: implement write
  }

  @override
  // ignore: avoid-dynamic
  void writeAll(Iterable<dynamic> objects, [String separator = '']) {
    // TODO: implement writeAll
  }

  @override
  void writeCharCode(int charCode) {
    // TODO: implement writeCharCode
  }

  @override
  void writeln([Object? object = '']) {
    // TODO: implement writeln
  }
}
