import 'dart:io';

void main() {
  final file = File('/Users/mehedihasanmridul/app/Hellow-Oman-Sheba-App/lib/data/models/chat_models.dart');
  var content = file.readAsStringSync();

  // Fix avatar URL extraction
  content = content.replaceFirst(
      "profilePicture: json['profile_picture'] ?? json['avatar_url'],",
      "profilePicture: json['avatar'] ?? json['profile_picture'] ?? json['avatar_url'],"
  );
  
  // Fix name extraction
  content = content.replaceFirst(
      "firstName: json['first_name'],",
      "firstName: json['name'] ?? json['first_name'],"
  );

  // Fix fullName logic
  content = content.replaceFirst(
'''  String get fullName {
    if (firstName == null && lastName == null) return 'User \$id';
    return '\${firstName ?? ''} \${lastName ?? ''}'.trim();
  }''',
'''  String get fullName {
    final name = '\${firstName ?? ''} \${lastName ?? ''}'.trim();
    if (name.isEmpty) return 'User \$id';
    return name;
  }'''
  );

  file.writeAsStringSync(content);
}
