import 'dart:io';

void main() {
  final file = File('lib/data/models/post.dart');
  var content = file.readAsStringSync();
  
  // Replace the authorName line
  final newAuthorLogic = '''      authorName: () {
        String name = (json['author_first_name'] ?? '').toString().trim();
        if (name.isEmpty) name = (json['author_name'] ?? '').toString().trim();
        if (name.isEmpty) name = 'অজ্ঞাত';
        return name;
      }(),''';
      
  content = content.replaceFirst(
    "authorName: json['author_first_name'] ?? json['author_name'] ?? 'অজ্ঞাত',",
    newAuthorLogic
  );
  
  file.writeAsStringSync(content);
  print('Fixed post model');
}
