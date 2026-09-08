import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../data/repositories/news_repository.dart';
import '../../data/models/news_article.dart';
import 'news_detail_screen_new.dart';

const List<String> _categories = [
  'সর্বশেষ', 'প্রবাস', 'বাংলাদেশ', 'আন্তর্জাতিক',
  'মধ্যপ্রাচ্য', 'রাজনীতি', 'অর্থনীতি', 'খেলাধুলা', 'বিনোদন',
];

const Map<String, Color> _categoryColors = {
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

Color _getCategoryColor(String cat) =>
    _categoryColors[cat] ?? const Color(0xFFCC0000);

class NewsFeedScreen extends ConsumerStatefulWidget {
  final String? initialCategory;
  const NewsFeedScreen({super.key, this.initialCategory});

  @override
  ConsumerState<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends ConsumerState<NewsFeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.initialCategory != null
        ? (_categories.indexOf(widget.initialCategory!).clamp(0, _categories.length - 1))
        : 0;
    _tabController = TabController(length: _categories.length, vsync: this, initialIndex: initialIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            floating: true,
            snap: true,
            expandedHeight: 0,
            backgroundColor: const Color(0xFF8B0000),
            foregroundColor: Colors.white,
            elevation: 0,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: const Text('HD', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
                const SizedBox(width: 10),
                const Text(
                  'হ্যালো ওমান সংবাদ',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.3),
                ),
              ],
            ),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: Colors.amber,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 0.3),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
              dividerColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              tabs: _categories.map((cat) {
                final color = _getCategoryColor(cat);
                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6, height: 6,
                        decoration: BoxDecoration(color: color == const Color(0xFFCC0000) ? Colors.amber : color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 5),
                      Text(cat),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: _categories.map((cat) => _NewsTabBody(category: cat)).toList(),
        ),
      ),
    );
  }
}

// ============================================================
// Per-tab body
// ============================================================
class _NewsTabBody extends ConsumerWidget {
  final String category;
  const _NewsTabBody({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsByCategory(category));

    return newsAsync.when(
      data: (articles) {
        if (articles.isEmpty) return _buildEmpty(category);
        return RefreshIndicator(
          color: const Color(0xFFCC0000),
          onRefresh: () async => ref.invalidate(newsByCategory(category)),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              if (index == 0) return _HeroCard(article: articles[0]);
              if (index == 1 && articles.length > 2) {
                return _TwoColumnRow(
                  left: articles[1],
                  right: articles.length > 2 ? articles[2] : null,
                );
              }
              if (index == 2 && articles.length > 2) return const SizedBox.shrink();
              return _ListCard(article: articles[index]);
            },
          ),
        );
      },
      loading: () => _buildShimmer(),
      error: (e, _) => _buildError(ref, category),
    );
  }

  Widget _buildEmpty(String category) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFCC0000).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.newspaper_rounded, size: 40, color: Color(0xFFCC0000)),
          ),
          const SizedBox(height: 16),
          Text('$category বিভাগে কোনো সংবাদ নেই',
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE5E7EB),
      highlightColor: const Color(0xFFF9FAFB),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
        children: [
          _shimmerBox(height: 240, radius: 16),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _shimmerBox(height: 180, radius: 12)),
            const SizedBox(width: 10),
            Expanded(child: _shimmerBox(height: 180, radius: 12)),
          ]),
          const SizedBox(height: 14),
          for (int i = 0; i < 4; i++) ...[
            _shimmerListItem(),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _shimmerBox({required double height, double radius = 8}) {
    return Container(
      height: height,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(radius)),
    );
  }

  Widget _shimmerListItem() {
    return Container(
      height: 96,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(width: 72, height: 72, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(height: 12, width: double.infinity, color: Colors.grey.shade200),
                Container(height: 12, width: double.infinity, color: Colors.grey.shade200),
                Container(height: 10, width: 100, color: Colors.grey.shade200),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(WidgetRef ref, String category) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 56, color: Color(0xFF9CA3AF)),
          const SizedBox(height: 16),
          const Text('নিউজ লোড করতে সমস্যা হয়েছে',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 15)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => ref.invalidate(newsByCategory(category)),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('আবার চেষ্টা করুন'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCC0000),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Hero Card (first article - large featured)
// ============================================================
class _HeroCard extends StatelessWidget {
  final NewsArticle article;
  const _HeroCard({required this.article});

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor(article.category);
    return GestureDetector(
      onTap: () => Navigator.push(context, _slide(NewsDetailScreenNew(article: article))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: Stack(
                children: [
                  _NewsImage(article: article, height: 230),
                  // Gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.transparent, Color(0xCC000000)],
                        ),
                      ),
                    ),
                  ),
                  // Category badge on image
                  Positioned(
                    top: 12, left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: catColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: catColor.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Text(article.category,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                    ),
                  ),
                  // Breaking tag if first
                  Positioned(
                    top: 12, right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('শীর্ষ খবর', style: TextStyle(color: Color(0xFF1A1A2E), fontSize: 10, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF111827), height: 1.45, letterSpacing: -0.2),
                  ),
                  if (article.excerpt != null && article.excerpt!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      article.excerpt!,
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13.5, color: Color(0xFF6B7280), height: 1.55),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _MetaRow(article: article),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Two-column row (2nd and 3rd articles)
// ============================================================
class _TwoColumnRow extends StatelessWidget {
  final NewsArticle left;
  final NewsArticle? right;
  const _TwoColumnRow({required this.left, this.right});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _SmallCard(article: left)),
          if (right != null) ...[const SizedBox(width: 10), Expanded(child: _SmallCard(article: right!))],
        ],
      ),
    );
  }
}

