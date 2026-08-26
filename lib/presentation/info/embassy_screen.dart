import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class EmbassyScreen extends StatelessWidget {
  const EmbassyScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: Colors.green[700],
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal[700]!, Colors.green[600]!, Colors.green[800]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 40.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: const Text('🇧🇩', style: TextStyle(fontSize: 40)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified, color: Colors.white, size: 14),
                                    SizedBox(width: 4),
                                    Text('অফিসিয়াল তথ্য', style: TextStyle(color: Colors.white, fontSize: 12)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'বাংলাদেশ দূতাবাস, মাস্কাট',
                                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const Text(
                                "Embassy of the People's Republic of Bangladesh",
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                              const Text(
                                'Sultanate of Oman',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(Icons.business, 'দূতাবাস সম্পর্কে বিস্তারিত', Colors.green),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ওমানে অবস্থিত বাংলাদেশ দূতাবাস প্রবাসী বাংলাদেশীদের জন্য একটি অত্যন্ত গুরুত্বপূর্ণ নির্ভরতার স্থান। এটি বাংলাদেশ ও ওমানের মধ্যে দ্বিপাক্ষিক সম্পর্ক উন্নয়ন, বাণিজ্য সম্প্রসারণ এবং সাংস্কৃতিক বিনিময়ে কাজ করে। দূতাবাসে প্রবাসীদের জন্য পাসপোর্ট নবায়ন, নতুন ই-পাসপোর্ট ইস্যু, ভিসা প্রদান, এবং ওয়েজ আর্নার্স কল্যাণ বোর্ডের মেম্বারশিপ সংক্রান্ত সেবা প্রদান করা হয়।',
                            style: TextStyle(fontSize: 14, height: 1.5),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'এছাড়াও, প্রবাসী শ্রমিকদের যেকোনো আইনি সহায়তা, কর্মক্ষেত্রে সমস্যা সমাধান, এবং কল্যাণমূলক কার্যক্রমে শ্রম উইং (Labour Wing) সার্বক্ষণিক সহযোগিতা করে থাকে। যেকোনো কনস্যুলার সেবার জন্য সরাসরি দূতাবাসে আসার আগে অনলাইনে অ্যাপয়েন্টমেন্ট নেওয়া বা ফোনে যোগাযোগ করে নেওয়া বাঞ্ছনীয়।',
                            style: TextStyle(fontSize: 14, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Quick Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickActionItem('কল করুন', Icons.phone, Colors.green, 'tel:+96824698660'),
                      _buildQuickActionItem('ম্যাপ দেখুন', Icons.location_on, Colors.blue, 'https://www.google.com/maps/search/?api=1&query=Bangladesh+Embassy+Muscat+Oman'),
                      _buildQuickActionItem('ইমেইল', Icons.email, Colors.purple, 'mailto:mission.muscat@mofa.gov.bd'),
                      _buildQuickActionItem('ওয়েবসাইট', Icons.language, Colors.orange, 'https://muscat.mofa.gov.bd'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle(Icons.phone_in_talk, 'জরুরী যোগাযোগ নম্বরসমূহ', Colors.green),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        _buildContactItem('সাধারণ তথ্য ও অনুসন্ধান', 'যেকোনো সাধারণ তথ্যের জন্য', '+968 2469 8660', Icons.info_outline, Colors.blue),
                        const Divider(height: 1),
                        _buildContactItem('পাসপোর্ট ও ভিসা সংক্রান্ত', 'নতুন পাসপোর্ট, নবায়ন বা ভিসার তথ্য', '+968 2469 8098\n+968 9527 9792 (মোবাইল)', Icons.description, Colors.blue),
                        const Divider(height: 1),
                        _buildContactItem('শ্রম শাখা (Labour Wing)', 'শ্রমিকদের যেকোনো সমস্যার জন্য', '+968 2460 3514\n+968 2469 8440', Icons.people, Colors.orange),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.orange[800]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('গুরুত্বপূর্ণ তথ্য', style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                'দূতাবাসে আসার আগে অবশ্যই প্রয়োজনীয় কাগজপত্র গুছিয়ে নিয়ে আসুন। পাসপোর্ট নবায়ন বা যেকোনো কনস্যুলার সেবার জন্য অনলাইনে অ্যাপয়েন্টমেন্ট নেওয়া বাধ্যতামূলক হতে পারে।',
                                style: TextStyle(color: Colors.orange[900], fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle(Icons.location_on, 'ঠিকানা', Colors.blue),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Villa 4207, Way 3052', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Shatti Al Qurum'),
                          Text('Muscat, Sultanate of Oman'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildSectionTitle(Icons.access_time, 'অফিস সময়সূচী', Colors.purple),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                              SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('রবিবার - বৃহস্পতিবার', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text('সকাল ৮:০০ - বিকাল ৪:০০', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red[100]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.red[700], size: 16),
                                const SizedBox(width: 8),
                                Text('শুক্রবার ও শনিবার বন্ধ থাকে', style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildSectionTitle(Icons.language, 'অনলাইন যোগাযোগ', Colors.orange),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(backgroundColor: Colors.purple[100], child: Icon(Icons.email, color: Colors.purple[600], size: 20)),
                          title: const Text('অফিসিয়াল ইমেইল', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          subtitle: const Text('mission.muscat@mofa.gov.bd', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          onTap: () => _launchUrl('mailto:mission.muscat@mofa.gov.bd'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: CircleAvatar(backgroundColor: Colors.orange[100], child: Icon(Icons.open_in_new, color: Colors.orange[600], size: 20)),
                          title: const Text('অফিসিয়াল ওয়েবসাইট', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          subtitle: const Text('muscat.mofa.gov.bd', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          onTap: () => _launchUrl('https://muscat.mofa.gov.bd'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildQuickActionItem(String title, IconData icon, Color color, String url) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _launchUrl(url),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(String title, String subtitle, String phoneNumbers, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 28.0),
            child: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ),
          const SizedBox(height: 12),
          ...phoneNumbers.split('\n').map((phone) {
            String cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 28.0),
              child: ElevatedButton.icon(
                onPressed: () => _launchUrl('tel:$cleanPhone'),
                icon: const Icon(Icons.phone, size: 16),
                label: Text(phone),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green[700],
                  elevation: 0,
                  side: BorderSide(color: Colors.green[200]!),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  alignment: Alignment.centerLeft,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
