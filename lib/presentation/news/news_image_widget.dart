import 'package:flutter/material.dart';
import '../../data/models/news_article.dart';

/// Renders a news image supporting both base64 and URL formats
class NewsImageWidget extends StatelessWidget {
  final NewsArticle article;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const NewsImageWidget({
    super.key,
    required this.article,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  Widget _placeholder() {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: Icon(Icons.newspaper_rounded, color: Color(0xFFCCCCCC), size: 40),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget image;

    if (article.image.isEmpty) {
      return _placeholder();
    }

    if (article.isBase64Image) {
      final bytes = article.base64Bytes;
      if (bytes == null) return _placeholder();
      image = Image.memory(
        bytes,
        height: height,
        width: width ?? double.infinity,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    } else {
      final url = article.image.startsWith('http')
          ? article.image
          : 'http://46.225.103.236:8000${article.image}';
      image = Image.network(
        url,
        height: height,
        width: width ?? double.infinity,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}
