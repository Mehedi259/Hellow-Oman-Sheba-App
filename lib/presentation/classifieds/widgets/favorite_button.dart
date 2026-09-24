import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/auth_provider.dart';
import '../../my_listings/providers/my_listings_provider.dart';

class FavoriteButton extends ConsumerStatefulWidget {
  final String contentType;
  final int contentId;
  final bool isOutlined;

  const FavoriteButton({super.key, required this.contentType, required this.contentId, this.isOutlined = false});

  @override
  ConsumerState<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends ConsumerState<FavoriteButton> {
  bool isFavorite = false;
  int? favoriteId;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final favorites = await ref.read(authRepositoryProvider).getFavorites();
      for (var fav in favorites) {
        if (fav['favorite_type']?.toString() == widget.contentType.toString() &&
            fav['favorite_id']?.toString() == widget.contentId.toString()) {
          if (mounted) {
            setState(() {
              isFavorite = true;
              favoriteId = fav['id'];
            });
          }
          break;
        }
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _toggleFavorite() async {
    if (isFavorite && favoriteId != null) {
      // Remove
      try {
        await ref.read(authRepositoryProvider).removeFavorite(favoriteId!);
        if (!mounted) return;
        setState(() {
          isFavorite = false;
          favoriteId = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed from favorites')));
        ref.invalidate(myFavoritesProvider);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } else {
      // Add
      try {
        await ref.read(authRepositoryProvider).addFavorite(widget.contentType, widget.contentId);
        if (!mounted) return;
        setState(() {
          isFavorite = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to favorites')));
        ref.invalidate(myFavoritesProvider);
        _checkFavoriteStatus(); // To get the new ID
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isOutlined) {
      return OutlinedButton(
        onPressed: _toggleFavorite,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: isFavorite ? Colors.red : Colors.grey.shade700,
        ),
      );
    }
    
    return IconButton(
      icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
      color: isFavorite ? Colors.red : null,
      onPressed: _toggleFavorite,
    );
  }
}
