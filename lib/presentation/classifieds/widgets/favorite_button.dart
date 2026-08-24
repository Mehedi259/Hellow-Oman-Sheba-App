import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/auth_provider.dart';

class FavoriteButton extends ConsumerStatefulWidget {
  final String contentType;
  final int contentId;

  const FavoriteButton({super.key, required this.contentType, required this.contentId});

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
        if (fav['content_type'] == widget.contentType && fav['content_id'] == widget.contentId) {
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
        setState(() {
          isFavorite = false;
          favoriteId = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed from favorites')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } else {
      // Add
      try {
        await ref.read(authRepositoryProvider).addFavorite(widget.contentType, widget.contentId);
        setState(() {
          isFavorite = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to favorites')));
        _checkFavoriteStatus(); // To get the new ID
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
      color: isFavorite ? Colors.red : null,
      onPressed: _toggleFavorite,
    );
  }
}
