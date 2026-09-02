import '../chat/widgets/chat_initiator_button.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/job.dart';
import '../../data/models/classifieds_models.dart';
import '../../data/repositories/classifieds_repository.dart';
import '../auth/auth_provider.dart';
import 'widgets/favorite_button.dart';
import 'widgets/reviews_section.dart';


final classifiedsRepositoryProvider = Provider((ref) {
  return ClassifiedsRepository(ref.watch(apiClientProvider));
});

class JobDetailScreen extends ConsumerWidget {
  final Job job;
  const JobDetailScreen({super.key, required this.job});

  String _timeAgo(DateTime createdAt) {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays > 0) return '${difference.inDays} দিন আগে';
    if (difference.inHours > 0) return '${difference.inHours} ঘণ্টা আগে';
    if (difference.inMinutes > 0) return '${difference.inMinutes} মিনিট আগে';
    return 'এইমাত্র';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasImages = job.images.isNotEmpty;
    final heroImageUrl = hasImages
        ? (job.images[0].startsWith('http') ? job.images[0] : 'http://188.245.212.240${job.images[0]}')
        : '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: FavoriteButton(contentType: 'job', contentId: job.id),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Image with Gradient Overlay ──
            SizedBox(
              height: hasImages ? 320 : 200,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasImages)
                    Image.network(
                      heroImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF1E3A5F),
                        child: const Icon(Icons.work_outline, color: Colors.white38, size: 80),
                      ),
                    )
                  else
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1E3A5F), Color(0xFF0F2942)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: const Center(child: Icon(Icons.work_outline, color: Colors.white24, size: 80)),
                    ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.15),
                          Colors.black.withOpacity(0.6),
                        ],
                        stops: const [0.3, 0.6, 1.0],
                      ),
                    ),
                  ),
                  // Job Type Badge + Views on Image
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.work_outline, color: Colors.white, size: 14),
                              const SizedBox(width: 6),
                              Text(job.jobType, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.access_time, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(_timeAgo(job.createdAt), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Multiple images indicator
                  if (job.images.length > 1)
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.photo_library, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text('${job.images.length}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Content Body ──
            Container(
              transform: Matrix4.translationValues(0, -24, 0),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      job.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        height: 1.3,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Company & Location Row
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.business_rounded, color: Color(0xFF2563EB), size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('প্রতিষ্ঠান', style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                                    const SizedBox(height: 2),
                                    Text(
                                      job.company.isNotEmpty ? job.company : 'প্রতিষ্ঠানের নাম দেওয়া নেই',
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Divider(height: 1, color: Colors.grey.shade100),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.location_on_rounded, color: Color(0xFFEF4444), size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('অবস্থান', style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                                    const SizedBox(height: 2),
                                    Text(
                                      job.location.isNotEmpty ? job.location : 'ঠিকানা দেওয়া নেই',
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Salary & Job Type Cards
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 20),
                                ),
                                const SizedBox(height: 12),
                                const Text('বেতন', style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                Text(
                                  job.salary,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.schedule_rounded, color: Colors.white, size: 20),
                                ),
                                const SizedBox(height: 12),
                                const Text('চাকরির ধরণ', style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                Text(
                                  job.jobType,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Description Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0EA5E9).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.description_rounded, color: Color(0xFF0EA5E9), size: 20),
                              ),
                              const SizedBox(width: 12),
                              const Text('বিস্তারিত বিবরণ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Text(
                              job.description.isNotEmpty ? job.description : 'কোনো বিবরণ দেওয়া নেই',
                              style: const TextStyle(fontSize: 15, color: Color(0xFF475569), height: 1.7, letterSpacing: 0.1),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Images gallery (if more than 1)
                    if (job.images.length > 1) ...[
                      const SizedBox(height: 28),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.photo_library_rounded, color: Color(0xFF10B981), size: 20),
                                ),
                                const SizedBox(width: 12),
                                Text('ছবি (${job.images.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: job.images.length,
                                itemBuilder: (context, index) {
                                  final imgUrl = job.images[index].startsWith('http')
                                      ? job.images[index]
                                      : 'http://188.245.212.240${job.images[index]}';
                                  return Container(
                                    margin: EdgeInsets.only(right: index < job.images.length - 1 ? 12 : 0),
                                    width: 140,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))],
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Image.network(
                                      imgUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(Icons.broken_image, color: Colors.grey),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    // Reviews Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 20),
                              ),
                              const SizedBox(width: 12),
                              const Text('রিভিউ ও মতামত', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ReviewsSection(contentType: 'job', contentId: job.id),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Bottom Action Bar ──
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -6)),
          ],
          border: Border(top: BorderSide(color: Colors.grey.shade100)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Call Button
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: IconButton(
                  onPressed: () async {
                    try {
                      await ref.read(classifiedsRepositoryProvider).applyForJob(job.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text('সফলভাবে আবেদন করা হয়েছে!'),
                              ],
                            ),
                            backgroundColor: Color(0xFF10B981),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ত্রুটি: $e'), backgroundColor: Colors.red));
                      }
                    }
                  },
                  icon: const Icon(Icons.send_rounded, color: Color(0xFF2563EB), size: 22),
                  tooltip: 'আবেদন করুন',
                ),
              ),
              const SizedBox(width: 12),
              // Message Button
              Expanded(
                child: ChatInitiatorButton(
                  targetUserId: job.ownerId ?? 1,
                  title: job.title,
                  initialMessage: 'আমি এই চাকরি সম্পর্কে জানতে চাচ্ছি: ${job.title}',
                  relatedObjectType: 'job',
                  relatedObjectId: job.id,
                  backgroundColor: const Color(0xFF2563EB),
                  label: 'মেসেজ পাঠান',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PropertyDetailScreen extends StatefulWidget {
  final Property property;
  const PropertyDetailScreen({super.key, required this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.property.images.isNotEmpty 
        ? widget.property.images 
        : (widget.property.imageUrl != null ? [widget.property.imageUrl!] : []);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: FavoriteButton(contentType: 'property', contentId: widget.property.id),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Header
            SizedBox(
              height: 300,
              width: double.infinity,
              child: images.isNotEmpty
                  ? Stack(
                      children: [
                        PageView.builder(
                          itemCount: images.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            final imgUrl = images[index].startsWith('http') 
                                ? images[index] 
                                : 'http://188.245.212.240${images[index]}';
                            return Image.network(
                              imgUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                              ),
                            );
                          },
                        ),
                        if (images.length > 1)
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                images.length,
                                (index) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: _currentImageIndex == index ? 12 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _currentImageIndex == index ? Colors.white : Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.apartment, color: Colors.grey, size: 80),
                    ),
            ),
            
            // Content
            Container(
              transform: Matrix4.translationValues(0.0, -20.0, 0.0),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.property.title,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E7FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${widget.property.price} OMR',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4338CA)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Location & Type
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFFDC2626), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.property.location.isNotEmpty ? widget.property.location : 'ঠিকানা দেওয়া নেই',
                            style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.home_work, color: Color(0xFF0056D2), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'ধরণ: ${widget.property.type.isNotEmpty ? widget.property.type : 'N/A'}',
                          style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    const Text('বিস্তারিত বিবরণ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const SizedBox(height: 12),
                    Text(
                      widget.property.description,
                      style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF475569)),
                    ),
                    
                    const SizedBox(height: 32),
                    const Text('যোগাযোগ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0xFFE2E8F0),
                            radius: 24,
                            child: Icon(Icons.person, color: Color(0xFF64748B), size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('মালিক/এজেন্ট', style: TextStyle(fontSize: 14, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(
                                  widget.property.contactInfo.isNotEmpty ? widget.property.contactInfo : 'যোগাযোগ নম্বর নেই',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    ReviewsSection(contentType: 'property', contentId: widget.property.id),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16).copyWith(bottom: MediaQuery.of(context).padding.bottom + 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final phone = widget.property.contactInfo;
                  if (phone.isNotEmpty) {
                    final url = Uri.parse('tel:$phone');
                    if (await canLaunchUrl(url)) await launchUrl(url);
                  }
                },
                icon: const Icon(Icons.phone),
                label: const Text('কল করুন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007BFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ChatInitiatorButton(
                targetUserId: widget.property.ownerId ?? 1,
                title: widget.property.title,
                initialMessage: 'আমি এই প্রপার্টি সম্পর্কে জানতে চাচ্ছি: ${widget.property.title}',
                relatedObjectType: 'property',
                relatedObjectId: widget.property.id,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VehicleDetailScreen extends StatelessWidget {
  final Vehicle vehicle;
  const VehicleDetailScreen({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(vehicle.title), actions: [FavoriteButton(contentType: 'vehicle', contentId: vehicle.id)]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vehicle.imageUrl != null)
              Image.network(
                vehicle.imageUrl!.startsWith('http') ? vehicle.imageUrl! : 'http://188.245.212.240${vehicle.imageUrl}',
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(height: 250, color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey, size: 50)),
              ),
            const SizedBox(height: 16),
            Text(vehicle.title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('\$${vehicle.price}', style: const TextStyle(fontSize: 24, color: Colors.teal, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('${vehicle.make} ${vehicle.model} • ${vehicle.year} • ${vehicle.mileage} km'),
            const SizedBox(height: 24),
            const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(vehicle.description),
            const SizedBox(height: 24),
            const Text('Contact Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(vehicle.contactInfo),
            const SizedBox(height: 32),
            ReviewsSection(contentType: 'vehicle', contentId: vehicle.id),
          ],
        ),
      ),
    );
  }
}

class ServiceDetailScreen extends StatelessWidget {
  final Service service;
  const ServiceDetailScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(service.title), actions: [FavoriteButton(contentType: 'service', contentId: service.id)]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (service.imageUrl != null)
              Image.network(
                service.imageUrl!.startsWith('http') ? service.imageUrl! : 'http://188.245.212.240${service.imageUrl}',
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(height: 250, color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey, size: 50)),
              ),
            const SizedBox(height: 16),
            Text(service.title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(service.category, style: const TextStyle(fontSize: 18, color: Colors.teal)),
            const SizedBox(height: 24),
            const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(service.description),
            const SizedBox(height: 24),
            const Text('Contact Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(service.contactInfo),
            const SizedBox(height: 32),
            ReviewsSection(contentType: 'service', contentId: service.id),
          ],
        ),
      ),
    );
  }
}

class MarketItemDetailScreen extends StatefulWidget {
  final MarketItem item;
  const MarketItemDetailScreen({super.key, required this.item});

  @override
  State<MarketItemDetailScreen> createState() => _MarketItemDetailScreenState();
}

class _MarketItemDetailScreenState extends State<MarketItemDetailScreen> {
  int _currentImageIndex = 0;

  String _timeAgo(DateTime createdAt) {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays > 0) {
      return '${difference.inDays} দিন আগে';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ঘণ্টা আগে';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} মিনিট আগে';
    } else {
      return 'এইমাত্র';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100), // Padding to prevent nav bar overlap
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Purple Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6B21A8), Color(0xFF4C1D95)], // Deep purple gradient
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'সব বিজ্ঞাপন দেখুন',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      widget.item.categoryName,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.item.city}${widget.item.area.isNotEmpty ? ', ${widget.item.area}' : ''}',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.calendar_today_outlined, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _timeAgo(widget.item.createdAt),
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Image Gallery
            if (widget.item.images.isNotEmpty)
              Column(
                children: [
                  // Main Image
                  Container(
                    height: 250,
                    width: double.infinity,
                    color: Colors.grey.shade100,
                    child: Image.network(
                      widget.item.images[_currentImageIndex].startsWith('http') 
                          ? widget.item.images[_currentImageIndex] 
                          : 'http://188.245.212.240${widget.item.images[_currentImageIndex]}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                    ),
                  ),
                  // Thumbnails
                  if (widget.item.images.length > 1)
                    Container(
                      height: 80,
                      padding: const EdgeInsets.all(8),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.item.images.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _currentImageIndex = index;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 80,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _currentImageIndex == index ? const Color(0xFF2563EB) : Colors.transparent,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image.network(
                                widget.item.images[index].startsWith('http') 
                                    ? widget.item.images[index] 
                                    : 'http://188.245.212.240${widget.item.images[index]}',
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
              
            // Details Body
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.item.price} ${widget.item.currency}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Detail Tags
                  Row(
                    children: [
                      Icon(Icons.sell_outlined, color: Colors.grey.shade600, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'অবস্থা: ${widget.item.condition}',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  const Text(
                    'বিস্তারিত বিবরণ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.item.description,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700, height: 1.5),
                  ),
                  
                  const SizedBox(height: 32),
                  const Text(
                    'রিভিউ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ReviewsSection(contentType: 'market_item', contentId: widget.item.id),
                ],
              ),
            ),
          ],
        ),
      ),
      
      // Sticky Bottom Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Add to favorites
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(Icons.favorite_border, color: Colors.black87),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: ChatInitiatorButton(
                  targetUserId: widget.item.ownerId ?? 1,
                  title: widget.item.title,
                  initialMessage: 'আমি এই বিজ্ঞাপনটি সম্পর্কে জানতে চাচ্ছি: ${widget.item.title}',
                  relatedObjectType: 'market_item',
                  relatedObjectId: widget.item.id,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

