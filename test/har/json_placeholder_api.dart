// ignore_for_file: avoid-dynamic

import 'package:dio/dio.dart';

import 'post.dart';

class JsonPlaceholderApi {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  final dio = Dio();

  Future<PostList> getPosts() async {
    final response = await dio.get<List<dynamic>>('$baseUrl/posts');

    return PostList.fromJson(response.data!);
  }
}
