import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('আমাদের সম্পর্কে', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Image/Logo area
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.handshake_rounded, size: 50, color: Color(0xFF2563EB)),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'হ্যালো ওমান সেবা',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ওমান প্রবাসীদের একটি পূর্ণাঙ্গ ডিজিটাল প্ল্যাটফর্ম',
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'আমাদের সম্পর্কে',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '\'হ্যালো ওমান সেবা\' হলো ওমানে বসবাসরত প্রবাসী এবং দর্শনার্থীদের জন্য একটি সম্পূর্ণ কমিউনিটি প্ল্যাটফর্ম। আমাদের মূল লক্ষ্য হলো ওমান প্রবাসীদের দৈনন্দিন জীবনকে আরও সহজ, সুন্দর এবং তথ্যবহুল করে তোলা।',
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.6),
                  ),
                  
                  const SizedBox(height: 32),
                  const Text(
                    'আমাদের সেবাসমূহ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildFeatureCard(
                    icon: Icons.work_outline_rounded,
                    color: const Color(0xFF2563EB),
                    title: 'চাকরির খবর ও নিয়োগ',
                    description: 'ওমানে আপনার স্বপ্নের চাকরি খুঁজে পেতে অথবা সঠিক কর্মী নিয়োগ দিতে আমাদের জব পোর্টাল ব্যবহার করুন।',
                  ),
                  _buildFeatureCard(
                    icon: Icons.storefront_rounded,
                    color: const Color(0xFF10B981),
                    title: 'ক্লাসিফায়েড (বেচাকেনা)',
                    description: 'নতুন বা পুরাতন পণ্য, গাড়ি, ইলেকট্রনিক্স কেনাবেচা কিংবা বাসা ভাড়ার বিজ্ঞাপন দিন খুব সহজেই।',
                  ),
                  _buildFeatureCard(
                    icon: Icons.support_agent_rounded,
                    color: const Color(0xFFF59E0B),
                    title: 'প্রয়োজনীয় সার্ভিস',
                    description: 'ওমানে প্রয়োজনীয় বিভিন্ন সার্ভিস যেমন - টেকনিশিয়ান, ক্লিনার, ড্রাইভার বা অন্যান্য প্রফেশনালদের দ্রুত খুঁজে পান।',
                  ),
                  _buildFeatureCard(
                    icon: Icons.forum_rounded,
                    color: const Color(0xFF8B5CF6),
                    title: 'কমিউনিটি ফোরাম',
                    description: 'আপনার প্রশ্ন, অভিজ্ঞতা বা প্রয়োজনীয় তথ্য শেয়ার করুন ওমানে বসবাসরত অন্যান্য প্রবাসীদের সাথে।',
                  ),
                  _buildFeatureCard(
                    icon: Icons.newspaper_rounded,
                    color: const Color(0xFFEF4444),
                    title: 'তাজা খবর ও আপডেট',
                    description: 'ওমানের গুরুত্বপূর্ণ খবর, ভিসা সংক্রান্ত আপডেট এবং অন্যান্য প্রয়োজনীয় তথ্য সবার আগে জেনে নিন।',
                  ),
                  
                  const SizedBox(height: 32),
                  const Text(
                    'আমাদের উদ্দেশ্য',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.1)),
                    ),
                    child: Text(
                      'আমরা বিশ্বাস করি সঠিক তথ্য এবং যোগাযোগের মাধ্যম প্রবাস জীবনে একটি বড় ভূমিকা রাখে। \'হ্যালো ওমান সেবা\' অ্যাপের মাধ্যমে আমরা এমন একটি নির্ভরযোগ্য মাধ্যম তৈরি করতে চাই, যেখানে প্রবাসীরা একে অপরের পাশে দাঁড়াতে পারে এবং প্রয়োজনীয় যেকোনো সেবা এক ক্লিকেই পেতে পারে।',
                      style: TextStyle(fontSize: 15, color: Colors.grey.shade800, height: 1.6),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        const Icon(Icons.favorite_rounded, color: Colors.red, size: 30),
                        const SizedBox(height: 12),
                        const Text(
                          'হ্যালো ওমান সেবার সাথে যুক্ত থাকার জন্য ধন্যবাদ!',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ভার্সন ১.০.০',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({required IconData icon, required Color color, required String title, required String description}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
