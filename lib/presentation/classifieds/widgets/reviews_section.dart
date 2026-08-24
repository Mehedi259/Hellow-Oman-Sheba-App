import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/classifieds_models.dart';
import '../classifieds_detail_screens.dart'; // For classifiedsRepositoryProvider

class ReviewsSection extends ConsumerStatefulWidget {
  final String contentType;
  final int contentId;

  const ReviewsSection({super.key, required this.contentType, required this.contentId});

  @override
  ConsumerState<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends ConsumerState<ReviewsSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Reviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: _showReviewDialog,
              child: const Text('Write a Review'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<Review>>(
          future: ref.read(classifiedsRepositoryProvider).getReviews(widget.contentType, widget.contentId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Text('Error loading reviews: ${snapshot.error}');
            }
            final reviews = snapshot.data ?? [];
            if (reviews.isEmpty) {
              return const Text('No reviews yet. Be the first to review!');
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final review = reviews[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: List.generate(5, (starIndex) {
                          return Icon(
                            starIndex < review.rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                      ),
                    ],
                  ),
                  subtitle: Text(review.comment),
                );
              },
            );
          },
        ),
      ],
    );
  }

  void _showReviewDialog() {
    int rating = 5;
    final commentController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Write a Review'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setState(() {
                            rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Share your experience...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting ? null : () async {
                    if (commentController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a comment')));
                      return;
                    }
                    setState(() => isSubmitting = true);
                    try {
                      await ref.read(classifiedsRepositoryProvider).postReview(
                        widget.contentType,
                        widget.contentId,
                        rating,
                        commentController.text,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review submitted!')));
                        this.setState(() {}); // refresh reviews
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                        setState(() => isSubmitting = false);
                      }
                    }
                  },
                  child: isSubmitting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
