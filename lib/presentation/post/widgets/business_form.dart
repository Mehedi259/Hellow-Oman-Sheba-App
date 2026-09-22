import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/repositories/classifieds_repository.dart';
import '../../auth/auth_provider.dart';
import '../../classifieds/classifieds_provider.dart';
import '../../my_listings/providers/my_listings_provider.dart';
import 'service_form.dart' show CustomTextField;

class BusinessForm extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;
  final Map<String, dynamic>? initialData;
  final int? editId;
  const BusinessForm({
    super.key,
    required this.onSuccess,
    this.initialData,
    this.editId,
  });
  @override
  ConsumerState<BusinessForm> createState() => _BusinessFormState();
}

class _BusinessFormState extends ConsumerState<BusinessForm> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final areaController = TextEditingController();
  final contactNameController = TextEditingController();
  final contactPhoneController = TextEditingController();
  final websiteController = TextEditingController();
  final businessNameController = TextEditingController();

  String selectedBusinessType = 'Restaurant';
  String selectedCity = 'Muscat';

  List<File> selectedImages = [];
  bool isLoading = false;
  final picker = ImagePicker();

  static const List<Map<String, String>> businessTypes = [
    {'value': 'Restaurant', 'label': 'রেস্তোরাঁ'},
    {'value': 'Grocery Store', 'label': 'মুদিখানা/সুপারশপ'},
    {'value': 'Salon & Beauty', 'label': 'সেলুন ও বিউটি পার্লার'},
    {'value': 'Electronics Shop', 'label': 'ইলেকট্রনিক্স দোকান'},
    {'value': 'Clothing & Fashion', 'label': 'পোশাক ও ফ্যাশন'},
    {'value': 'Education & Training', 'label': 'শিক্ষা ও প্রশিক্ষণ'},
    {'value': 'IT & Technology', 'label': 'আইটি ও প্রযুক্তি'},
    {'value': 'Healthcare', 'label': 'স্বাস্থ্যসেবা'},
    {'value': 'Construction', 'label': 'নির্মাণ ও ঠিকাদারি'},
    {'value': 'Transport & Logistics', 'label': 'পরিবহন ও লজিস্টিক্স'},
    {'value': 'Agriculture', 'label': 'কৃষি ও খামার'},
    {'value': 'Other Business', 'label': 'অন্যান্য ব্যবসা'},
  ];

  static const List<String> cities = [
    'Muscat', 'Salalah', 'Sohar', 'Nizwa', 'Sur', 'Ibri', 'Barka', 'Rustaq',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final data = widget.initialData!;
      titleController.text = data['title'] ?? '';
      descriptionController.text = data['description'] ?? '';
      priceController.text = data['price']?.toString() ?? '';
      areaController.text = data['area'] ?? '';
      contactNameController.text = data['contact_name'] ?? '';
      contactPhoneController.text = data['contact_phone'] ?? '';
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
    websiteController.dispose();
    businessNameController.dispose();
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
        contactNameController.text.isEmpty || contactPhoneController.text.isEmpty) {
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
        'description': '${businessNameController.text.isNotEmpty ? "ব্যবসার নাম: ${businessNameController.text}\n" : ""}${websiteController.text.isNotEmpty ? "ওয়েবসাইট: ${websiteController.text}\n" : ""}${descriptionController.text}',
        'description_bn': descriptionController.text,
        'category': 'Business',
        'service_type': selectedBusinessType,
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
              Text(widget.editId != null ? 'বিজনেস আপডেট হয়েছে!' : 'বিজনেস পোস্ট হয়েছে!'),
            ]),
            backgroundColor: const Color(0xFF7C3AED),
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
        String errMsg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errMsg), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget _buildDropdown({
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
          CustomTextField(controller: businessNameController, label: 'ব্যবসার নাম *', hint: 'যেমন: Al-Ameen Trading LLC'),
          const SizedBox(height: 16),
          CustomTextField(controller: titleController, label: 'বিজ্ঞাপনের শিরোনাম *', hint: 'যেমন: সেরা দামে বাংলাদেশি পণ্য পাচ্ছেন'),
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'ব্যবসার ধরন',
            value: selectedBusinessType,
            items: businessTypes.map((t) => DropdownMenuItem(value: t['value'], child: Text(t['label']!))).toList(),
            onChanged: (val) => setState(() => selectedBusinessType = val!),
          ),
          const SizedBox(height: 16),
          CustomTextField(controller: websiteController, label: 'ওয়েবসাইট (ঐচ্ছিক)', hint: 'https://yourwebsite.com'),
          const SizedBox(height: 16),
          CustomTextField(
            controller: priceController,
            label: 'শুরুর মূল্য (OMR) — ঐচ্ছিক',
            hint: '0.00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          CustomTextField(controller: descriptionController, label: 'বিস্তারিত বিবরণ *', hint: 'আপনার ব্যবসা ও সার্ভিস সম্পর্কে বিস্তারিত লিখুন...', maxLines: 5),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          const Text('লোকেশন এবং যোগাযোগ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: CustomTextField(controller: contactNameController, label: 'যোগাযোগের নাম *', hint: 'আপনার নাম')),
              const SizedBox(width: 16),
              Expanded(child: CustomTextField(controller: contactPhoneController, label: 'ফোন নম্বর *', hint: '+968 ...', keyboardType: TextInputType.phone)),
            ],
          ),
          const SizedBox(height: 24),
          if (widget.editId == null) ...[
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ছবি', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                TextButton.icon(
                  onPressed: pickImages,
                  icon: const Icon(Icons.add_photo_alternate_rounded, color: Color(0xFF7C3AED)),
                  label: const Text('ছবি যোগ করুন', style: TextStyle(color: Color(0xFF7C3AED))),
                  style: TextButton.styleFrom(backgroundColor: const Color(0xFF7C3AED).withOpacity(0.1)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (selectedImages.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
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
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: isLoading ? null : submit,
            child: isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(widget.editId != null ? 'তথ্য আপডেট করুন' : 'বিজনেস পোস্ট করুন', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}
