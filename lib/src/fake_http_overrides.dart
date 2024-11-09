import 'dart:convert';
import 'dart:io';

import '../fake_http_client.dart';

class FakeHttpOverrides extends HttpOverrides {
  FakeHttpOverrides({
    required this.harContent,
  });

  static Future<FakeHttpOverrides> createFromFile(String path) async {
    final file = File(path);

    return FakeHttpOverrides(
      harContent: jsonDecode(await file.readAsString()) as Map<String, dynamic>,
    );
  }

  final Map<String, dynamic> harContent;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return FakeHttpClient(harRoot: HarRoot.fromJson(harContent));
  }
}
