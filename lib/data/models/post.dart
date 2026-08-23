class Post {
  final int id;
  final String title;
  final String content;
  final String authorName;
  final String categoryName;
  final int likes;
  final int commentsCount;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.categoryName,
    required this.likes,
    required this.commentsCount,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      authorName: json['author_first_name'] ?? json['author_name'] ?? 'অজ্ঞাত',
      categoryName: json['category'] != null ? (json['category']['nameBn'] ?? json['category']['name'] ?? 'সাধারণ আলোচনা') : 'সাধারণ আলোচনা',
      likes: json['likes'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
