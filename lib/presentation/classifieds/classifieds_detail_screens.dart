import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('চাকরির বিস্তারিত', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [FavoriteButton(contentType: 'job', contentId: job.id)],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (job.images.isNotEmpty)
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                ),
                child: Image.network(
                  job.images[0].startsWith('http') ? job.images[0] : 'http://188.245.212.240${job.images[0]}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 50)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.business, size: 20, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          job.company,
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 20, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          job.location,
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0EA5E9).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF0EA5E9)),
                              const SizedBox(height: 4),
                              Text(job.salary, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0EA5E9))),
                              const Text('বেতন', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.work_outline, color: Color(0xFF6366F1)),
                              const SizedBox(height: 4),
                              Text(job.jobType, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                              const Text('ধরণ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text('বিস্তারিত বিবরণ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                    job.description,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  const Text('রিভিউ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ReviewsSection(contentType: 'job', contentId: job.id),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  await ref.read(classifiedsRepositoryProvider).applyForJob(job.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Successfully applied for job!'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('আবেদন করুন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }
}

class PropertyDetailScreen extends StatelessWidget {
  final Property property;
  const PropertyDetailScreen({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(property.title), actions: [FavoriteButton(contentType: 'property', contentId: property.id)]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (property.imageUrl != null)
              Image.network(
                property.imageUrl!.startsWith('http') ? property.imageUrl! : 'http://188.245.212.240${property.imageUrl}',
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(height: 250, color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey, size: 50)),
              ),
            const SizedBox(height: 16),
            Text(property.title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('\$${property.price}', style: const TextStyle(fontSize: 24, color: Colors.teal, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('${property.location} • ${property.type}'),
            const SizedBox(height: 24),
            const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(property.description),
            const SizedBox(height: 24),
            const Text('Contact Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(property.contactInfo),
            const SizedBox(height: 32),
            ReviewsSection(contentType: 'property', contentId: property.id),
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
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Contact logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'যোগাযোগ করুন',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

