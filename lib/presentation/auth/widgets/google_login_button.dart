import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../auth_provider.dart';

class GoogleLoginButton extends ConsumerWidget {
  final VoidCallback? onSuccess;

  const GoogleLoginButton({super.key, this.onSuccess});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () async {
          try {
            final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();
            if (googleUser == null) {
              return; // User canceled the sign-in
            }

            final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
            final String? idToken = googleAuth.idToken;

            if (idToken != null) {
              await ref.read(authStateProvider.notifier).loginWithGoogle(idToken);
              if (onSuccess != null) {
                onSuccess!();
              }
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Google থেকে টোকেন পাওয়া যায়নি')),
                );
              }
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Google লগইন ব্যর্থ হয়েছে: $e')),
              );
            }
          }
        },
        icon: Image.network(
          'https://developers.google.com/identity/images/g-logo.png',
          height: 24,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, color: Colors.blue),
        ),
        label: const Text(
          'Continue with Google',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }
}
