import 'dart:io';

void main() {
  final file = File('/Users/mehedihasanmridul/app/Hellow-Oman-Sheba-App/lib/presentation/profile/profile_screen.dart');
  var content = file.readAsStringSync();

  // 1. Add ImagePicker and Dio imports if needed
  if (!content.contains('import \'package:image_picker/image_picker.dart\';')) {
    content = content.replaceFirst(
      'import \'package:flutter/material.dart\';',
      "import 'package:flutter/material.dart';\nimport 'package:image_picker/image_picker.dart';\nimport 'package:dio/dio.dart';"
    );
  }

  // 2. Add _pickAndUploadImage method to _ProfileScreenState
  if (!content.contains('_pickAndUploadImage')) {
    final methodString = '''
  Future<void> _pickAndUploadImage(BuildContext context, WidgetRef ref) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (pickedFile == null) return;
      
      // show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ছবি আপলোড হচ্ছে...'), duration: Duration(seconds: 2)),
      );

      final file = File(pickedFile.path);
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.updateProfile(formData);
      
      // Refresh profile
      ref.read(authStateProvider.notifier).fetchUser();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('প্রোফাইল ছবি সফলভাবে আপডেট হয়েছে')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ছবি আপলোড ব্যর্থ হয়েছে: \$e')),
      );
    }
  }

  @override
''';
    content = content.replaceFirst('  @override\n  Widget build(BuildContext context) {', methodString + '  Widget build(BuildContext context) {');
  }

  // 3. Wrap Avatar with GestureDetector
  content = content.replaceFirst(
'''                        // Avatar
                        Container(
                          width: 90,''',
'''                        // Avatar
                        GestureDetector(
                          onTap: () => _pickAndUploadImage(context, ref),
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 90,'''
  );

  content = content.replaceFirst(
'''                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),''',
'''                                : null,
                          ),
                        ),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7C3AED),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.edit, size: 14, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),'''
  );

  // 4. Remove Location badge ("ওমান")
  content = content.replaceFirst(
'''                        const SizedBox(height: 10),
                        // Location badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_on_rounded, size: 14, color: Colors.white.withOpacity(0.7)),
                              const SizedBox(width: 4),
                              Text('ওমান', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),''',
''''''
  );

  // 5. Change _SettingsTab to ConsumerWidget to handle delete
  content = content.replaceFirst(
    'class _SettingsTab extends StatelessWidget {',
    'class _SettingsTab extends ConsumerWidget {'
  );
  content = content.replaceFirst(
    '  Widget build(BuildContext context) {',
    '  Widget build(BuildContext context, WidgetRef ref) {'
  );

  // 6. Add Delete Account button in _SettingsTab
  final deleteBtnString = '''
              Divider(height: 1, color: Colors.grey.shade100, indent: 70),
              _buildSettingsItem(
                icon: Icons.delete_forever_rounded,
                iconColor: Colors.red,
                title: 'অ্যাকাউন্ট মুছুন',
                subtitle: 'Delete Account',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('সতর্কতা!'),
                      content: const Text('আপনি কি নিশ্চিত যে আপনি আপনার অ্যাকাউন্ট মুছে ফেলতে চান? এই প্রক্রিয়াটি অপরিবর্তনীয়।'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('বাতিল'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            try {
                              final authRepo = ref.read(authRepositoryProvider);
                              await authRepo.deleteAccount();
                              await ref.read(authStateProvider.notifier).logout();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('অ্যাকাউন্ট মুছতে সমস্যা হয়েছে: \$e')),
                              );
                            }
                          },
                          child: const Text('হ্যাঁ, মুছুন', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
''';
  if (!content.contains('অ্যাকাউন্ট মুছুন')) {
    content = content.replaceFirst(
'''              _buildSettingsItem(
                icon: Icons.help_rounded,
                iconColor: const Color(0xFFF59E0B),
                title: 'সাধারণ জিজ্ঞাসা',
                subtitle: 'FAQ',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqScreen())),
              ),
            ],
          ),
        ),''',
'''              _buildSettingsItem(
                icon: Icons.help_rounded,
                iconColor: const Color(0xFFF59E0B),
                title: 'সাধারণ জিজ্ঞাসা',
                subtitle: 'FAQ',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqScreen())),
              ),
''' + deleteBtnString + '''
            ],
          ),
        ),'''
    );
  }

  file.writeAsStringSync(content);
}
