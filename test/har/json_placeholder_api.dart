// ignore_for_file: avoid-dynamic

import 'package:dio/dio.dart';

typedef JSON = Map<String, dynamic>;

class JsonPlaceholderApi {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  final dio = Dio();

  Future<Response<List<dynamic>>> getPosts({int? userId}) async {
    final response = await dio.get<List<dynamic>>(
      '$baseUrl/posts',
      queryParameters: {
        if (userId case final id?) 'userId': id,
      },
    );

    return response;
  }

  Future<Response<JSON>> getPost(int id) async {
    final response = await dio.get<Map<String, dynamic>>('$baseUrl/posts/$id');

    return response;
  }
}
