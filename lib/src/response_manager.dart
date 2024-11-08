import 'dart:math';

import '../fake_http_client.dart';

class ResponseManager {
  ResponseManager({
    required this.harRoot,
  });

  final HarRoot harRoot;

  final Map<String, int> _counters = {};

  Future<HarResponse> getResponse({
    required String method,
    required Uri uri,
    required String? body,
  }) async {
    try {
      // final responses = harRoot.log.entries
      //     .where(
      //       (entry) =>
      //           entry.request.method == method &&
      //           entry.request.url.contains(uri.path),
      //     )
      //     .toList();
      var responses = harRoot.log.entries.where(
        (entry) {
          final requestUri = Uri.parse(entry.request.url);

          return entry.request.method == method &&
              uri.path == requestUri.path &&
              uri.query == requestUri.query;
        },
      ).toList();
      if (responses.isEmpty) {
        responses = harRoot.log.entries.where(
          (entry) {
            final requestUri = Uri.parse(entry.request.url);

            return entry.request.method == method &&
                uri.path == requestUri.path;
          },
        ).toList();

        if (responses.length > 1) {
          responses.sort((a, b) {
            final uriA = Uri.parse(a.request.url);
            final uriB = Uri.parse(b.request.url);
            final countA = _countMatchingQueryParams(uriA, uri);
            final countB = _countMatchingQueryParams(uriB, uri);

            return countB.compareTo(countA);
          });
        }
      }

      if (responses.isEmpty) {
        throw Exception('No response found for $method $uri');
      }

      if (responses.length == 1) {
        return responses.first.response;
      }
      final key = '$method $uri';
      final count = min(
        switch (_counters[key]) {
          final count? => count + 1,
          _ => 0,
        },
        responses.length - 1,
      );

      _counters[key] = count;

      return responses[count].response;
    } catch (e, s) {
      if (uri.path.endsWith('.png')) {
        // return FakeHttpRequest.imagePng(uri: uri, method: method);
      }
      Error.throwWithStackTrace('No response found for $method $uri', s);
    }
  }

  // Future<FakeHttpRequest> getRequest({
  //   required String method,
  //   required Uri uri,
  // }) async {
  //   try {
  //     final responses = harRoot.log.entries
  //         .where(
  //           (entry) =>
  //               entry.request.method == method &&
  //               entry.request.url.contains(uri.path),
  //         )
  //         .toList();

  //     if (responses.length > 1) {
  //       responses.sort((a, b) {
  //         final uriA = Uri.parse(a.request.url);
  //         final uriB = Uri.parse(b.request.url);
  //         final countA = _countMatchingQueryParams(uriA, uri);
  //         final countB = _countMatchingQueryParams(uriB, uri);

  //         return countB.compareTo(countA);
  //       });
  //     }

  //     return FakeHttpRequest(
  //       method: method,
  //       uri: uri,
  //       harResponse: responses.first.response,
  //     );
  //   } catch (e, s) {
  //     if (uri.path.endsWith('.png')) {
  //       return FakeHttpRequest.imagePng(uri: uri, method: method);
  //     }
  //     Error.throwWithStackTrace('No response found for $method $uri', s);
  //   }
  // }

  int _countMatchingQueryParams(Uri requestUri, Uri targetUri) {
    final requestParams = requestUri.queryParameters;
    final targetParams = targetUri.queryParameters;
    var count = 0;

    for (final key in targetParams.keys) {
      if (requestParams.containsKey(key) &&
          requestParams[key] == targetParams[key]) {
        count++;
      }
    }

    return count;
  }
}
