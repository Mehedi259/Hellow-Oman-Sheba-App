import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('গোপনীয়তা নীতি (Privacy Policy)'),
        backgroundColor: const Color(0xFF9333EA),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'গোপনীয়তা নীতি',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              '১. তথ্য সংগ্রহ\nআমরা আপনার অ্যাকাউন্ট খোলার সময় আপনার নাম, ইমেইল এবং ফোন নম্বর সংগ্রহ করি। আপনার পছন্দ ও ব্রাউজিং অভিজ্ঞতা উন্নত করতে কুকিজ এবং অন্যান্য তথ্য ব্যবহার করা হতে পারে।',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              '২. তথ্যের ব্যবহার\nআপনার তথ্য শুধুমাত্র আমাদের সেবা প্রদান, সহায়তা প্রদান এবং সিস্টেমের উন্নয়নের জন্য ব্যবহৃত হবে। আমরা আপনার তথ্য তৃতীয় কোনো পক্ষের সাথে শেয়ার করি না, যদি না তা আইনি কারণে প্রয়োজন হয়।',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              '৩. তথ্য নিরাপত্তা\nআপনার ব্যক্তিগত তথ্য সুরক্ষিত রাখতে আমরা বিভিন্ন নিরাপত্তা ব্যবস্থা গ্রহণ করেছি। তবে ইন্টারনেটের মাধ্যমে ডেটা আদান-প্রদান ১০০% নিরাপদ নয়, তাই আমরা পুরোপুরি গ্যারান্টি দিতে পারি না।',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              '৪. নীতিমালা পরিবর্তন\nHello Oman Sheba যেকোনো সময় এই নীতিমালার পরিবর্তন বা সংশোধন করার অধিকার সংরক্ষণ করে। যেকোনো পরিবর্তনের পর আপডেট এই পেজে প্রকাশ করা হবে।',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              '৫. যোগাযোগ\nআপনার যদি এই গোপনীয়তা নীতি সম্পর্কে কোনো প্রশ্ন থাকে, তবে অনুগ্রহ করে আমাদের সাপোর্ট টিমের সাথে যোগাযোগ করুন।',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
