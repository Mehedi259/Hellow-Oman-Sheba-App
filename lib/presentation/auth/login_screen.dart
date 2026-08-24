import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_provider.dart';

import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isGoogleInitialized = false;

  @override
  void initState() {
    super.initState();
    _initGoogleSignIn();
  }

  Future<void> _initGoogleSignIn() async {
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId: '426790430741-89du8066jkn0cjkbqugq7ej6v6s5ep5v.apps.googleusercontent.com',
      );
      setState(() {
        _isGoogleInitialized = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize Google Sign In: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen(authStateProvider, (previous, next) {
      next.whenData((user) {
        if (user != null) {
          context.go('/');
        }
      });
      next.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('লগইন'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png', // Assuming logo exists based on typical structure
                height: 100,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.account_circle, size: 100, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              const Text(
                'হ্যালো ওমান সেবা অ্যাপে স্বাগতম',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'এই কাজটি করার জন্য আপনাকে লগইন করতে হবে। Google দিয়ে সহজেই লগইন করুন।',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              if (authState.isLoading || !_isGoogleInitialized)
                const CircularProgressIndicator()
              else
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();
                        if (googleUser == null) {
                          return; // The user canceled the sign-in
                        }

                        final GoogleSignInAuthentication googleAuth = googleUser.authentication;
                        final String? idToken = googleAuth.idToken;

                        if (idToken != null) {
                          ref.read(authStateProvider.notifier).loginWithGoogle(idToken);
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
                ),
            ],
          ),
        ),
      ),
    );
  }
}
