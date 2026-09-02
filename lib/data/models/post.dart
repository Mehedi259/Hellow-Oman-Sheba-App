class Post {
  final int id;
  final String title;
  final String content;
  final String authorName;
  final int authorId;
  final String? authorProfilePicture;
  final String categoryName;
  final int likes;
  final int commentsCount;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.authorId,
    this.authorProfilePicture,
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
      authorId: json['author_id'] ?? json['user'] ?? json['user_id'] ?? 1,
      authorProfilePicture: json['author_profile_picture'] ?? json['user_profile_picture'],
      categoryName: json['category'] != null ? (json['category']['nameBn'] ?? json['category']['name'] ?? 'সাধারণ আলোচনা') : 'সাধারণ আলোচনা',
      likes: json['likes'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
