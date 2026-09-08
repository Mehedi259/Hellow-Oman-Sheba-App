import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../my_listings/providers/my_listings_provider.dart';
import '../../../data/repositories/classifieds_repository.dart';
import '../../auth/auth_provider.dart';

class PropertyForm extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;
  final Map<String, dynamic>? initialData;
  final int? editId;
  const PropertyForm({
    super.key,
    required this.onSuccess,
    this.initialData,
    this.editId,
  });
  @override
  ConsumerState<PropertyForm> createState() => _PropertyFormState();
}

class _PropertyFormState extends ConsumerState<PropertyForm> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final areaController = TextEditingController();
  final bedroomsController = TextEditingController();
  final bathroomsController = TextEditingController();
  final contactNameController = TextEditingController();
  final contactPhoneController = TextEditingController();

  String selectedPropertyType = 'APARTMENT';
  String selectedPurpose = 'RENT';
  String selectedCity = 'Muscat';

  List<File> selectedImages = [];
  bool isLoading = false;
  final picker = ImagePicker();

  static const List<Map<String, String>> propertyTypes = [
    {'value': 'APARTMENT', 'label': 'অ্যাপার্টমেন্ট'},
    {'value': 'VILLA', 'label': 'ভিলা'},
    {'value': 'HOUSE', 'label': 'বাসা'},
    {'value': 'ROOM', 'label': 'রুম'},
    {'value': 'BED_SPACE', 'label': 'বেড স্পেস'},
    {'value': 'COMMERCIAL', 'label': 'কমার্শিয়াল'},
  ];

  static const List<Map<String, String>> purposes = [
    {'value': 'RENT', 'label': 'ভাড়া'},
    {'value': 'SALE', 'label': 'বিক্রয়'},
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
      bedroomsController.text = data['bedrooms']?.toString() ?? '';
      bathroomsController.text = data['bathrooms']?.toString() ?? '';
      contactNameController.text = data['contact_name'] ?? '';
      contactPhoneController.text = data['contact_phone'] ?? '';
      
      if (data['property_type'] != null && propertyTypes.any((e) => e['value'] == data['property_type'])) {
        selectedPropertyType = data['property_type'];
      }
      if (data['purpose'] != null && purposes.any((e) => e['value'] == data['purpose'])) {
        selectedPurpose = data['purpose'];
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
    bedroomsController.dispose();
    bathroomsController.dispose();
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
        'price': double.tryParse(priceController.text) ?? 0,
        'currency': 'OMR',
        'property_type': selectedPropertyType,
        'purpose': selectedPurpose,
        'category': selectedPropertyType,
        'type': selectedPropertyType == 'COMMERCIAL' ? 'COMMERCIAL' : 'RESIDENTIAL',
        'city': selectedCity,
        'area': areaController.text,
        'bedrooms': bedroomsController.text.isNotEmpty ? int.tryParse(bedroomsController.text) : null,
        'bathrooms': bathroomsController.text.isNotEmpty ? int.tryParse(bathroomsController.text) : null,
        'contact_name': contactNameController.text,
        'contact_phone': contactPhoneController.text,
        'status': 'PUBLISHED',
      };

      final response = widget.editId != null 
          ? await repo.updateProperty(widget.editId!, payload)
          : await repo.createProperty(payload);

      final int? propertyId = response['id'];

      // Only upload images if there are new ones selected. 
      // If editing and no new images are selected, we skip image upload.
      if (propertyId != null && selectedImages.isNotEmpty) {
        for (var i = 0; i < selectedImages.length; i++) {
          await repo.uploadClassifiedImage(selectedImages[i].path, 'property', propertyId, i == 0);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white), 
              const SizedBox(width: 8), 
              Expanded(child: Text(widget.editId != null ? 'প্রপার্টি সফলভাবে আপডেট হয়েছে!' : 'প্রপার্টি সফলভাবে পোস্ট হয়েছে!')),
            ]),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        ref.invalidate(myPostsProvider);
        widget.onSuccess();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()), 
            backgroundColor: const Color(0xFFEF4444), 
            behavior: SnackBarBehavior.floating, 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- Section: Basic Info ---
          _buildSectionHeader(Icons.home_rounded, 'প্রপার্টি তথ্য', const Color(0xFF10B981)),
          const SizedBox(height: 16),
          _buildTextField(titleController, 'শিরোনাম', hint: 'যেমন: ২ বেডরুম ভাড়া দেয়া হবে', icon: Icons.title_rounded, isRequired: true),
          const SizedBox(height: 14),
          
          Row(
            children: [
              Expanded(child: _buildDropdown('প্রপার্টির ধরন', propertyTypes, selectedPropertyType, (v) => setState(() => selectedPropertyType = v), isRequired: true)),
              const SizedBox(width: 12),
              Expanded(child: _buildDropdown('উদ্দেশ্য', purposes, selectedPurpose, (v) => setState(() => selectedPurpose = v), isRequired: true)),
            ],
          ),

          const SizedBox(height: 28),
          // --- Section: Location ---
          _buildSectionHeader(Icons.location_on_rounded, 'লোকেশন', const Color(0xFF3B82F6)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCityDropdown(),
              ),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(areaController, 'এলাকা', hint: 'যেমন: Al Khuwair', icon: Icons.pin_drop_rounded, isRequired: true)),
            ],
          ),

          const SizedBox(height: 28),
          // --- Section: Price ---
          _buildSectionHeader(Icons.payments_rounded, 'মূল্য ও বিবরণ', const Color(0xFFF59E0B)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField(priceController, 'মূল্য (OMR)', isNumber: true, hint: '300', icon: Icons.currency_exchange_rounded, isRequired: true)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(bedroomsController, 'বেডরুম', isNumber: true, hint: '2', icon: Icons.bed_rounded)),
            ],
          ),
          const SizedBox(height: 14),
          _buildTextField(bathroomsController, 'বাথরুম', isNumber: true, hint: '1', icon: Icons.bathtub_rounded),
          const SizedBox(height: 14),
          _buildTextField(descriptionController, 'বিবরণ', maxLines: 4, hint: 'প্রপার্টির বিস্তারিত বিবরণ লিখুন...', icon: Icons.article_rounded, isRequired: true),

          const SizedBox(height: 28),
          // --- Section: Contact ---
          _buildSectionHeader(Icons.contact_phone_rounded, 'যোগাযোগ', const Color(0xFFEC4899)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField(contactNameController, 'নাম', hint: 'আপনার নাম', icon: Icons.person_rounded, isRequired: true)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(contactPhoneController, 'ফোন', hint: '+968 9XXXXXXX', icon: Icons.phone_rounded, isRequired: true)),
            ],
          ),

          const SizedBox(height: 28),
          // --- Section: Images ---
          _buildSectionHeader(Icons.photo_library_rounded, 'ছবি আপলোড', const Color(0xFF14B8A6)),
          const SizedBox(height: 16),
          _buildImagePicker(),

          const SizedBox(height: 36),
          _buildSubmitButton(),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: color))),
        Expanded(child: Container(height: 1, color: color.withValues(alpha: 0.15))),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1, bool isNumber = false, String? hint, IconData? icon, bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF475569))),
            if (isRequired) const Text(' *', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14, fontWeight: FontWeight.w400),
            prefixIcon: icon != null && maxLines == 1 ? Icon(icon, size: 20, color: const Color(0xFF94A3B8)) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: icon != null && maxLines == 1 ? 0 : 16, vertical: maxLines > 1 ? 16 : 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<Map<String, String>> items, String value, ValueChanged<String> onChanged, {bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF475569))),
            if (isRequired) const Text(' *', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
              items: items.map((item) => DropdownMenuItem(
                value: item['value'],
                child: Text(item['label']!),
              )).toList(),
              onChanged: (v) { if (v != null) onChanged(v); },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('শহর', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF475569))),
            Text(' *', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCity,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
              items: cities.map((city) => DropdownMenuItem(
                value: city,
                child: Text(city),
              )).toList(),
              onChanged: (v) { if (v != null) setState(() => selectedCity = v); },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        InkWell(
          onTap: pickImages,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              color: const Color(0xFF14B8A6).withValues(alpha: 0.05),
              border: Border.all(color: const Color(0xFF14B8A6).withValues(alpha: 0.3), width: 1.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFF14B8A6).withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.cloud_upload_rounded, size: 32, color: Color(0xFF14B8A6)),
                ),
                const SizedBox(height: 12),
                const Text('ছবি আপলোড করুন', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF14B8A6))),
                const SizedBox(height: 4),
                Text(
                  selectedImages.isEmpty ? 'ট্যাপ করে গ্যালারি থেকে ছবি সিলেক্ট করুন' : '${selectedImages.length} টি ছবি সিলেক্ট করা হয়েছে',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ),
        if (selectedImages.isNotEmpty) ...[
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: selectedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: Stack(
                    children: [
                      Container(
                        width: 90, height: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200, width: 2),
                          image: DecorationImage(image: FileImage(selectedImages[index]), fit: BoxFit.cover),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 4))],
                        ),
                      ),
                      Positioned(
                        right: -2, top: -2,
                        child: GestureDetector(
                          onTap: () => removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444), shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: const Color(0xFFEF4444).withValues(alpha: 0.3), blurRadius: 6)],
                            ),
                            child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                      if (index == 0)
                        Positioned(
                          bottom: 0, left: 0, right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                            ),
                            child: const Text('প্রধান ছবি', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)], begin: Alignment.centerLeft, end: Alignment.centerRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: const Color(0xFF10B981).withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : submit,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(widget.editId != null ? Icons.save_rounded : Icons.publish_rounded, color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                      Text(widget.editId != null ? 'প্রপার্টি আপডেট করুন' : 'প্রপার্টি পোস্ট করুন', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.3)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
