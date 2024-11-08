import 'dart:io';

import 'package:checks/checks.dart';
import 'package:dio/dio.dart';
import 'package:fake_http_client/fake_http_client.dart';
import 'package:test/test.dart';

import 'har/json_placeholder_api.dart';
import 'har/post.dart';

void main() {
  setUp(() async {
    HttpOverrides.global = await FakeHttpOverrides.createFromFile(
      File('test/har/json_placeholder.har'),
    );
  });

  tearDown(() {
    HttpOverrides.global = null;
  });

  test('fake http client ...', () async {
    final api = JsonPlaceholderApi();
    final response = await api.getPosts();
    final posts = PostList.fromJson(response.data!);

    check(response.statusCode).equals(200);
    check(posts.posts.length).equals(100);
  });

  test('get posts with user id', () async {
    final api = JsonPlaceholderApi();
    final response = await api.getPosts(userId: 1);
    final posts = PostList.fromJson(response.data!);

    check(response.statusCode).equals(200);
    check(posts.posts.length).equals(10);
  });

  test('get post with id 1', () async {
    final api = JsonPlaceholderApi();
    final response = await api.getPost(1);
    final post = Post.fromJson(response.data!);

    check(response.statusCode).equals(200);
    check(post.id).equals(1);
    check(post.userId).equals(1);
    check(post.title).equals(
      'sunt aut facere repellat provident occaecati excepturi optio reprehenderit',
    );
    check(post.body).equals(
      'quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto',
    );
  });

  test('get uknown post should response error', () async {
    final api = JsonPlaceholderApi();

    try {
      await api.getPost(101);
    } on DioException catch (e) {
      check(e.response?.statusCode).equals(404);
    }
  });
}
