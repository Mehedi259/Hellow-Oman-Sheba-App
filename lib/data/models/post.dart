class Post {
  final int id;
  final String title;
  final String content;
  final String authorName;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      authorName: json['author_name'] ?? 'Anonymous',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
