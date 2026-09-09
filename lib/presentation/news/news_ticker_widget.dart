import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/news_repository.dart';
import '../../data/models/news_article.dart';
import '../news/news_feed_screen.dart';
import '../news/news_detail_screen_new.dart';

class NewsTickerWidget extends ConsumerStatefulWidget {
  const NewsTickerWidget({super.key});

  @override
  ConsumerState<NewsTickerWidget> createState() => _NewsTickerWidgetState();
}

class _NewsTickerWidgetState extends ConsumerState<NewsTickerWidget> {
  late ScrollController _scrollController;
  Timer? _timer;
  double _scrollPosition = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!mounted || !_scrollController.hasClients) return;
      final maxScroll = _scrollController.position.maxScrollExtent;
      if (maxScroll <= 0) return;
      _scrollPosition += 0.8;
      if (_scrollPosition >= maxScroll) {
        _scrollPosition = 0;
        _scrollController.jumpTo(0);
      } else {
        _scrollController.jumpTo(_scrollPosition);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final newsAsync = ref.watch(allNewsProvider);

    return newsAsync.when(
      data: (newsList) {
        if (newsList.isEmpty) return const SizedBox.shrink();
        return _buildTicker(newsList);
      },
      loading: () => _buildTickerSkeleton(),
      error: (e, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildTicker(List<NewsArticle> newsList) {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFCC0000), Color(0xFFFF1A1A)],
        ),
      ),
      child: Row(
        children: [
          // "সর্বশেষ" label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: double.infinity,
            color: const Color(0xFF880000), // Original dark red
            child: const Center(
              child: Text(
                '📰 সর্বশেষ',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          // Vertical divider
          Container(width: 2, color: Colors.white24),
          // Scrolling news
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (_) => true, // Block scroll bubbling
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: newsList.length * 3, // repeat for infinite feel
                itemBuilder: (context, index) {
                  final article = newsList[index % newsList.length];
                  return GestureDetector(
                    onTap: () {
                      _timer?.cancel();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => NewsDetailScreenNew(article: article)),
                      ).then((_) => _startAutoScroll());
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          const Text('■ ', style: TextStyle(color: Colors.yellow, fontSize: 8)),
                          Text(
                            article.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.visible,
                          ),
                          const SizedBox(width: 32),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTickerSkeleton() {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFCC0000), Color(0xFFFF1A1A)],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: const Color(0xFF880000),
            child: const Center(
              child: Text('📰 সর্বশেষ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
            ),
          ),
          const SizedBox(width: 2),
          const Expanded(
            child: Center(
              child: SizedBox(height: 12, width: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
