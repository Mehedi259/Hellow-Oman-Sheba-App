import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/system_models.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class HeroSliderWidget extends StatefulWidget {
  final List<SliderItem> sliders;

  const HeroSliderWidget({super.key, required this.sliders});

  @override
  State<HeroSliderWidget> createState() => _HeroSliderWidgetState();
}

class _HeroSliderWidgetState extends State<HeroSliderWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.sliders.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
        if (_currentPage < widget.sliders.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _launchUrl(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sliders.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: AspectRatio(
        aspectRatio: 2.2,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: widget.sliders.length,
                itemBuilder: (context, index) {
                  final slider = widget.sliders[index];
                  final imageUrl = slider.imageUrl.startsWith('http')
                      ? slider.imageUrl
                      : 'http://188.245.212.240${slider.imageUrl}';

                  return GestureDetector(
                    onTap: () => _launchUrl(slider.link),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.fill,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(color: Colors.white),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          if (widget.sliders.length > 1)
            Positioned(
              bottom: 12,
              right: 16,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.sliders.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 6,
                    width: _currentPage == index ? 24 : 6,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
      ),
    );
  }
}
