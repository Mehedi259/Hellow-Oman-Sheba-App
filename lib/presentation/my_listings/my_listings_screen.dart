import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyListingsScreen extends ConsumerStatefulWidget {
  const MyListingsScreen({super.key});

  @override
  ConsumerState<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends ConsumerState<MyListingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          'লিস্টিং ও কার্যক্রম',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFF0056D2),
          unselectedLabelColor: const Color(0xFF94A3B8),
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          indicatorColor: const Color(0xFF0056D2),
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          tabAlignment: TabAlignment.center,
          tabs: const [
            Tab(text: 'আমার পোস্ট'),
            Tab(text: 'পছন্দের তালিকা'),
            Tab(text: 'আমার কমেন্ট'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _EmptyStateView(
            icon: Icons.post_add_rounded,
            title: 'আপনার কোনো পোস্ট নেই',
            subtitle: 'নতুন পোস্ট তৈরি করতে নিচের + বাটনে ক্লিক করুন',
          ),
          _EmptyStateView(
            icon: Icons.favorite_border_rounded,
            title: 'পছন্দের তালিকা খালি',
            subtitle: 'কোনো পোস্টে লাইক দিলে সেটি এখানে দেখা যাবে',
          ),
          _EmptyStateView(
            icon: Icons.comment_outlined,
            title: 'কোনো কমেন্ট নেই',
            subtitle: 'কমিউনিটি পোস্টে আপনার করা কমেন্টগুলো এখানে দেখা যাবে',
          ),
        ],
      ),
    );
  }
}

class _EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyStateView({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0056D2).withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: const Color(0xFF0056D2).withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 80), // To avoid covering by bottom nav bar
          ],
        ),
      ),
    );
  }
}
