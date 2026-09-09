import sys

with open('lib/presentation/classifieds/classifieds_screen.dart', 'r') as f:
    content = f.read()

# Add import
if 'cached_network_image.dart' not in content:
    content = content.replace(
        "import 'package:flutter/material.dart';",
        "import 'package:flutter/material.dart';\nimport 'package:cached_network_image/cached_network_image.dart';"
    )

# Get Service Icon function
service_icon_func = """
  Widget _getServiceIcon(String category) {
    final cat = category.toUpperCase().replaceAll(' ', '_');
    if (cat.contains('ELECTRICAL')) return Icon(Icons.electrical_services, size: 32, color: Colors.blue.shade600);
    if (cat.contains('MAKTAB') || cat.contains('SANAD')) return Icon(Icons.account_balance, size: 32, color: Colors.blue.shade600);
    if (cat.contains('HOSPITAL') || cat.contains('MEDICAL')) return Icon(Icons.local_hospital, size: 32, color: Colors.blue.shade600);
    if (cat.contains('TOUR') || cat.contains('TRAVEL')) return Icon(Icons.flight_takeoff, size: 32, color: Colors.blue.shade600);
    if (cat.contains('CAR') || cat.contains('VEHICLE')) return Icon(Icons.directions_car, size: 32, color: Colors.blue.shade600);
    if (cat.contains('CLEANING')) return Icon(Icons.cleaning_services, size: 32, color: Colors.blue.shade600);
    if (cat.contains('AC') || cat.contains('REPAIR')) return Icon(Icons.build, size: 32, color: Colors.blue.shade600);
    return Icon(Icons.business_center_rounded, size: 32, color: Colors.blue.shade600);
  }

  Widget _buildPremiumServiceCard"""

content = content.replace('  Widget _buildPremiumServiceCard', service_icon_func)

# Modify the Container to show Image if available
old_container = """                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)], // blue-50 to blue-100
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Center(
                    child: Icon(Icons.business_center_rounded, size: 32, color: Colors.blue.shade600),
                  ),
                ),"""

new_container = """                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: (item.images.isNotEmpty || item.imageUrl != null)
                        ? CachedNetworkImage(
                            imageUrl: item.images.isNotEmpty ? item.images.first : item.imageUrl!,
                            fit: BoxFit.cover,
                            width: 72,
                            height: 72,
                            placeholder: (context, url) => Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            errorWidget: (context, url, error) => Center(child: _getServiceIcon(item.category)),
                          )
                        : Center(
                            child: _getServiceIcon(item.category),
                          ),
                  ),
                ),"""

content = content.replace(old_container, new_container)

with open('lib/presentation/classifieds/classifieds_screen.dart', 'w') as f:
    f.write(content)

