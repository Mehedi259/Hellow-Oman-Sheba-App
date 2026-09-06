import 'dart:io';

void main() {
  final file = File('lib/presentation/home/widgets/community_widget.dart');
  var content = file.readAsStringSync();
  
  // Look for the Row that displays the author and time
  final target = '''
              // Author and Time row
              Row(
                children: [
                  const Icon(Icons.person_outline_rounded, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      post.authorName.isNotEmpty ? post.authorName : 'অজ্ঞাত',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text('•', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                  ),
                  const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(post.createdAt),
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  ),
                ],
              ),
''';

  final replacement = '''
              // Author and Time row
              Row(
                children: [
                  if (post.authorProfilePicture != null && post.authorProfilePicture!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Image.network(
                        post.authorProfilePicture!,
                        width: 18,
                        height: 18,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
                      ),
                    )
                  else
                    _buildDefaultAvatar(),
                  const SizedBox(width: 6),
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
                  const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 2),
                  Text(
                    _formatTime(post.createdAt),
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  ),
                ],
              ),
''';

  content = content.replaceFirst(target, replacement);

  // Add the _buildDefaultAvatar helper to the bottom of the widget
  if (!content.contains('_buildDefaultAvatar')) {
    content = content.replaceFirst(
      '  @override\n  Widget build(BuildContext context) {',
      '''
  Widget _buildDefaultAvatar() {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, size: 12, color: Color(0xFF64748B)),
    );
  }

  @override
  Widget build(BuildContext context) {'''
    );
  }
  
  file.writeAsStringSync(content);
  print('Fixed community card');
}
