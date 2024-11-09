// ignore_for_file: avoid-dynamic

class Post {
  Post({
    this.id,
    this.title,
    this.body,
    this.userId,
  });

  Post.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        title = json['title'] as String?,
        body = json['body'] as String?,
        userId = json['userId'] as int?;
  final int? id;
  final String? title;
  final String? body;
  final int? userId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'userId': userId,
      };
}

class PostList {
  PostList({
    required this.posts,
  });

  factory PostList.fromJson(List<dynamic> json) {
    final posts = (json as List<dynamic>?)
        ?.map((dynamic e) => Post.fromJson(e as Map<String, dynamic>))
        .toList();

    return PostList(
      posts: posts ?? const [],
    );
  }

  final List<Post> posts;
}
