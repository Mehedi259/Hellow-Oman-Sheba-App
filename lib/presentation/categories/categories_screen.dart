import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('সকল ক্যাটাগরি'),
      ),
      body: const Center(
        child: Text('ক্যাটাগরি পেজ (শীঘ্রই আসছে...)'),
      ),
    );
  }
}
