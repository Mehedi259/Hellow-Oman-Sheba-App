import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/repositories/classifieds_repository.dart';
import '../../auth/auth_provider.dart';
import '../../classifieds/classifieds_provider.dart';
import '../../my_listings/providers/my_listings_provider.dart';

class VehicleForm extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;
  final Map<String, dynamic>? initialData;
  final int? editId;
  const VehicleForm({
    super.key,
    required this.onSuccess,
    this.initialData,
    this.editId,
  });
  @override
  ConsumerState<VehicleForm> createState() => _VehicleFormState();
}

class _VehicleFormState extends ConsumerState<VehicleForm> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final yearController = TextEditingController();
  final mileageController = TextEditingController();
  final priceController = TextEditingController();
  final areaController = TextEditingController();
  final contactNameController = TextEditingController();
  final contactPhoneController = TextEditingController();

  String selectedVehicleType = 'CAR';
  String selectedPurpose = 'SALE';
  String selectedCondition = 'NEW';
  String selectedFuelType = 'PETROL';
  String selectedTransmission = 'AUTOMATIC';
  String selectedCity = 'Muscat';

  List<File> selectedImages = [];
  bool isLoading = false;
  final picker = ImagePicker();

  static const List<Map<String, String>> vehicleTypes = [
    {'value': 'CAR', 'label': 'গাড়ি'},
    {'value': 'SUV', 'label': 'এসইউভি'},
    {'value': 'TRUCK', 'label': 'ট্রাক'},
    {'value': 'VAN', 'label': 'ভ্যান'},
    {'value': 'MOTORCYCLE', 'label': 'মোটরসাইকেল'},
    {'value': 'BUS', 'label': 'বাস'},
  ];

  static const List<Map<String, String>> purposes = [
    {'value': 'SALE', 'label': 'বিক্রয়'},
    {'value': 'RENT', 'label': 'ভাড়া'},
  ];

  static const List<Map<String, String>> conditions = [
    {'value': 'NEW', 'label': 'নতুন'},
    {'value': 'USED', 'label': 'ব্যবহৃত'},
    {'value': 'EXCELLENT', 'label': 'চমৎকার'},
    {'value': 'GOOD', 'label': 'ভাল'},
    {'value': 'FAIR', 'label': 'মোটামুটি'},
  ];

  static const List<Map<String, String>> fuelTypes = [
    {'value': 'PETROL', 'label': 'পেট্রোল'},
    {'value': 'DIESEL', 'label': 'ডিজেল'},
    {'value': 'ELECTRIC', 'label': 'বৈদ্যুতিক'},
    {'value': 'HYBRID', 'label': 'হাইব্রিড'},
  ];

  static const List<Map<String, String>> transmissions = [
    {'value': 'AUTOMATIC', 'label': 'অটোমেটিক'},
    {'value': 'MANUAL', 'label': 'ম্যানুয়াল'},
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
      brandController.text = data['make'] ?? data['brand'] ?? '';
      modelController.text = data['model'] ?? '';
      yearController.text = data['year']?.toString() ?? '';
      mileageController.text = data['mileage']?.toString() ?? '';
      priceController.text = data['price']?.toString() ?? '';
      areaController.text = data['area'] ?? '';
      contactNameController.text = data['contact_name'] ?? '';
      contactPhoneController.text = data['contact_phone'] ?? '';
      
      if (data['type'] != null && vehicleTypes.any((e) => e['value'] == data['type'])) {
        selectedVehicleType = data['type'];
      }
      if (data['purpose'] != null && purposes.any((e) => e['value'] == data['purpose'])) {
        selectedPurpose = data['purpose'];
      }
      if (data['condition'] != null && conditions.any((e) => e['value'] == data['condition'])) {
        selectedCondition = data['condition'];
      }
      if (data['fuel_type'] != null && fuelTypes.any((e) => e['value'] == data['fuel_type'])) {
        selectedFuelType = data['fuel_type'];
      }
      if (data['transmission'] != null && transmissions.any((e) => e['value'] == data['transmission'])) {
        selectedTransmission = data['transmission'];
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
    brandController.dispose();
    modelController.dispose();
    yearController.dispose();
    mileageController.dispose();
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
        'purpose': selectedPurpose,
        'type': selectedVehicleType,
        'make': brandController.text,
        'model': modelController.text,
        'year': yearController.text.isNotEmpty ? int.tryParse(yearController.text) : null,
        'condition': selectedCondition,
        'fuel_type': selectedFuelType,
        'transmission': selectedTransmission,
        'mileage': mileageController.text.isNotEmpty ? int.tryParse(mileageController.text) : null,
        'price': double.tryParse(priceController.text) ?? 0,
        'currency': 'OMR',
        'city': selectedCity,
        'area': areaController.text,
        'contact_name': contactNameController.text,
        'contact_phone': contactPhoneController.text,
        'status': 'PUBLISHED',
      };

      if (widget.editId != null) {
        await repo.updateVehicle(widget.editId!, payload);
      } else {
        await repo.createVehicle(payload, images: selectedImages);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.check_circle_outline_rounded, color: Colors.white), 
              const SizedBox(width: 8), 
              Text(widget.editId != null ? 'গাড়ির তথ্য আপডেট হয়েছে!' : 'গাড়ির বিজ্ঞাপন পোস্ট হয়েছে!'),
            ]),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        ref.invalidate(vehiclesProvider);
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
          // Purpose & Vehicle Type Row
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'বিজ্ঞাপনের ধরন',
                  value: selectedPurpose,
                  items: purposes.map((p) => DropdownMenuItem(value: p['value'], child: Text(p['label']!))).toList(),
                  onChanged: (val) => setState(() => selectedPurpose = val!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField(
                  label: 'গাড়ির ধরন',
                  value: selectedVehicleType,
                  items: vehicleTypes.map((t) => DropdownMenuItem(value: t['value'], child: Text(t['label']!))).toList(),
                  onChanged: (val) => setState(() => selectedVehicleType = val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          CustomTextField(controller: titleController, label: 'বিজ্ঞাপনের শিরোনাম *', hint: 'যেমন: Toyota Corolla 2020 বিক্রয়'),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(child: CustomTextField(controller: brandController, label: 'ব্র্যান্ড (Make)', hint: 'যেমন: Toyota')),
              const SizedBox(width: 16),
              Expanded(child: CustomTextField(controller: modelController, label: 'মডেল', hint: 'যেমন: Corolla')),
            ],
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(child: CustomTextField(controller: yearController, label: 'বছর', hint: 'যেমন: 2020', keyboardType: TextInputType.number)),
              const SizedBox(width: 16),
              Expanded(child: CustomTextField(controller: mileageController, label: 'মাইলেজ (কি.মি.)', hint: 'যেমন: 15000', keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'অবস্থা (Condition)',
                  value: selectedCondition,
                  items: conditions.map((c) => DropdownMenuItem(value: c['value'], child: Text(c['label']!))).toList(),
                  onChanged: (val) => setState(() => selectedCondition = val!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField(
                  label: 'জ্বালানী (Fuel)',
                  value: selectedFuelType,
                  items: fuelTypes.map((f) => DropdownMenuItem(value: f['value'], child: Text(f['label']!))).toList(),
                  onChanged: (val) => setState(() => selectedFuelType = val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'ট্রান্সমিশন',
                  value: selectedTransmission,
                  items: transmissions.map((t) => DropdownMenuItem(value: t['value'], child: Text(t['label']!))).toList(),
                  onChanged: (val) => setState(() => selectedTransmission = val!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  controller: priceController,
                  label: 'মূল্য (OMR) *',
                  hint: '0.00',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          CustomTextField(controller: descriptionController, label: 'বিস্তারিত বর্ণনা *', hint: 'গাড়ির বিস্তারিত তথ্য লিখুন...', maxLines: 4),
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
              Expanded(child: CustomTextField(controller: areaController, label: 'এলাকা', hint: 'যেমন: Ruwi')),
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
                const Text('গাড়ির ছবি', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                TextButton.icon(
                  onPressed: pickImages,
                  icon: const Icon(Icons.add_photo_alternate_rounded, color: Color(0xFF8B5CF6)),
                  label: const Text('ছবি যোগ করুন', style: TextStyle(color: Color(0xFF8B5CF6))),
                  style: TextButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.1)),
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
              backgroundColor: const Color(0xFF8B5CF6),
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
