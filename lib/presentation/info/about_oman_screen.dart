import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui'; // for ImageFilter

class AboutOmanScreen extends StatelessWidget {
  const AboutOmanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF115E59), Color(0xFF047857), Color(0xFF134E4A)], // teal-800 to emerald-700 to teal-900
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Button
                      InkWell(
                        onTap: () => context.pop(),
                        borderRadius: BorderRadius.circular(24),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.arrow_back, color: Colors.white, size: 16),
                                  SizedBox(width: 8),
                                  Text('হোম পেজে ফিরে যান', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Flag Box
                      Center(
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                  ),
                                  child: const Text('🇴🇲', style: TextStyle(fontSize: 64, height: 1)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Titles
                            const Text(
                              'সালতানাত ওমান',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sultanate of Oman',
                              style: TextStyle(
                                color: Colors.teal.shade100,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'মধ্যপ্রাচ্যের এক শান্তিময় এবং প্রাচীন ঐতিহ্যের দেশ, যা তার অনন্য সংস্কৃতি, আতিথেয়তা এবং প্রবাসী শ্রমিকদের জন্য নিরাপদ কর্মপরিবেশের জন্য পরিচিত।',
                              style: TextStyle(
                                color: Colors.teal.shade50,
                                fontSize: 16,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Body Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 2. Introduction Card
                  _buildCard(
                    title: 'ওমান পরিচিতি',
                    icon: Icons.info_outline,
                    iconColor: Colors.teal.shade600,
                    topBorderColor: Colors.teal.shade600,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade700, height: 1.6),
                            children: const [
                              TextSpan(text: 'ওমান (আরবি: عُمان‎), সরকারি নাম '),
                              TextSpan(text: 'সালতানাত অব ওমান', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                              TextSpan(text: ' (سلطنة عُمان), মধ্যপ্রাচ্যের আরব উপদ্বীপের দক্ষিণ-পূর্ব উপকূলে অবস্থিত একটি স্বাধীন রাষ্ট্র। এটি আরব বিশ্বের প্রাচীনতম স্বাধীন রাষ্ট্রগুলির মধ্যে অন্যতম। ওমানের রাজধানী এবং সর্ববৃহৎ শহর হলো '),
                              TextSpan(text: 'মাস্কাট', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                              TextSpan(text: ' (Muscat)।'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'ওমান একটি পরম রাজতান্ত্রিক দেশ। বর্তমান সুলতান হাইথাম বিন তারিক আল সাইদ দেশের প্রধান। ওমানের অর্থনীতি মূলত তেল এবং গ্যাস রপ্তানির উপর নির্ভরশীল হলেও বর্তমানে পর্যটন ও মৎস্য শিল্পের ব্যাপক উন্নতি হচ্ছে।',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade700, height: 1.6),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 3. Geography & Climate
                  _buildCard(
                    title: 'ভৌগোলিক অবস্থান ও জলবায়ু',
                    icon: Icons.map_outlined,
                    iconColor: Colors.blue.shade600,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ওমানের উত্তর-পশ্চিমে সংযুক্ত আরব আমিরাত (UAE), পশ্চিমে সৌদি আরব এবং দক্ষিণ-পশ্চিমে ইয়েমেন অবস্থিত। এর দক্ষিণ ও পূর্ব দিকে আরব সাগর এবং উত্তর-পূর্বে ওমান উপসাগর রয়েছে।',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade700, height: 1.6),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 16),
                        _buildHighlightedBox(
                          title: 'ভৌগোলিক বৈচিত্র্য',
                          description: 'ওমানে রয়েছে বিস্তীর্ণ মরুভূমি, সুউচ্চ পর্বতমালা (যেমন জাবাল শামস) এবং দীর্ঘ সমুদ্র সৈকত। ওয়াদি (শুষ্ক নদী উপত্যকা) ওমানের প্রকৃতির এক অন্যতম আকর্ষণ।',
                          bgColor: Colors.blue.shade50,
                          borderColor: Colors.blue.shade100,
                          titleColor: Colors.blue.shade800,
                          descColor: Colors.blue.shade900.withValues(alpha: 0.8),
                        ),
                        const SizedBox(height: 12),
                        _buildHighlightedBox(
                          title: 'জলবায়ু',
                          description: 'ওমানের জলবায়ু সাধারণত শুষ্ক ও উষ্ণ। গ্রীষ্মকালে তাপমাত্রা ৫০°C পর্যন্ত পৌঁছাতে পারে। তবে শীতকালে (নভেম্বর থেকে মার্চ) আবহাওয়া খুবই মনোরম থাকে।',
                          bgColor: Colors.orange.shade50,
                          borderColor: Colors.orange.shade100,
                          titleColor: Colors.orange.shade800,
                          descColor: Colors.orange.shade900.withValues(alpha: 0.8),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 4. History & Culture
                  _buildCard(
                    title: 'ইতিহাস ও সংস্কৃতি',
                    icon: Icons.account_balance_outlined,
                    iconColor: Colors.purple.shade600,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ওমানের ইতিহাস হাজার বছরের পুরনো। একসময় ওমানি সাম্রাজ্য পূর্ব আফ্রিকা পর্যন্ত বিস্তৃত ছিল। ওমানিরা তাদের সমৃদ্ধ ঐতিহ্য, প্রাচীন দুর্গ (Forts) এবং আতিথেয়তার জন্য বিশ্বজুড়ে পরিচিত।',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade700, height: 1.6),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 16),
                        _buildListTile(
                          icon: Icons.menu_book,
                          iconColor: Colors.purple.shade700,
                          iconBgColor: Colors.purple.shade100,
                          title: 'পোশাক',
                          description: 'পুরুষরা ঐতিহ্যবাহী ‘দিশদাশা’ বা ‘কান্দুরা’ পরিধান করে এবং মাথায় ‘কুমা’ (টুপি) বা ‘মুসার’ (পাগড়ি) বাঁধে। মহিলারা বোরকা বা আবায়া পরিধান করেন।',
                        ),
                        const SizedBox(height: 12),
                        _buildListTile(
                          icon: Icons.restaurant_menu,
                          iconColor: Colors.purple.shade700,
                          iconBgColor: Colors.purple.shade100,
                          title: 'খাদ্যাভ্যাস',
                          description: 'শুয়া (Shuwa - মাটির নিচে রান্না করা বিশেষ মাংস), মাজবুস (Machboos), এবং কাহওয়া (আরবীয় কফি) ওমানি সংস্কৃতির অবিচ্ছেদ্য অংশ।',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 5. Expatriates & Employment
                  _buildCard(
                    title: 'প্রবাসী বাংলাদেশী ও কর্মসংস্থান',
                    icon: Icons.work_outline,
                    iconColor: Colors.orange.shade600,
                    topBorderColor: Colors.orange.shade500,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ওমানে বিপুল সংখ্যক প্রবাসী কাজ করেন, যার মধ্যে বাংলাদেশীদের সংখ্যা অন্যতম। মূলত নির্মাণ শিল্প, কৃষি, মৎস্য শিকার, সুপারমার্কেট, এবং ক্লিনিং সেক্টরে বাংলাদেশীরা ব্যাপকভাবে কাজ করছেন।',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade700, height: 1.6),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            border: Border.all(color: Colors.orange.shade200),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.people_outline, color: Colors.orange.shade800, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'প্রবাসীদের জন্য গুরুত্বপূর্ণ নিয়মাবলী',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.orange.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildBulletPoint('ভিসা ও রেসিডেন্স কার্ড:', 'ওমানে কাজ করার জন্য বৈধ ওয়ার্ক ভিসা এবং রেসিডেন্স কার্ড (পাতাকা) থাকা বাধ্যতামূলক।'),
                              _buildBulletPoint('স্পন্সরশিপ (Kafeel):', 'ওমানের নিয়ম অনুযায়ী বিদেশি কর্মীদের একজন স্থানীয় স্পন্সর বা কফিলের অধীনে কাজ করতে হয়।'),
                              _buildBulletPoint('আইনশৃঙ্খলা:', 'ওমানের আইন অত্যন্ত কড়া। ট্রাফিক নিয়ম ভঙ্গ বা কোনো অপরাধমূলক কাজের জন্য কঠোর শাস্তির বিধান রয়েছে।'),
                              _buildBulletPoint('সংস্কৃতির প্রতি সম্মান:', 'রমজান মাসে জনসম্মুখে পানাহার করা থেকে বিরত থাকা এবং শালীন পোশাক পরিধান করা আইনের অংশ।'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),

                  // 6. Quick Facts
                  _buildCard(
                    title: 'এক নজরে ওমান',
                    icon: Icons.book_outlined,
                    iconColor: Colors.teal.shade600,
                    bgColor: Colors.teal.shade50.withValues(alpha: 0.5),
                    child: Column(
                      children: [
                        _buildFactRow('রাজধানী', 'মাস্কাট (Muscat)'),
                        _buildFactRow('রাষ্ট্রভাষা', 'আরবি (Arabic)'),
                        _buildFactRow('মুদ্রা', 'ওমানি রিয়াল (OMR)'),
                        _buildFactRow('রাষ্ট্রধর্ম', 'ইসলাম (ইবাদি মতবাদ)'),
                        _buildFactRow('প্রধান শহরসমূহ', 'মাস্কাট (Muscat), সালালাহ (Salalah), সোহার (Sohar), নিজওয়া (Nizwa), সুর (Sur), সীব (Seeb), খাসাব (Khasab), ইবরি (Ibri), রুস্তাক (Rustaq)', isLast: true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 7. Useful Links
                  _buildCard(
                    title: 'প্রয়োজনীয় লিংক',
                    child: Column(
                      children: [
                        _buildLinkTile(
                          context: context,
                          icon: Icons.location_on_outlined,
                          iconColor: Colors.blue.shade600,
                          iconBgColor: Colors.blue.shade100,
                          title: 'বাংলাদেশ দূতাবাস',
                          subtitle: 'যোগাযোগের বিস্তারিত তথ্য',
                          route: '/embassy',
                        ),
                        const Divider(height: 1, indent: 64),
                        _buildLinkTile(
                          context: context,
                          icon: Icons.phone_outlined,
                          iconColor: Colors.red.shade600,
                          iconBgColor: Colors.red.shade100,
                          title: 'জরুরী যোগাযোগ',
                          subtitle: 'পুলিশ, এম্বুলেন্স ও হাসপাতাল',
                          route: '/emergency',
                        ),
                        const Divider(height: 1, indent: 64),
                        _buildLinkTile(
                          context: context,
                          icon: Icons.work_outline,
                          iconColor: Colors.orange.shade600,
                          iconBgColor: Colors.orange.shade100,
                          title: 'কর্মসংস্থান',
                          subtitle: 'ওমানে নতুন চাকরির খবর',
                          route: '/classifieds?tab=jobs',
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    IconData? icon,
    Color? iconColor,
    Color? topBorderColor,
    Color bgColor = Colors.white,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias, // Important for the colored top border
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Colored Border implementation without throwing non-uniform border radius exception
          if (topBorderColor != null)
            Container(
              height: 4,
              width: double.infinity,
              color: topBorderColor,
            ),
          if (title.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50.withValues(alpha: 0.8),
                border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: iconColor, size: 24),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedBox({
    required String title,
    required String description,
    required Color bgColor,
    required Color borderColor,
    required Color titleColor,
    required Color descColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: titleColor, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(color: descColor, fontSize: 14, height: 1.5),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(
              style: TextStyle(fontSize: 15, color: Colors.grey.shade800, height: 1.5),
              children: [
                TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                TextSpan(text: description),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: Colors.orange.shade800),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                style: TextStyle(fontSize: 15, color: Colors.orange.shade900.withValues(alpha: 0.9), height: 1.5),
                children: [
                  TextSpan(text: '$title ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactRow(String label, String value, {bool isLast = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.teal.shade100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.teal.shade700, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildLinkTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return InkWell(
      onTap: () => context.push(route),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
