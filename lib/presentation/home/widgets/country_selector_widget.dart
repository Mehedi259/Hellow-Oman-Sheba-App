import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:hellow_oman_sheba_app/core/utils/router_utils.dart';

class CountrySelectorWidget extends StatefulWidget {
  const CountrySelectorWidget({super.key});

  @override
  State<CountrySelectorWidget> createState() => _CountrySelectorWidgetState();
}

class _CountrySelectorWidgetState extends State<CountrySelectorWidget> {
  String _currentCountry = 'oman';

  @override
  void initState() {
    super.initState();
    _loadCountry();
  }

  Future<void> _loadCountry() async {
    final prefs = await SharedPreferences.getInstance();
    final country = prefs.getString('selected_country');
    if (mounted && country != null) {
      setState(() {
        _currentCountry = country.toLowerCase();
      });
    }
  }

  String get _countryName {
    switch (_currentCountry) {
      case 'bangladesh':
        return 'Bangladesh';
      case 'uae':
        return 'UAE';
      case 'oman':
      default:
        return 'Oman';
    }
  }

  String get _flagUrl {
    switch (_currentCountry) {
      case 'bangladesh':
        return 'https://flagcdn.com/w40/bd.png';
      case 'uae':
        return 'https://flagcdn.com/w40/ae.png';
      case 'oman':
      default:
        return 'https://flagcdn.com/w40/om.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await context.safePushRoute('/country-select');
        _loadCountry();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Image.network(
                _flagUrl,
                width: 22,
                height: 15,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.flag, size: 16, color: Colors.black54),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              _countryName,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B), size: 15),
          ],
        ),
      ),
    );
  }
}
