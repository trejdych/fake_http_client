import 'dart:convert';
import 'dart:io';

import 'package:checks/checks.dart';
import 'package:fake_http_client/fake_http_client.dart';
import 'package:test/test.dart';

import '../har/igvita.har.dart';

void main() {
  test('fake http client ...', () async {
    final harRoot =
        HarRoot.fromJson(jsonDecode(igvitaHar) as Map<String, dynamic>);
    final client = FakeHttpClient(harRoot: harRoot);
    final request = await client.getUrl(Uri.http('www.igvita.com'));
    final response = await request.close();

    check(response.statusCode).equals(200);
    check(response.headers.value(HttpHeaders.contentTypeHeader))
        .equals('text/html; charset=utf-8');
  });
}
