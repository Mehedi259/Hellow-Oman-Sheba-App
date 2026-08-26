import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (!await launchUrl(launchUri)) {
      debugPrint('Could not launch $phoneNumber');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('জরুরী নম্বরসমূহ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroHeader(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildMainEmergencyBanner(),
                  const SizedBox(height: 16),
                  _buildContactList(),
                  const SizedBox(height: 24),
                  _buildImportantTips(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFDC2626), Color(0xFFB91C1C), Color(0xFFBE123C)], // red-600 to red-700 to rose-700
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 36),
              SizedBox(width: 12),
              Text(
                'জরুরী নম্বরসমূহ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'ওমানে জরুরী পরিস্থিতিতে সাহায্যের জন্য নিচের নম্বরগুলো ব্যবহার করুন। সকল নম্বর ২৪/৭ সক্রিয়।',
            style: TextStyle(
              color: Color(0xFFFECACA), // red-200
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainEmergencyBanner() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2), // red-50
        border: Border.all(color: const Color(0xFFFCA5A5), width: 2), // red-300
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFDC2626), // red-600
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.phone, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'জরুরী কল: 9999',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF991B1B), // red-800
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'পুলিশ, অ্যাম্বুলেন্স, ফায়ার সার্ভিস — একটি নম্বরেই সব সেবা',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFDC2626), // red-600
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _makePhoneCall('9999'),
              icon: const Icon(Icons.phone, size: 20, color: Colors.white),
              label: const Text(
                'এখনই কল করুন',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626), // red-600
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactList() {
    final contacts = [
      {
        'name': 'রয়্যাল ওমান পুলিশ',
        'nameEn': 'Royal Oman Police',
        'phone': '9999',
        'icon': Icons.shield_outlined,
        'color': const Color(0xFF2563EB), // blue-600
        'desc': 'জরুরী পুলিশ সেবা, দুর্ঘটনা, চুরি, নিরাপত্তা সংক্রান্ত সমস্যা',
      },
      {
        'name': 'অ্যাম্বুলেন্স সেবা',
        'nameEn': 'Ambulance Service',
        'phone': '9999',
        'icon': Icons.favorite_border,
        'color': const Color(0xFFDC2626), // red-600
        'desc': 'জরুরী চিকিৎসা সেবা, অ্যাম্বুলেন্স',
      },
      {
        'name': 'ফায়ার সার্ভিস',
        'nameEn': 'Fire Service (Civil Defence)',
        'phone': '9999',
        'icon': Icons.local_fire_department_outlined,
        'color': const Color(0xFFEA580C), // orange-600
        'desc': 'আগুন সংক্রান্ত জরুরী সেবা',
      },
      {
        'name': 'বাংলাদেশ দূতাবাস, মাস্কাট',
        'nameEn': 'Bangladesh Embassy, Muscat',
        'phone': '+968 2469 8989',
        'altPhone': '+968 2469 7373',
        'icon': Icons.business_outlined,
        'color': const Color(0xFF15803D), // green-700
        'desc': 'পাসপোর্ট, ভিসা, কনসুলার সেবা, জরুরী সহায়তা',
      },
      {
        'name': 'কোস্ট গার্ড',
        'nameEn': 'Coast Guard',
        'phone': '1555',
        'icon': Icons.anchor,
        'color': const Color(0xFF0E7490), // cyan-700
        'desc': 'সমুদ্রে জরুরী উদ্ধার সেবা',
      },
      {
        'name': 'বিমানবন্দর তথ্য',
        'nameEn': 'Muscat International Airport',
        'phone': '+968 2435 3333',
        'icon': Icons.flight_takeoff,
        'color': const Color(0xFF4F46E5), // indigo-600
        'desc': 'ফ্লাইট তথ্য, বিমানবন্দর সেবা',
      },
    ];

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: contacts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: contact['color'] as Color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(contact['icon'] as IconData, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact['name'] as String,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          contact['nameEn'] as String,
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                contact['desc'] as String,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _makePhoneCall(contact['phone'] as String),
                  icon: const Icon(Icons.phone_outlined, size: 18),
                  label: Text(
                    contact['phone'] as String,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              if (contact.containsKey('altPhone')) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _makePhoneCall(contact['altPhone'] as String),
                    icon: const Icon(Icons.phone_outlined, size: 18),
                    label: Text(
                      contact['altPhone'] as String,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildImportantTips() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB), // amber-50
        border: Border.all(color: const Color(0xFFFDE68A)), // amber-200
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 24), // amber-600
              SizedBox(width: 8),
              Text(
                'জরুরী পরিস্থিতিতে মনে রাখুন',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildBulletPoint('শান্ত থাকুন এবং পরিস্থিতি মূল্যায়ন করুন'),
          const SizedBox(height: 8),
          _buildBulletPoint('৯৯৯৯ নম্বরে কল করে আপনার অবস্থান জানান'),
          const SizedBox(height: 8),
          _buildBulletPoint('আপনার পাসপোর্ট এবং আইডি কার্ড সবসময় সাথে রাখুন'),
          const SizedBox(height: 8),
          _buildBulletPoint('বাংলাদেশ দূতাবাসের নম্বর সংরক্ষণ করে রাখুন'),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(
            color: Color(0xFFD97706), // amber-600
            fontWeight: FontWeight.bold,
            fontSize: 20,
            height: 1.2,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
