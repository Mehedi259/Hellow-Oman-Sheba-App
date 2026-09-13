import 'dart:io';

void main() {
  final file = File('/Users/mehedihasanmridul/app/Hellow-Oman-Sheba-App/lib/presentation/my_listings/my_listings_screen.dart');
  var content = file.readAsStringSync();

  // Helper function for image extraction
  final imgHelper = '''
  String? _extractImageUrl(Map<String, dynamic> post) {
    if (post['images'] != null && post['images'] is List && (post['images'] as List).isNotEmpty) {
      final first = (post['images'] as List).first;
      if (first is Map) return first['image']?.toString() ?? first['url']?.toString();
      return first.toString();
    }
    if (post['image_url'] != null && post['image_url'].toString().isNotEmpty) return post['image_url'].toString();
    if (post['image'] != null && post['image'].toString().isNotEmpty) return post['image'].toString();
    if (post['photo'] != null && post['photo'].toString().isNotEmpty) return post['photo'].toString();
    if (post['primary_image'] != null && post['primary_image'].toString().isNotEmpty) return post['primary_image'].toString();
    return null;
  }
  
  String _getAbsoluteUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return 'http://188.245.212.240\$url';
  }
''';

  content = content.replaceFirst('  Widget _buildPostsTab() {', imgHelper + '\n  Widget _buildPostsTab() {');

  // Replace the image/icon rendering
  final newCardContent = '''
              final rawImageUrl = _extractImageUrl(post as Map<String, dynamic>);
              final imageUrl = _getAbsoluteUrl(rawImageUrl);

              return _buildCard(
                onTap: () => _navigateToItem(context, type, id),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64, height: 64,
                      alignment: Alignment.center,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildFallbackIcon(type),
                            )
                          : _buildFallbackIcon(type),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
''';

  content = content.replaceFirst(
'''              return _buildCard(
                onTap: () => _navigateToItem(context, type, id),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56, height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF0056D2).withOpacity(0.15),
                            const Color(0xFF0056D2).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF0056D2).withOpacity(0.1)),
                      ),
                      child: Text(iconPath, style: const TextStyle(fontSize: 26)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(''', newCardContent);

  final fallbackIconMethod = '''
  Widget _buildFallbackIcon(String type) {
    IconData iconData = Icons.article_outlined;
    if (type == 'property') iconData = Icons.home_work_outlined;
    if (type == 'vehicle') iconData = Icons.directions_car_outlined;
    if (type == 'service') iconData = Icons.design_services_outlined;
    if (type == 'job_seeker') iconData = Icons.person_search_outlined;
    if (type == 'job') iconData = Icons.work_outline;

    return Icon(iconData, size: 28, color: const Color(0xFF94A3B8));
  }
''';

  content = content.replaceFirst('  Widget _buildPostsTab() {', fallbackIconMethod + '\n  Widget _buildPostsTab() {');
  
  // Remove the old iconPath string assignment
  content = content.replaceFirst(
'''              String iconPath = '💼';
              if (type == 'property') iconPath = '🏠';
              if (type == 'vehicle') iconPath = '🚗';
              if (type == 'service') iconPath = '🛠️';
              if (type == 'job_seeker') iconPath = '👨‍🔧';
''', '');

  file.writeAsStringSync(content);
}
