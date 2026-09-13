import 'package:flutter/material.dart';
import 'google_login_button.dart';

class LoginPromptWidget extends StatelessWidget {
  final String message;

  const LoginPromptWidget({
    Key? key,
    this.message = 'এই ফিচারটি ব্যবহার করতে\\nলগইন করুন',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFFF8FAFC), Color(0xFFEDE9FE)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFDB2777)]),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withOpacity(0.25),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    )
                  ],
                ),
                child: const Icon(Icons.person_rounded, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 32),
              const Text(
                'স্বাগতম!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              GoogleLoginButton(onSuccess: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
