import 'dart:io';

import 'package:checks/checks.dart';
import 'package:fake_http_client/fake_http_client.dart';
import 'package:test/test.dart';

import 'har/json_placeholder_api.dart';

void main() {
  test('fake http client ...', () async {
    HttpOverrides.global =
        await FakeHttpOverrides.createFromFile('test/har/json_placeholder.har');
    final api = JsonPlaceholderApi();

    final posts = await api.getPosts();

    check(posts.posts.length).equals(100);
  });
}
