import 'package:flutter/material.dart';
import 'widgets/job_form.dart';
import 'widgets/property_form.dart';
import 'widgets/vehicle_form.dart';
import 'widgets/market_form.dart';
import 'widgets/service_form.dart';

class EditPostScreen extends StatelessWidget {
  final String type;
  final int editId;
  final Map<String, dynamic> initialData;

  const EditPostScreen({
    super.key,
    required this.type,
    required this.editId,
    required this.initialData,
  });

  @override
  Widget build(BuildContext context) {
    Widget formContent;
    String formTitle;
    List<Color> formGradient;
    IconData icon;

    switch (type) {
      case 'property':
        formContent = PropertyForm(
          onSuccess: () => Navigator.pop(context),
          editId: editId,
          initialData: initialData,
        );
        formTitle = 'প্রপার্টি এডিট করুন';
        formGradient = const [Color(0xFF10B981), Color(0xFF059669)];
        icon = Icons.apartment_rounded;
        break;
      case 'job':
        formContent = JobForm(
          onSuccess: () => Navigator.pop(context),
          editId: editId,
          initialData: initialData,
        );
        formTitle = 'চাকরি এডিট করুন';
        formGradient = const [Color(0xFF3B82F6), Color(0xFF1D4ED8)];
        icon = Icons.work_rounded;
        break;
      case 'vehicle':
        formContent = VehicleForm(
          onSuccess: () => Navigator.pop(context),
          editId: editId,
          initialData: initialData,
        );
        formTitle = 'গাড়ি এডিট করুন';
        formGradient = const [Color(0xFF8B5CF6), Color(0xFF6D28D9)];
        icon = Icons.directions_car_rounded;
        break;
      case 'classified':
      case 'market':
        formContent = MarketForm(
          onSuccess: () => Navigator.pop(context),
          editId: editId,
          initialData: initialData,
        );
        formTitle = 'মার্কেট পোস্ট এডিট করুন';
        formGradient = const [Color(0xFFF59E0B), Color(0xFFD97706)];
        icon = Icons.storefront_rounded;
        break;
      case 'service':
        formContent = ServiceForm(
          onSuccess: () => Navigator.pop(context),
          editId: editId,
          initialData: initialData,
        );
        formTitle = 'সার্ভিস এডিট করুন';
        formGradient = const [Color(0xFF14B8A6), Color(0xFF0D9488)];
        icon = Icons.handyman_rounded;
        break;
      default:
        formContent = Center(child: Text('Editing for $type is not supported yet'));
        formTitle = 'এডিট করুন';
        formGradient = const [Colors.grey, Colors.blueGrey];
        icon = Icons.edit;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: formGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 20),
              child: Row(
                children: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(formTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                        const SizedBox(height: 2),
                        Text('তথ্য পরিবর্তন করে সেভ করুন', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFFF8FAFC),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: formContent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
