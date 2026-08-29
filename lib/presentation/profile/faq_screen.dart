import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('সাধারণ জিজ্ঞাসা (FAQ)'),
        backgroundColor: const Color(0xFF9333EA),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: const [
          ExpansionTile(
            title: Text('অ্যাকাউন্ট কীভাবে খুলবো?', style: TextStyle(fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('প্রোফাইল আইকনে ক্লিক করে "লগইন/রেজিস্টার" অপশন বেছে নিন। আপনি আপনার গুগল অ্যাকাউন্ট ব্যবহার করে সহজেই অ্যাকাউন্ট খুলতে পারবেন।'),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('আমি কি পাসওয়ার্ড পরিবর্তন করতে পারবো?', style: TextStyle(fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('হ্যাঁ, প্রোফাইল সেকশনের "পাসওয়ার্ড" ট্যাবে গিয়ে আপনার পুরানো এবং নতুন পাসওয়ার্ড দিয়ে পরিবর্তন করতে পারবেন।'),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('পছন্দের তালিকা (Favorites) কিভাবে কাজ করে?', style: TextStyle(fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('যে কোনো চাকরি বা মার্কেট আইটেম দেখার সময় হার্ট (♡) আইকনে ক্লিক করলে তা আপনার পছন্দের তালিকায় যুক্ত হবে। পরে প্রোফাইলের "পছন্দ" ট্যাব থেকে সেগুলো সহজেই দেখতে পারবেন।'),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('আমি কিভাবে আমার পোস্ট মুছে ফেলবো?', style: TextStyle(fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('প্রোফাইলের "আমার পোস্ট" ট্যাবে যান। সেখানে আপনার করা সমস্ত পোস্ট দেখতে পাবেন এবং ডিলিট (Delete) আইকনে ক্লিক করে সেগুলো মুছে ফেলতে পারবেন।'),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('মার্কেটপ্লেসে কিছু বিক্রি করতে চাই, কী করতে হবে?', style: TextStyle(fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('নিচের মেনু থেকে "+" (প্লাস) আইকনে ক্লিক করে আপনি নতুন পণ্য বিক্রির বিজ্ঞাপন বা চাকরির পোস্ট দিতে পারবেন। প্রয়োজনীয় তথ্য ও ছবি দিয়ে সাবমিট করলেই পোস্টটি লাইভ হয়ে যাবে।'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
