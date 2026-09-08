import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../my_listings/providers/my_listings_provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/repositories/classifieds_repository.dart';
import '../../../core/api/api_client.dart';
import '../../auth/auth_provider.dart';

class JobForm extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;
  final Map<String, dynamic>? initialData;
  final int? editId;
  const JobForm({
    super.key,
    required this.onSuccess,
    this.initialData,
    this.editId,
  });
  @override
  ConsumerState<JobForm> createState() => _JobFormState();
}

class _JobFormState extends ConsumerState<JobForm> {
  final titleController = TextEditingController();
  final companyController = TextEditingController();
  final areaController = TextEditingController();
  final minSalaryController = TextEditingController();
  final maxSalaryController = TextEditingController();
  final descriptionController = TextEditingController();
  final requirementsController = TextEditingController();
  final benefitsController = TextEditingController();
  final contactNameController = TextEditingController();
  final contactPhoneController = TextEditingController();

  String? typeValue;
  String? cityValue;
  String currencyValue = 'OMR';

  List<File> selectedImages = [];
  bool isLoading = false;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final data = widget.initialData!;
      titleController.text = data['title'] ?? data['title_bn'] ?? '';
      companyController.text = data['company_name'] ?? '';
      areaController.text = data['area'] ?? '';
      minSalaryController.text = data['salary_min']?.toString() ?? '';
      maxSalaryController.text = data['salary_max']?.toString() ?? '';
      descriptionController.text = data['description'] ?? data['description_bn'] ?? '';
      requirementsController.text = data['requirements'] ?? '';
      benefitsController.text = data['benefits'] ?? '';
      contactNameController.text = data['contact_name'] ?? '';
      contactPhoneController.text = data['contact_phone'] ?? '';
      
