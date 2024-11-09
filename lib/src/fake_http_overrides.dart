import 'dart:io';

import '../fake_http_client.dart';

class FakeHttpOverrides extends HttpOverrides {
  FakeHttpOverrides({
    required this.harRoot,
  });

  final HarRoot harRoot;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return FakeHttpClient(harRoot: harRoot);
  }
}
