import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('শর্তাবলী (Terms & Conditions)'),
        backgroundColor: const Color(0xFF9333EA),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'শর্তাবলী',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              '১. সেবার ব্যবহার\nHello Oman Sheba অ্যাপটি ব্যবহার করার মাধ্যমে আপনি আমাদের শর্তাবলীর সাথে সম্মত হচ্ছেন। আপনি সম্মতি না দিলে অনুগ্রহ করে আমাদের অ্যাপটি ব্যবহার করা থেকে বিরত থাকুন।',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              '২. ব্যবহারকারীর দায়িত্ব\nআপনি সম্মতি দিচ্ছেন যে অ্যাপের মাধ্যমে বেআইনি, মানহানিকর বা ক্ষতিকর কোনো কনটেন্ট পোস্ট বা শেয়ার করবেন না। যেকোনো ধরনের অপব্যবহারের জন্য অ্যাকাউন্ট স্থগিত করা হতে পারে।',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              '৩. মেধা সম্পদ (Intellectual Property)\nঅ্যাপের সমস্ত ডিজাইন, টেক্সট, গ্রাফিক্স, এবং কোড Hello Oman Sheba-এর মালিকানাধীন। আমাদের পূর্বানুমতি ছাড়া এগুলোর বাণিজ্যিক ব্যবহার সম্পূর্ণ নিষিদ্ধ।',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              '৪. থার্ড পার্টি লিংক\nঅ্যাপে থাকা বিভিন্ন লিংক বা বিজ্ঞাপন অন্যান্য ওয়েবসাইটে নিয়ে যেতে পারে। সেই ওয়েবসাইটগুলোর কনটেন্ট বা শর্তাবলীর জন্য আমরা দায়ী নই।',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              '৫. শর্তাবলী সংশোধন\nআমরা যেকোনো সময় এই শর্তাবলী আপডেট করার অধিকার রাখি। সংশোধিত শর্তাবলী অ্যাপে প্রকাশিত হওয়ার পর থেকেই কার্যকর বলে গণ্য হবে।',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
