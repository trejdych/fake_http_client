import 'dart:async';
import 'dart:io';

import 'fake_http_client_request.dart';
import 'fake_http_headers.dart';
import 'fake_http_response.dart';

/// A callback to simulate authentication.
///
/// See [HttpClient.authenticate].
///
/// This is not invoked automatically be the test client if set, but
/// it can be accessed in the [RequestCallback] method.
typedef AuthenticateCallback = Future<bool> Function(Uri, String, String);

/// A callback to simulate proxy authentication.
///
/// See [HttpClient.authenticateProxy].
///
/// This is not invoked automatically be the test client if set, but
/// it can be accessed in the [RequestCallback] method.
typedef AuthenticateProxyCallback = Future<bool> Function(
  String,
  int,
  String,
  String,
);

/// A callback to simulate a bad certificate.
///
/// See [HttpClient.badCertificateCallback].
///
/// This is not invoked automatically be the test client if set, but
/// it can be accessed in the [RequestCallback] method.
typedef BadCertificateCallback = Function(X509Certificate, String, int);

/// Callback which can be invoked to resolve a proxy [Uri].
///
/// See [HttpClient.findProxy].
///
/// This is not invoked automatically be the test client if set, but
/// it can be accessed in the [RequestCallback] method.
typedef FindProxyCallback = String Function(Uri);

/// A fake [HttpClient] for testing Flutter or Dart VM applications.
///
/// Using [HttpOverrides.global] and an [FakeHttpClient], you can test code which
/// uses [HttpClient()] without dependency injection. All you need to do
/// is create a test client and specify how you want it to respond using a
/// [RequestCallback].
///
/// Currently the test client only supports the following HTTP methods:
///
///   * [getUrl]
///   * [postUrl]
///   * [headUrl]
///   * [patchUrl]
///   * [deleteUrl]
///   * [openUrl]
///   * [patchUrl]
///
/// Any of the non *Url methods will throw.  The other members from the
/// http client can be read in the [RequestCallback] but won't be used
/// otherwise. Currently [close], [addCredentials] and [addProxyCredentials]
/// do nothing.
///
/// The following example forces all HTTP requests to return a
/// successful empty response.
///
///     class MyHttpOverrides extends HttpOverrides {
///       HttpClient() createClient(_) {
///         return FakeHttpClient((HttpRequest request, FakeHttpClient client) {
///           return FakeHttpResponse();
///         });
///       }
///     }
///
///     void main() {
///       // overrides all HttpClients.
///       HttpOverrides.global = MyHttpOverrides();
///
///       group('Widget tests', () {
///         test('returns 200', () async {
///            // this is actually an instance of [FakeHttpClient].
///            final client = HttpClient();
///            final request = client.getUrl(Uri.https('google.com'));
///            final response = await request.close();
///
///            expect(response.statusCode, HttpStatus.ok);
///         });
///       });
///     }
///
/// If you don't want to override all HttpClients, you can also use
/// [HttpOverrides.runZoned].  Anything which executes in the provided callback
/// will use the provided http client.
///
/// See also:
///
///   * [HttpClient]
///   * [FakeHttpResponse]
///   * [HttpOverrides]
class FakeHttpClient implements HttpClient {
  FakeHttpClient();

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
  AuthenticateCallback? authenticate;

  @override
  AuthenticateProxyCallback? authenticateProxy;

  @override
  FindProxyCallback? findProxy;

  @override
  BadCertificateCallback? badCertificateCallback;

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
    final HttpClientRequest request = FakeHttpClientRequest(
      method: method,
      uri: url,
      headers: FakeHttpHeaders(),
    );

    await request.close();

    return request;
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
