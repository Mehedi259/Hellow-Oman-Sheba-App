import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/classifieds_models.dart';
import '../classifieds_detail_screens.dart';

class MarketCardWidget extends StatefulWidget {
  final MarketItem item;
  
  const MarketCardWidget({super.key, required this.item});

  @override
  State<MarketCardWidget> createState() => _MarketCardWidgetState();
}

class _MarketCardWidgetState extends State<MarketCardWidget> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MarketItemDetailScreen(item: widget.item),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with Overlays
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image
                  widget.item.images.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: widget.item.images[0].startsWith('http') 
                              ? widget.item.images[0] 
                              : 'http://188.245.212.240${widget.item.images[0]}',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey.shade100,
                            child: Center(
                              child: SizedBox(
                                width: 24, height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.store, color: Colors.grey, size: 50),
                        )
                      : const Icon(Icons.store, color: Colors.grey, size: 50),
                  
                  // Favorite Button (Top Right)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isFavorite = !isFavorite;
                        });
                        // In a real app, you would also trigger an API call or update a provider here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isFavorite 
                                  ? 'পছন্দের তালিকায় যুক্ত করা হয়েছে' 
                                  : 'পছন্দের তালিকা থেকে সরানো হয়েছে'
                            ),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, 
                          color: isFavorite ? const Color(0xFFEF4444) : Colors.white, // Red or White
                          size: 18,
                        ),
                      ),
                    ),
                  ),

                  // Price Tag (Bottom Right)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${widget.item.price} ${widget.item.currency}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Details Section (Just the title)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 4, right: 4, bottom: 4),
            child: Text(
              widget.item.title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