class _SmallCard extends StatelessWidget {
  final NewsArticle article;
  const _SmallCard({required this.article});

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor(article.category);
    return GestureDetector(
      onTap: () => Navigator.push(context, _slide(NewsDetailScreenNew(article: article))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Stack(
                children: [
                  _NewsImage(article: article, height: 120),
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(color: catColor, borderRadius: BorderRadius.circular(12)),
                      child: Text(article.category,
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(article.title,
                      maxLines: 3, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF111827), height: 1.4)),
                  const SizedBox(height: 8),
                  Text(article.date,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// List Card (remaining articles)
// ============================================================
class _ListCard extends StatelessWidget {
  final NewsArticle article;
  const _ListCard({required this.article});

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor(article.category);
    return GestureDetector(
      onTap: () => Navigator.push(context, _slide(NewsDetailScreenNew(article: article))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _NewsImage(article: article, height: 90, width: 90),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: catColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: catColor.withOpacity(0.25)),
                        ),
                        child: Text(article.category,
                            style: TextStyle(color: catColor, fontSize: 10, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    article.title,
                    maxLines: 3, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827), height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  _MetaRow(article: article, small: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Meta row (date + reporter)
// ============================================================
class _MetaRow extends StatelessWidget {
  final NewsArticle article;
  final bool small;
  const _MetaRow({required this.article, this.small = false});

  @override
  Widget build(BuildContext context) {
    final size = small ? 11.0 : 12.0;
    return Row(
      children: [
        const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF9CA3AF)),
        const SizedBox(width: 4),
        Text(article.date, style: TextStyle(fontSize: size, color: const Color(0xFF9CA3AF))),
        if (article.reporter != null && article.reporter!.isNotEmpty) ...[
          const SizedBox(width: 10),
          const Icon(Icons.person_outline_rounded, size: 13, color: Color(0xFF9CA3AF)),
          const SizedBox(width: 3),
          Flexible(
            child: Text(article.reporter!,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: size, color: const Color(0xFF9CA3AF))),
          ),
        ],
      ],
    );
  }
}

// ============================================================
// News Image — supports base64 & URL, with shimmer placeholder
// ============================================================
class _NewsImage extends StatelessWidget {
  final NewsArticle article;
  final double height;
  final double? width;

  const _NewsImage({required this.article, required this.height, this.width});

  @override
  Widget build(BuildContext context) {
    final w = width ?? double.infinity;

    if (article.image.isEmpty) return _placeholder(w);

    if (article.image.startsWith('data:image')) {
      try {
        final base64Str = article.image.split(',').last;
        final bytes = base64Decode(base64Str);
        return Image.memory(bytes, height: height, width: w, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholder(w));
      } catch (_) {
        return _placeholder(w);
      }
    }

    final url = article.image.startsWith('http')
        ? article.image
        : 'http://46.225.103.236:8000${article.image}';

    return Image.network(url, height: height, width: w, fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Shimmer.fromColors(
            baseColor: const Color(0xFFE5E7EB),
            highlightColor: const Color(0xFFF9FAFB),
            child: Container(height: height, width: w, color: Colors.white),
          );
        },
        errorBuilder: (_, __, ___) => _placeholder(w));
  }

  Widget _placeholder(double w) {
    return Container(
      height: height, width: w,
      color: const Color(0xFFF3F4F6),
      child: const Center(child: Icon(Icons.newspaper_rounded, color: Color(0xFFD1D5DB), size: 32)),
    );
  }
}

// ============================================================
// Navigation helper
// ============================================================
PageRouteBuilder _slide(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}
