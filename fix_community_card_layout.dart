import 'dart:io';

void main() {
  final file = File('lib/presentation/home/widgets/community_widget.dart');
  var content = file.readAsStringSync();
  
  final target = '''
                  Flexible(
                    child: Text(
                      post.authorName.isNotEmpty ? post.authorName : 'অজ্ঞাত',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text('•', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                  ),
''';

  final replacement = '''
                  Expanded(
                    child: Text(
                      post.authorName.isNotEmpty ? post.authorName : 'অজ্ঞাত',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
''';

  content = content.replaceFirst(target, replacement);
  file.writeAsStringSync(content);
  print('Fixed community card layout');
}
