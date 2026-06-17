import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/salon_provider.dart';
import '../../models/review_model.dart';

class ManageReviewsScreen extends ConsumerWidget {
  const ManageReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsStream = ref.watch(supabaseServiceProvider).getReviews();

    return Scaffold(
      appBar: AppBar(title: const Text('Review Moderation')),
      body: StreamBuilder<List<ReviewModel>>(
        stream: reviewsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final reviews = snapshot.data ?? [];
          
          if (reviews.isEmpty) {
             return const Center(child: Text('No customer reviews yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final r = reviews[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ...List.generate(5, (i) => Icon(
                            i < r.rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          )),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.delete_sweep, color: Colors.red),
                            onPressed: () => _deleteReview(context, ref, r.id),
                            tooltip: 'Delete inappropriate review',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(r.comment, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Client: ${r.customerId}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _deleteReview(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Review?'),
        content: const Text('This will permanently delete this review from the public profile.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(supabaseServiceProvider).deleteReview(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review removed.')));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
