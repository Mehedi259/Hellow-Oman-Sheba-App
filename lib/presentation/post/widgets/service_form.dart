import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/repositories/classifieds_repository.dart';
import '../../auth/auth_provider.dart';
import '../../classifieds/classifieds_provider.dart';
import '../../my_listings/providers/my_listings_provider.dart';

class ServiceForm extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;
  final Map<String, dynamic>? initialData;
  final int? editId;
  const ServiceForm({
    super.key,
    required this.onSuccess,
    this.initialData,
    this.editId,
  });
  @override
  ConsumerState<ServiceForm> createState() => _ServiceFormState();
}

class _ServiceFormState extends ConsumerState<ServiceForm> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final areaController = TextEditingController();
  final contactNameController = TextEditingController();
  final contactPhoneController = TextEditingController();

  String selectedCategory = 'AC_REPAIR';
  String selectedCity = 'Muscat';

  List<File> selectedImages = [];
  bool isLoading = false;
  final picker = ImagePicker();

  static const List<Map<String, String>> categories = [
    {'value': 'AC_REPAIR', 'label': 'এসি মেরামত'},
    {'value': 'PLUMBING', 'label': 'প্লাম্বিং'},
    {'value': 'ELECTRICAL', 'label': 'ইলেকট্রিক্যাল'},
    {'value': 'CLEANING', 'label': 'ক্লিনিং'},
    {'value': 'CARPENTRY', 'label': 'কাঠের কাজ'},
    {'value': 'PAINTING', 'label': 'রংয়ের কাজ'},
    {'value': 'APPLIANCE_REPAIR', 'label': 'অ্যাপ্লায়েন্স মেরামত'},
    {'value': 'OTHER', 'label': 'অন্যান্য'},
  ];

  static const List<String> cities = [
    'Muscat', 'Salalah', 'Sohar', 'Nizwa', 'Sur', 'Ibri', 'Barka', 'Rustaq',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final data = widget.initialData!;
      titleController.text = data['title'] ?? data['title_bn'] ?? '';
      descriptionController.text = data['description'] ?? data['description_bn'] ?? '';
      priceController.text = data['price']?.toString() ?? '';
      areaController.text = data['area'] ?? '';
      contactNameController.text = data['contact_name'] ?? '';
      contactPhoneController.text = data['contact_phone'] ?? '';
      
      if (data['category'] != null && categories.any((e) => e['value'] == data['category'])) {
        selectedCategory = data['category'];
      }
      if (data['city'] != null && cities.contains(data['city'])) {
        selectedCity = data['city'];
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    areaController.dispose();
    contactNameController.dispose();
    contactPhoneController.dispose();
    super.dispose();
  }

  Future<void> pickImages() async {
    try {
      final List<XFile> images = await picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          selectedImages.addAll(images.map((img) => File(img.path)));
        });
      }
    } catch (e) {
      debugPrint("Error picking images: $e");
    }
  }

  void removeImage(int index) {
    setState(() => selectedImages.removeAt(index));
  }

  Future<void> submit() async {
    if (titleController.text.isEmpty || descriptionController.text.isEmpty || 
        priceController.text.isEmpty || contactNameController.text.isEmpty || 
        contactPhoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white), 
            SizedBox(width: 8), 
            Expanded(child: Text('অনুগ্রহ করে প্রয়োজনীয় তথ্য দিন')),
          ]),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    
    setState(() => isLoading = true);
    try {
      final repo = ClassifiedsRepository(ref.read(apiClientProvider));
      final payload = {
        'title': titleController.text,
        'title_bn': titleController.text,
        'description': descriptionController.text,
        'description_bn': descriptionController.text,
        'service_type': selectedCategory,
        'price': double.tryParse(priceController.text) ?? 0,
        'currency': 'OMR',
        'city': selectedCity,
        'area': areaController.text,
        'contact_name': contactNameController.text,
        'contact_phone': contactPhoneController.text,
        'status': 'PUBLISHED',
      };

      if (widget.editId != null) {
        await repo.updateService(widget.editId!, payload);
      } else {
        await repo.createService(payload, images: selectedImages);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.check_circle_outline_rounded, color: Colors.white), 
              const SizedBox(width: 8), 
              Text(widget.editId != null ? 'সার্ভিস আপডেট হয়েছে!' : 'সার্ভিস পোস্ট হয়েছে!'),
            ]),
            backgroundColor: const Color(0xFF0D9488),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        ref.invalidate(servicesProvider);
        ref.invalidate(myPostsProvider);
        widget.onSuccess();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ত্রুটি: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            items: items,
            onChanged: onChanged,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            dropdownColor: Colors.white,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(controller: titleController, label: 'সার্ভিসের নাম *', hint: 'যেমন: বাসা শিফটিং সার্ভিস'),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'ক্যাটাগরি',
                  value: selectedCategory,
                  items: categories.map((c) => DropdownMenuItem(value: c['value'], child: Text(c['label']!))).toList(),
                  onChanged: (val) => setState(() => selectedCategory = val!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  controller: priceController,
                  label: 'ফি/মূল্য (OMR) *',
                  hint: '0.00',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          CustomTextField(controller: descriptionController, label: 'বিস্তারিত বর্ণনা *', hint: 'আপনার সার্ভিস সম্পর্কে বিস্তারিত লিখুন...', maxLines: 5),
          const SizedBox(height: 24),
          
          const Divider(),
          const SizedBox(height: 16),
          const Text('লোকেশন এবং যোগাযোগ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'শহর',
                  value: selectedCity,
                  items: cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setState(() => selectedCity = val!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: CustomTextField(controller: areaController, label: 'এলাকা', hint: 'যেমন: Ghubra')),
            ],
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(child: CustomTextField(controller: contactNameController, label: 'যোগাযোগের নাম *', hint: 'আপনার নাম')),
              const SizedBox(width: 16),
              Expanded(child: CustomTextField(controller: contactPhoneController, label: 'ফোন নম্বর *', hint: '+968 ...', keyboardType: TextInputType.phone)),
            ],
          ),
          const SizedBox(height: 24),
          
          // Image Picker
          if (widget.editId == null) ...[
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ছবি', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                TextButton.icon(
                  onPressed: pickImages,
                  icon: const Icon(Icons.add_photo_alternate_rounded, color: Color(0xFF0D9488)),
                  label: const Text('ছবি যোগ করুন', style: TextStyle(color: Color(0xFF0D9488))),
                  style: TextButton.styleFrom(backgroundColor: const Color(0xFF0D9488).withOpacity(0.1)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (selectedImages.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: selectedImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(image: FileImage(selectedImages[index]), fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        top: 4, right: 4,
                        child: GestureDetector(
                          onTap: () => removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            const SizedBox(height: 24),
          ],
          
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: isLoading ? null : submit,
            child: isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(widget.editId != null ? 'তথ্য আপডেট করুন' : 'বিজ্ঞাপন পোস্ট করুন', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
