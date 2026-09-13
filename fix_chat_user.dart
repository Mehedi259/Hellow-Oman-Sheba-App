import 'dart:io';

void main() {
  final file = File('/Users/mehedihasanmridul/app/Hellow-Oman-Sheba-App/lib/data/models/chat_models.dart');
  var content = file.readAsStringSync();

  // Add username to ChatUser class
  content = content.replaceFirst(
'''class ChatUser {
  final int id;
  final String? firstName;
  final String? lastName;
  final String? profilePicture;

  ChatUser({
    required this.id,
    this.firstName,
    this.lastName,
    this.profilePicture,
  });''',
'''class ChatUser {
  final int id;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? profilePicture;

  ChatUser({
    required this.id,
    this.username,
    this.firstName,
    this.lastName,
    this.profilePicture,
  });'''
  );

  // Add username parsing
  content = content.replaceFirst(
'''  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'],
      firstName: json['name'] ?? json['first_name'],
      lastName: json['last_name'],
      profilePicture: json['avatar'] ?? json['profile_picture'] ?? json['avatar_url'],
    );
  }''',
'''  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'],
      username: json['username'],
      firstName: json['name'] ?? json['first_name'],
      lastName: json['last_name'],
      profilePicture: json['avatar'] ?? json['profile_picture'] ?? json['avatar_url'],
    );
  }'''
  );

  // Fix fullName fallback to username
  content = content.replaceFirst(
'''  String get fullName {
    final name = '\${firstName ?? ''} \${lastName ?? ''}'.trim();
    if (name.isEmpty) return 'User \$id';
    return name;
  }''',
'''  String get fullName {
    final name = '\${firstName ?? ''} \${lastName ?? ''}'.trim();
    if (name.isEmpty) return username ?? 'User \$id';
    return name;
  }'''
  );

  file.writeAsStringSync(content);
}
