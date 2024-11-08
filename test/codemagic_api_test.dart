import 'dart:io';

import 'package:checks/checks.dart';
import 'package:fake_http_client/fake_http_client.dart';
import 'package:test/test.dart';

import 'codemagic_api.dart';

void main() {
  setUp(() async {
    HttpOverrides.global =
        await FakeHttpOverrides.createFromFile(File('test/har/codemagic.har'));
  });

  tearDown(() {
    HttpOverrides.global = null;
  });

  test('fake http client ...', () async {
    final api = CodemagicApi();
    final response = await api.getApps();

    check(response.statusCode).equals(200);
  });

  test('get builds', () async {
    final api = CodemagicApi();
    final response = await api.getBuilds();

    check(response.statusCode).equals(200);
  });

  test('run build', () async {
    final api = CodemagicApi();
    final response = await api.runBuild(
      appId: '65b4b43011c15979cab129c3',
      workflowId: '65b4b43011c15979cab129c2',
      branch: 'main',
    );

    check(response.statusCode).equals(200);
  });
}
