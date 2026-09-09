import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
          : 'https://helloomanbangla.com${article.image}';
      image = CachedNetworkImage(
        imageUrl: url,
        height: height,
        width: width ?? double.infinity,
        fit: fit,
        placeholder: (context, url) => _placeholder(),
        errorWidget: (context, url, error) => _placeholder(),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}
