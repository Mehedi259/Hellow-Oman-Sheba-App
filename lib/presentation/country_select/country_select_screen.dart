import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CountrySelectScreen extends StatelessWidget {
  const CountrySelectScreen({super.key});

  Future<void> _selectCountry(BuildContext context, String countryCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_country', countryCode);
    
    if (context.mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.language_rounded, size: 80, color: Color(0xFF7C3AED)),
              const SizedBox(height: 24),
              const Text(
                'আপনার অবস্থান নির্বাচন করুন',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'আপনি কোন দেশের তথ্য দেখতে চান তা নির্বাচন করুন।',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _buildCountryCard(
                context,
                title: 'ওমান',
                subtitle: 'Oman',
                icon: Icons.location_on_rounded,
                countryCode: 'oman',
              ),
              const SizedBox(height: 16),
              _buildCountryCard(
                context,
                title: 'সৌদি আরব',
                subtitle: 'Saudi Arabia',
                icon: Icons.location_on_rounded,
                countryCode: 'saudi',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountryCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required String countryCode}) {
    return InkWell(
      onTap: () => _selectCountry(context, countryCode),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF7C3AED), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFCBD5E1), size: 20),
          ],
        ),
      ),
    );
  }
}
