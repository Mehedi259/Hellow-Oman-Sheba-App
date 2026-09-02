import '../../chat/widgets/chat_initiator_button.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/classifieds_models.dart';
import '../../classifieds/classifieds_detail_screens.dart';
import 'section_header.dart';

class PropertiesWidget extends StatelessWidget {
  final List<Property> properties;

  const PropertiesWidget({super.key, required this.properties});

  @override
  Widget build(BuildContext context) {
    if (properties.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'বাসা ভাড়া',
          subtitle: 'আপনার পছন্দের বাসা খুঁজুন',
          icon: Icons.apartment_rounded,
          color: const Color(0xFF0056D2), // Logo Blue
          onSeeAllPressed: () {
            context.push('/classifieds?tab=properties');
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final item = properties[index];
              return PropertyRentCard(property: item);
            },
          ),
        ),
      ],
    );
  }
}

class PropertyRentCard extends StatefulWidget {
  final Property property;
  const PropertyRentCard({super.key, required this.property});

  @override
  State<PropertyRentCard> createState() => _PropertyRentCardState();
}

class _PropertyRentCardState extends State<PropertyRentCard> {
  int _currentImageIndex = 0;
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    List<String> images = widget.property.images.isNotEmpty 
        ? widget.property.images
        : (widget.property.imageUrl != null && widget.property.imageUrl!.isNotEmpty
            ? [widget.property.imageUrl!] 
            : []);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PropertyDetailScreen(property: widget.property),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Slider
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Stack(
                children: [
                  images.isNotEmpty
                      ? PageView.builder(
                          itemCount: images.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return CachedNetworkImage(
                              imageUrl: images[index].startsWith('http') 
                                  ? images[index] 
                                  : 'http://188.245.212.240${images[index]}',
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: Colors.grey.shade100),
                              errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey.shade100,
                          child: const Center(child: Icon(Icons.apartment, color: Colors.grey, size: 50)),
                        ),
                  
                  // Indicators
                  if (images.length > 1)
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == index ? Colors.white : Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Content
            Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price
                    Text(
                      '${widget.property.price} OMR', // Assuming OMR for now
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDC2626), // Red color
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Title
                    Text(
                      widget.property.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    
                    // Condition / Category Tag
                    Row(
                      children: [
                        const Icon(Icons.verified_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          widget.property.type.isNotEmpty ? widget.property.type : 'New',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Dashed Divider
                    const DashedDivider(),
                    const SizedBox(height: 8),
                    
                    // Location
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: Colors.black87),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.property.location,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Property Type: ${widget.property.type}',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                      // Bottom Actions
                    Row(
                      children: [
                        // Call Button
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: 36,
                            child: ElevatedButton(
                              onPressed: () async {
                                final phone = widget.property.contactInfo;
                                final url = Uri.parse('tel:$phone');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF007BFF), // Blue
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Icon(Icons.phone, size: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Message Button
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: 36,
                            child: ChatInitiatorButton(
                              targetUserId: widget.property.ownerId ?? 1,
                              title: widget.property.title,
                              initialMessage: 'আমি এই প্রপার্টি সম্পর্কে জানতে চাচ্ছি: ${widget.property.title}',
                              relatedObjectType: 'property',
                              relatedObjectId: widget.property.id,
                              icon: const Icon(Icons.chat_bubble_outline, size: 18),
                              label: '',
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Favorite Button
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: isFavorite ? const Color(0xFFDC2626) : Colors.grey.shade600,
                              size: 18,
                            ),
                            onPressed: () {
                              setState(() {
                                isFavorite = !isFavorite;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DashedDivider extends StatelessWidget {
  const DashedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.grey.shade300),
              ),
            );
          }),
        );
      },
    );
  }
}
