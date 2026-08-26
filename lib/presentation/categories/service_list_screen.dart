import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/classifieds_models.dart';
import '../classifieds/classifieds_provider.dart';
import '../classifieds/classifieds_detail_screens.dart';
import 'package:url_launcher/url_launcher.dart';

const Map<String, Map<String, String>> serviceCategoriesData = {
  'ambulance': {'nameBn': 'অ্যাম্বুলেন্স', 'icon': '🚑', 'description': 'জরুরী অ্যাম্বুলেন্স সেবা এবং মেডিকেল ট্রান্সপোর্ট।', 'backendName': 'Ambulance'},
  'doctors': {'nameBn': 'বিশেষজ্ঞ ডাক্তার', 'icon': '👨‍⚕️', 'description': 'বিশেষজ্ঞ চিকিৎসক, পরামর্শ এবং চেকআপ সেবা।', 'backendName': 'Specialist Doctor'},
  'hospitals': {'nameBn': 'হাসপাতাল', 'icon': '🏥', 'description': 'হাসপাতাল, ক্লিনিক এবং মেডিকেল সেন্টার।', 'backendName': 'Hospital'},
  'maktab': {'nameBn': 'মক্তব সানাদ', 'icon': '📜', 'description': 'মক্তব সার্টিফিকেট, শিক্ষা সনদ এবং সংশ্লিষ্ট সেবা।', 'backendName': 'Maktab Sanad'},
  'travel-agency': {'nameBn': 'ট্রাভেল এজেন্সি', 'icon': '✈️', 'description': 'ফ্লাইট বুকিং, হোটেল রিজার্ভেশন এবং ট্যুর প্যাকেজ।', 'backendName': 'Travel Agency'},
  'tourist-places': {'nameBn': 'দর্শনীয় স্থান', 'icon': '🗿', 'description': 'ওমানের দর্শনীয় স্থান, ঐতিহাসিক স্থান এবং পর্যটন।', 'backendName': 'Tourist Place'},
  'lawyers': {'nameBn': 'আইনজীবী', 'icon': '⚖️', 'description': 'আইনজীবী, আইনগত পরামর্শ এবং লেবার কোর্ট সেবা।', 'backendName': 'Lawyer'},
  'hotels': {'nameBn': 'হোটেল', 'icon': '🏨', 'description': 'হোটেল, রেস্ট হাউস এবং আবাসন সেবা।', 'backendName': 'Hotel'},
  'money-exchange': {'nameBn': 'মানি এক্সচেঞ্জ', 'icon': '💱', 'description': 'মানি এক্সচেঞ্জ, রেমিট্যান্স এবং ব্যাংকিং সেবা।', 'backendName': 'Money Exchange'},
  'police': {'nameBn': 'পুলিশ স্টেশন', 'icon': '👮', 'description': 'পুলিশ স্টেশন, জরুরী সেবা এবং আইন শৃঙ্খলা।', 'backendName': 'Police Station'},
};

class ServiceListScreen extends ConsumerWidget {
  final String slug;
  
  const ServiceListScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryData = serviceCategoriesData[slug];
    if (categoryData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Not Found')),
        body: const Center(child: Text('Category not found')),
      );
    }

    final backendName = categoryData['backendName']!;
    final state = ref.watch(servicesByCategoryProvider(backendName));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: Colors.purple[700],
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple[600]!, Colors.purple[700]!, Colors.indigo[700]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 40.0),
                    child: Row(
                      children: [
                        Text(categoryData['icon']!, style: const TextStyle(fontSize: 50)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                categoryData['nameBn']!,
                                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                categoryData['description']!,
                                style: TextStyle(color: Colors.purple[100], fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: state.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(child: Text('Error loading services: $err')),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.inbox, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'এই ক্যাটাগরিতে এখনো কোন সেবা যোগ করা হয়নি।',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${items.length}টি সেবা প্রদানকারী',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ...items.map((item) => _buildServiceCard(context, item)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, Service item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      elevation: 2,
      shadowColor: Colors.grey.shade100,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ServiceDetailScreen(service: item)),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Text(serviceCategoriesData[slug]!['icon']!, style: const TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (item.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.category_outlined, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (item.contactInfo.isNotEmpty)
                    TextButton.icon(
                      onPressed: () async {
                        final url = Uri.parse('tel:${item.contactInfo}');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                      icon: const Icon(Icons.phone, size: 16),
                      label: const Text('যোগাযোগ'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
