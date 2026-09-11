import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/news_article.dart';
import '../../news/news_detail_screen_new.dart';
import 'section_header.dart';

class LatestNewsWidget extends StatelessWidget {
  final List<NewsArticle> articles;

  const LatestNewsWidget({super.key, required this.articles});

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) return const SizedBox();

    // Display max 8 articles for the horizontal list
    final displayArticles = articles.length > 8 ? articles.sublist(0, 8) : articles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'সংবাদ',
          subtitle: 'হ্যালো ওমান সর্বশেষ খবর',
          icon: Icons.newspaper_outlined,
          color: const Color(0xFFCC0000), // Red color
          onSeeAllPressed: () {
            context.push('/news');
          },
        ),
        SizedBox(
          height: 250, // Height for the horizontal list
          child: _AutoScrollingNewsList(articles: displayArticles),
        ),
      ],
    );
  }
}

class _AutoScrollingNewsList extends StatefulWidget {
  final List<NewsArticle> articles;

  const _AutoScrollingNewsList({required this.articles});

  @override
  State<_AutoScrollingNewsList> createState() => _AutoScrollingNewsListState();
}

class _AutoScrollingNewsListState extends State<_AutoScrollingNewsList> {
  final PageController _pageController = PageController(viewportFraction: 0.55);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        if (_pageController.position.pixels >= _pageController.position.maxScrollExtent - 10) {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      padEnds: false,
      itemCount: widget.articles.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: _HomeNewsCard(article: widget.articles[index]),
        );
      },
    );
  }
}

class _HomeNewsCard extends StatelessWidget {
  final NewsArticle article;
  const _HomeNewsCard({required this.article});

  Color _getCategoryColor(String cat) {
    const Map<String, Color> colors = {
      'প্রবাস': Color(0xFF1565C0),
      'বাংলাদেশ': Color(0xFF2E7D32),
      'আন্তর্জাতিক': Color(0xFF6A1B9A),
      'মধ্যপ্রাচ্য': Color(0xFF00695C),
      'রাজনীতি': Color(0xFFB71C1C),
      'অর্থনীতি': Color(0xFF1B5E20),
      'খেলাধুলা': Color(0xFFE65100),
      'বিনোদন': Color(0xFF880E4F),
      'সর্বশেষ': Color(0xFFCC0000),
    };
    return colors[cat] ?? const Color(0xFFCC0000);
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor(article.category);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewsDetailScreenNew(article: article)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Stack(
                children: [
                  _HomeNewsImage(article: article, height: 110),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: catColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        article.category,
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      article.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF111827), height: 1.4),
                    ),
                    Text(
                      article.date,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeNewsImage extends StatelessWidget {
  final NewsArticle article;
  final double height;
  final double? width;

  const _HomeNewsImage({required this.article, required this.height, this.width});

  @override
  Widget build(BuildContext context) {
    final w = width ?? double.infinity;

    if (article.image.isEmpty) return _placeholder(w);

    if (article.image.startsWith('data:image')) {
      try {
        final base64Str = article.image.split(',').last;
        final bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          height: height,
          width: w,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(w),
        );
      } catch (_) {
        return _placeholder(w);
      }
    }

    final url = article.image.startsWith('http')
        ? article.image
        : 'https://helloomanbangla.com${article.image}';

    return CachedNetworkImage(
      imageUrl: url,
      height: height,
      width: w,
      fit: BoxFit.cover,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: const Color(0xFFE5E7EB),
        highlightColor: const Color(0xFFF9FAFB),
        child: Container(height: height, width: w, color: Colors.white),
      ),
      errorWidget: (context, url, error) => _placeholder(w),
    );
  }

  Widget _placeholder(double w) {
    return Container(
      height: height,
      width: w,
      color: const Color(0xFFF3F4F6),
      child: const Center(
        child: Icon(Icons.newspaper_rounded, color: Color(0xFFD1D5DB), size: 32),
      ),
    );
  }
}
