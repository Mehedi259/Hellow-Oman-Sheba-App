import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/news_article.dart';
import 'news_image_widget.dart';

class NewsDetailScreenNew extends StatelessWidget {
  final NewsArticle article;
  const NewsDetailScreenNew({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: CustomScrollView(
        slivers: [
          // ---- AppBar with image ----
          SliverAppBar(
            expandedHeight: article.image.isNotEmpty ? 300 : 100,
            pinned: true,
            backgroundColor: const Color(0xFF8B0000),
            iconTheme: const IconThemeData(color: Colors.white),
            systemOverlayStyle: SystemUiOverlayStyle.light,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                      fit: StackFit.expand,
                      children: [
                        NewsImageWidget(
                          article: article,
                          fit: BoxFit.cover,
                        ),
                        // Dark gradient overlay
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black87],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded),
                onPressed: () {
                  // Share functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('শেয়ার করা হচ্ছে...')),
                  );
                },
              ),
            ],
          ),

          // ---- Content ----
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- Newspaper name / header ----
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCC0000),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'হ্যালো ওমান',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCC0000).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFCC0000).withOpacity(0.4)),
                        ),
                        child: Text(
                          article.category,
                          style: const TextStyle(color: Color(0xFFCC0000), fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ---- Title ----
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A1A2E),
                      height: 1.4,
                      letterSpacing: -0.3,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ---- Divider line (newspaper style) ----
                  Row(
                    children: [
                      Container(width: 4, height: 20, color: const Color(0xFFCC0000)),
                      const SizedBox(width: 8),
                      Expanded(child: Container(height: 1.5, color: const Color(0xFFCC0000).withOpacity(0.3))),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ---- Meta info ----
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 15, color: Color(0xFF888888)),
                      const SizedBox(width: 5),
                      Text(article.date,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF888888))),
                      if (article.reporter != null && article.reporter!.isNotEmpty) ...[
                        const SizedBox(width: 14),
                        const Icon(Icons.person_outline_rounded, size: 15, color: Color(0xFF888888)),
                        const SizedBox(width: 5),
                        Text(article.reporter!,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF888888))),
                      ],
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ---- Excerpt (lead) ----
                  if (article.excerpt != null && article.excerpt!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCC0000).withOpacity(0.04),
                        borderRadius: BorderRadius.circular(10),
                        border: Border(left: BorderSide(color: const Color(0xFFCC0000), width: 4)),
                      ),
                      child: Text(
                        article.excerpt!,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF333333),
                          fontStyle: FontStyle.italic,
                          height: 1.7,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // ---- Full content ----
                  if (article.content != null && article.content!.isNotEmpty)
                    _buildContent(article.content!),

                  const SizedBox(height: 40),

                  // ---- Footer ----
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFFCC0000),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(child: Text('হ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20))),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('হ্যালো ওমান', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                            Text('প্রবাসীদের বিশ্বস্ত সংবাদ মাধ্যম',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(String content) {
    // Split content into paragraphs for newspaper-style rendering
    final paragraphs = content.split('\n').where((p) => p.trim().isNotEmpty).toList();
    if (paragraphs.isEmpty) {
      return Text(
        content,
        style: const TextStyle(fontSize: 16, color: Color(0xFF2D2D2D), height: 1.8),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.map((para) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(
            para.trim(),
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF2D2D2D),
              height: 1.8,
            ),
            textAlign: TextAlign.justify,
          ),
        );
      }).toList(),
    );
  }
}
