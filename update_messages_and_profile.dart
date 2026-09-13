import 'dart:io';

void main() {
  final profileFile = File('/Users/mehedihasanmridul/app/Hellow-Oman-Sheba-App/lib/presentation/profile/profile_screen.dart');
  var profileContent = profileFile.readAsStringSync();

  // Replace _buildLoginPrompt() in profile_screen.dart with LoginPromptWidget
  if (!profileContent.contains('import \'../auth/widgets/login_prompt_widget.dart\';')) {
    profileContent = profileContent.replaceFirst(
      'import \'../auth/widgets/google_login_button.dart\';',
      "import '../auth/widgets/google_login_button.dart';\nimport '../auth/widgets/login_prompt_widget.dart';"
    );
  }

  profileContent = profileContent.replaceFirst(
    'return _buildLoginPrompt();',
    "return const LoginPromptWidget(message: 'প্রোফাইল দেখতে ও সব ফিচার ব্যবহার করতে\\nলগইন করুন');"
  );

  // We can just keep _buildLoginPrompt around or remove it. Let's remove it.
  final regex = RegExp(r'Widget _buildLoginPrompt\(\) \{[\s\S]*?\}\n\n\s*SliverAppBar _buildProfileHeader');
  profileContent = profileContent.replaceFirstMapped(regex, (match) {
    return 'SliverAppBar _buildProfileHeader';
  });
  profileFile.writeAsStringSync(profileContent);

  // Now update messages_screen.dart
  final messagesFile = File('/Users/mehedihasanmridul/app/Hellow-Oman-Sheba-App/lib/presentation/messages/messages_screen.dart');
  var messagesContent = messagesFile.readAsStringSync();

  if (!messagesContent.contains('import \'../auth/widgets/login_prompt_widget.dart\';')) {
    messagesContent = messagesContent.replaceFirst(
      'import \'../auth/auth_provider.dart\';',
      "import '../auth/auth_provider.dart';\nimport '../auth/widgets/login_prompt_widget.dart';"
    );
  }

  // Need to read authStateProvider
  if (!messagesContent.contains('final authState = ref.watch(authStateProvider);')) {
    messagesContent = messagesContent.replaceFirst(
      'final conversationsAsync = ref.watch(conversationsProvider);',
      "final conversationsAsync = ref.watch(conversationsProvider);\n    final authState = ref.watch(authStateProvider);"
    );
  }

  // Check auth state
  if (!messagesContent.contains('if (user == null) {')) {
    messagesContent = messagesContent.replaceFirst(
      '      body: conversationsAsync.when(',
      '''      body: authState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: \$e')),
        data: (user) {
          if (user == null) {
            return const LoginPromptWidget(message: 'মেসেজ দেখতে ও অন্যান্য ফিচার ব্যবহার করতে\\nলগইন করুন');
          }
          return conversationsAsync.when('''
    );

    // close the extra brace
    messagesContent = messagesContent.replaceFirst(
      '''      ),
    );
  }
}''',
      '''          );
        },
      ),
    );
  }
}'''
    );
  }

  messagesFile.writeAsStringSync(messagesContent);
}
