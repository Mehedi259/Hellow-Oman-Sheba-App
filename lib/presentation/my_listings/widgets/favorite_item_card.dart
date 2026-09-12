import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../navigation_utils.dart';
import '../../auth/auth_provider.dart';
import '../providers/my_listings_provider.dart';

class FavoriteItemCard extends ConsumerWidget {
  final dynamic item;
  final int favId;
  final String contentType;
  final String contentIdStr;

  const FavoriteItemCard({
    super.key,
    required this.item,
    required this.favId,
    required this.contentType,
    required this.contentIdStr,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<String, dynamic>? details = item['item_details'];
    
    final String title = details?['title'] ?? details?['title_bn'] ?? item['title'] ?? item['favorite_type'] ?? 'Favorite Item';
    final String description = details?['description'] ?? 'ID: ${item['favorite_id'] ?? item['content_id'] ?? ''}';
    final String? location = details?['location'];
    final String? price = details?['price'];
    final String iconStr = details?['icon'] ?? '❤️';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8)),
          BoxShadow(color: const Color(0xFF0056D2).withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
             final id = int.tryParse(contentIdStr);
             if (id != null) {
               navigateToFavoriteItem(context, ref, contentType, id);
             }
          },
          highlightColor: const Color(0xFF0056D2).withOpacity(0.05),
          splashColor: const Color(0xFF0056D2).withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
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
                        const Color(0xFFEC4899).withOpacity(0.15),
                        const Color(0xFFEC4899).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEC4899).withOpacity(0.1)),
                  ),
                  child: Text(iconStr, style: const TextStyle(fontSize: 26)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E293B), fontSize: 17, height: 1.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (location != null && location.isNotEmpty) ...[
                            const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 4),
                            Flexible(child: Text(location, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)), overflow: TextOverflow.ellipsis)),
                            const SizedBox(width: 12),
                          ],
                          if (price != null && price.isNotEmpty && price != '0.00' && price != '0') ...[
                            const Icon(Icons.payments_rounded, size: 14, color: Color(0xFF10B981)),
                            const SizedBox(width: 4),
                            Text('$price OMR', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF10B981))),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    try {
                      await ref.read(authRepositoryProvider).removeFavorite(favId);
                      ref.invalidate(myFavoritesProvider);
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed from favorites')));
                    } catch (e) {
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_rounded, color: Color(0xFFEF4444), size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
