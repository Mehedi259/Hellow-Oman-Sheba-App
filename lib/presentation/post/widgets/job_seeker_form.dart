import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/repositories/classifieds_repository.dart';
import '../../../core/api/api_client.dart';
import '../../auth/auth_provider.dart';

class JobSeekerForm extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;
  const JobSeekerForm({super.key, required this.onSuccess});
  @override
  ConsumerState<JobSeekerForm> createState() => _JobSeekerFormState();
}

class _JobSeekerFormState extends ConsumerState<JobSeekerForm> {
  final titleController = TextEditingController();
  final experienceController = TextEditingController();
  final educationController = TextEditingController();
  final skillsController = TextEditingController();
  final summaryController = TextEditingController();
  final expectedSalaryController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();
  final areaController = TextEditingController();

  List<File> selectedImages = [];
  bool isLoading = false;

  final picker = ImagePicker();

  @override
  void dispose() {
    titleController.dispose();
    experienceController.dispose();
    educationController.dispose();
    skillsController.dispose();
    summaryController.dispose();
    expectedSalaryController.dispose();
    phoneController.dispose();
    cityController.dispose();
    areaController.dispose();
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
    if (titleController.text.isEmpty || experienceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.white), SizedBox(width: 8), Expanded(child: Text('অনুগ্রহ করে প্রয়োজনীয় তথ্য দিন'))]),
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
      
      final skillsList = skillsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      
      final response = await repo.createJobSeekerProfile({
        'professional_title': titleController.text,
        'years_of_experience': int.tryParse(experienceController.text) ?? 0,
        'education_level': educationController.text,
        'summary': summaryController.text,
        'expected_salary': expectedSalaryController.text.isNotEmpty ? int.tryParse(expectedSalaryController.text) : null,
        'skills': skillsList,
        'phone': phoneController.text,
        'city': cityController.text,
        'area': areaController.text,
      });

      final int? profileId = response['id'];
      
      if (profileId != null && selectedImages.isNotEmpty) {
        for (var i = 0; i < selectedImages.length; i++) {
          await repo.uploadClassifiedImage(selectedImages[i].path, 'others', profileId, i == 0);
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(children: [Icon(Icons.check_circle_rounded, color: Colors.white), SizedBox(width: 8), Expanded(child: Text('আপনার প্রোফাইল সফলভাবে তৈরি হয়েছে!'))]),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
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
          // --- Section: Professional Info ---
          _buildSectionHeader(Icons.work_history_rounded, 'পেশাগত তথ্য', const Color(0xFF8B5CF6)),
          const SizedBox(height: 16),
          _buildTextField(titleController, 'পেশা বা টাইটেল', hint: 'যেমন: সিনিয়র প্লাম্বার, ড্রাইভার', icon: Icons.badge_rounded, isRequired: true),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _buildTextField(experienceController, 'অভিজ্ঞতা (বছর)', isNumber: true, hint: '0', icon: Icons.timeline_rounded, isRequired: true)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(educationController, 'শিক্ষাগত যোগ্যতা', hint: 'এস.এস.সি', icon: Icons.school_rounded)),
            ],
          ),
          const SizedBox(height: 14),
          _buildTextField(skillsController, 'দক্ষতা (কমা দিয়ে আলাদা করুন)', hint: 'প্লাম্বিং, ড্রাইভিং, এসি রিপেয়ার...', icon: Icons.psychology_rounded),
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text('যেমন: প্লাম্বিং, এসি রিপেয়ার, কারপেন্ট্রি', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
          ),

          const SizedBox(height: 28),
          // --- Section: About ---
          _buildSectionHeader(Icons.person_rounded, 'আপনার সম্পর্কে', const Color(0xFF3B82F6)),
          const SizedBox(height: 16),
          _buildTextField(summaryController, 'সংক্ষিপ্ত বিবরণ', maxLines: 4, hint: 'আপনার কাজের অভিজ্ঞতা এবং দক্ষতা সম্পর্কে বিস্তারিত লিখুন...', icon: Icons.article_rounded),

          const SizedBox(height: 28),
          // --- Section: Salary ---
          _buildSectionHeader(Icons.payments_rounded, 'বেতন', const Color(0xFFF59E0B)),
          const SizedBox(height: 16),
          _buildTextField(expectedSalaryController, 'প্রত্যাশিত বেতন (OMR)', isNumber: true, hint: 'যেমন: 200', icon: Icons.currency_exchange_rounded),

          const SizedBox(height: 28),
          // --- Section: Contact ---
          _buildSectionHeader(Icons.contact_phone_rounded, 'যোগাযোগ ও লোকেশন', const Color(0xFFEC4899)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField(phoneController, 'ফোন নম্বর', hint: '+968 9XXXXXXX', icon: Icons.phone_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(cityController, 'শহর', hint: 'মাস্কাট', icon: Icons.location_city_rounded)),
            ],
          ),
          const SizedBox(height: 14),
          _buildTextField(areaController, 'এলাকা/Area', hint: 'যেমন: রুই, সিব', icon: Icons.pin_drop_rounded),

          const SizedBox(height: 28),
          // --- Section: Images ---
          _buildSectionHeader(Icons.photo_library_rounded, 'সার্টিফিকেট / আইডি / কাজের ছবি', const Color(0xFF14B8A6)),
          const SizedBox(height: 16),
          _buildImagePicker(),

          const SizedBox(height: 36),
          _buildSubmitButton(),
          const SizedBox(height: 40),
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
        Expanded(child: Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: color))),
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
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: icon != null && maxLines == 1 ? 0 : 16, vertical: maxLines > 1 ? 16 : 14),
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
              border: Border.all(color: const Color(0xFF14B8A6).withOpacity(0.3), width: 1.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFF14B8A6).withOpacity(0.1), shape: BoxShape.circle),
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
        gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)], begin: Alignment.centerLeft, end: Alignment.centerRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: const Color(0xFF8B5CF6).withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 8)),
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
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_add_rounded, color: Colors.white, size: 22),
                      SizedBox(width: 10),
                      Text('প্রোফাইল তৈরি করুন', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.3)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