      typeValue = data['type'] ?? typeValue;
      cityValue = data['city'] ?? cityValue;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    companyController.dispose();
    areaController.dispose();
    minSalaryController.dispose();
    maxSalaryController.dispose();
    descriptionController.dispose();
    requirementsController.dispose();
    benefitsController.dispose();
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
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  Future<void> submit() async {
    if (titleController.text.isEmpty || companyController.text.isEmpty || typeValue == null || cityValue == null || areaController.text.isEmpty || descriptionController.text.isEmpty || contactNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.white), SizedBox(width: 8), Expanded(child: Text('অনুগ্রহ করে সব প্রয়োজনীয় তথ্য দিন'))]),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    
    setState(() => isLoading = true);
    try {
      final typeMap = {
        'Full-time': 'FULL_TIME',
        'Part-time': 'PART_TIME',
        'Contract': 'CONTRACT',
        'Internship': 'INTERNSHIP',
      };

      final repo = ClassifiedsRepository(ref.read(apiClientProvider));
      final payload = {
        'title': titleController.text,
        'title_bn': titleController.text,
        'company_name_en': companyController.text,
        'type': typeMap[typeValue] ?? 'FULL_TIME',
        'city': cityValue,
        'area': areaController.text,
        'salary_min': minSalaryController.text,
        'salary_max': maxSalaryController.text,
        'salary_currency': currencyValue,
        'description': descriptionController.text,
        'description_bn': descriptionController.text,
        'requirements': requirementsController.text,
        'experience': requirementsController.text, // API expects experience instead of requirements
        'benefits': benefitsController.text,
        'contact_name': '${companyController.text} (${contactNameController.text})',
        'contact_phone': contactPhoneController.text,
        'status': 'PUBLISHED',
        'job_status': 'PUBLISHED',
      };

      if (widget.editId != null) {
        await repo.updateJob(widget.editId!, payload);
      } else {
        await repo.createJob(payload);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white), 
              const SizedBox(width: 8), 
              Expanded(child: Text(widget.editId != null ? 'চাকরির বিজ্ঞাপন সফলভাবে আপডেট করা হয়েছে!' : 'চাকরির বিজ্ঞাপন সফলভাবে পোস্ট করা হয়েছে!'))
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
          SnackBar(content: Text(e.toString()), backgroundColor: const Color(0xFFEF4444), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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
          _buildSectionHeader(Icons.info_outline_rounded, 'মৌলিক তথ্য', const Color(0xFF3B82F6)),
          const SizedBox(height: 16),
          _buildTextField(titleController, 'চাকরির শিরোনাম', hint: 'যেমন: সফটওয়্যার ইঞ্জিনিয়ার', icon: Icons.badge_rounded, isRequired: true),
          const SizedBox(height: 14),
          _buildTextField(companyController, 'কোম্পানির নাম', hint: 'কোম্পানির নাম লিখুন', icon: Icons.business_rounded, isRequired: true),
          const SizedBox(height: 14),
          _buildDropdown('চাকরির ধরন', ['Full-time', 'Part-time'], typeValue, (val) => setState(() => typeValue = val), icon: Icons.category_rounded, isRequired: true),

          const SizedBox(height: 28),
          // --- Section: Location ---
          _buildSectionHeader(Icons.location_on_rounded, 'লোকেশন', const Color(0xFF10B981)),
          const SizedBox(height: 16),
          _buildDropdown('শহর', ['Muscat', 'Seeb', 'Salalah', 'Bawshar', 'Sohar', 'As Suwayq', 'Ibri', 'Saham', 'Barka', 'Rustaq', 'Nizwa', 'Buraimi', 'Sur', 'Ibra', 'Khasab', 'Duqm'], cityValue, (val) => setState(() => cityValue = val), icon: Icons.location_city_rounded, isRequired: true),
          const SizedBox(height: 14),
          _buildTextField(areaController, 'এলাকা', hint: 'যেমন: Al Khuwair', icon: Icons.pin_drop_rounded, isRequired: true),

          const SizedBox(height: 28),
          // --- Section: Salary ---
          _buildSectionHeader(Icons.payments_rounded, 'বেতন', const Color(0xFFF59E0B)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField(minSalaryController, 'ন্যূনতম', isNumber: true, hint: '300', icon: Icons.arrow_downward_rounded)),
              const SizedBox(width: 12),
              Container(
                margin: const EdgeInsets.only(top: 24),
                child: const Text('—', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(maxSalaryController, 'সর্বোচ্চ', isNumber: true, hint: '500', icon: Icons.arrow_upward_rounded)),
            ],
          ),
          const SizedBox(height: 14),
          _buildDropdown('মুদ্রা', ['OMR', 'BDT'], currencyValue, (val) => setState(() => currencyValue = val!), icon: Icons.currency_exchange_rounded),

          const SizedBox(height: 28),
          // --- Section: Description ---
          _buildSectionHeader(Icons.description_rounded, 'বিবরণ ও যোগ্যতা', const Color(0xFF8B5CF6)),
          const SizedBox(height: 16),
          _buildTextField(descriptionController, 'বিবরণ', maxLines: 4, hint: 'চাকরির বিস্তারিত বিবরণ লিখুন', icon: Icons.article_rounded, isRequired: true),
          const SizedBox(height: 14),
          _buildTextField(requirementsController, 'যোগ্যতা', maxLines: 3, hint: 'প্রয়োজনীয় যোগ্যতা লিখুন', icon: Icons.checklist_rounded),
          const SizedBox(height: 14),
          _buildTextField(benefitsController, 'সুবিধা', maxLines: 3, hint: 'চাকরির সুবিধা লিখুন', icon: Icons.card_giftcard_rounded),

          const SizedBox(height: 28),
          // --- Section: Contact ---
          _buildSectionHeader(Icons.contact_phone_rounded, 'যোগাযোগ', const Color(0xFFEC4899)),
          const SizedBox(height: 16),
          _buildTextField(contactNameController, 'যোগাযোগের নাম', hint: 'আপনার নাম', icon: Icons.person_rounded, isRequired: true),
          const SizedBox(height: 14),
          _buildTextField(contactPhoneController, 'যোগাযোগ ফোন', hint: '+968 9XXXXXXX', icon: Icons.phone_rounded, isRequired: true),

          const SizedBox(height: 28),
          // --- Section: Images ---
          _buildSectionHeader(Icons.photo_library_rounded, 'ছবি আপলোড', const Color(0xFF14B8A6)),
          const SizedBox(height: 16),
          _buildImagePicker(),

          const SizedBox(height: 36),
          // Submit button
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
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(width: 12),
        Expanded(child: Container(height: 1, color: color.withOpacity(0.15))),
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
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: icon != null && maxLines == 1 ? 0 : 16, vertical: maxLines > 1 ? 16 : 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, void Function(String?) onChanged, {IconData? icon, bool isRequired = false}) {
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
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(14),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              hint: Row(
                children: [
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
                    const SizedBox(width: 12),
                  ] else
                    const SizedBox(width: 12),
                  Text('নির্বাচন করুন', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                ],
              ),
              selectedItemBuilder: (context) {
                return items.map((item) {
                  return Row(
                    children: [
                      if (icon != null) ...[
                        const SizedBox(width: 8),
                        Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
                        const SizedBox(width: 12),
                      ] else
                        const SizedBox(width: 12),
                      Text(item, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF1E293B))),
                    ],
                  );
                }).toList();
              },
              icon: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade400),
              ),
              items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              onChanged: onChanged,
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
              color: const Color(0xFF14B8A6).withOpacity(0.05),
              border: Border.all(color: const Color(0xFF14B8A6).withOpacity(0.3), width: 1.5, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14B8A6).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
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
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200, width: 2),
                          image: DecorationImage(image: FileImage(selectedImages[index]), fit: BoxFit.cover),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4))],
                        ),
                      ),
                      Positioned(
                        right: -2,
                        top: -2,
                        child: GestureDetector(
                          onTap: () => removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: const Color(0xFFEF4444).withOpacity(0.3), blurRadius: 6)],
                            ),
                            child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                          ),
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
        gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFDB2777)], begin: Alignment.centerLeft, end: Alignment.centerRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 8)),
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
                      Text(widget.editId != null ? 'আপডেট করুন' : 'বিজ্ঞাপন পোস্ট করুন', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.3)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
