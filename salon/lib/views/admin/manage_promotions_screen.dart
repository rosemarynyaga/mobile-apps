import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/salon_provider.dart';
import '../../models/promotion_model.dart';
import 'package:intl/intl.dart';

class ManagePromotionsScreen extends ConsumerStatefulWidget {
  const ManagePromotionsScreen({super.key});

  @override
  ConsumerState<ManagePromotionsScreen> createState() => _ManagePromotionsScreenState();
}

class _ManagePromotionsScreenState extends ConsumerState<ManagePromotionsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final promotionsStream = ref.watch(supabaseServiceProvider).getPromotions();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Promotions & Discounts'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search promotions...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<PromotionModel>>(
        stream: promotionsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final promotions = snapshot.data!.where((p) => 
            p.title.toLowerCase().contains(_searchQuery) || 
            p.description.toLowerCase().contains(_searchQuery)
          ).toList();

          if (promotions.isEmpty) return const Center(child: Text('No promotions found.'));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: promotions.length,
            itemBuilder: (context, index) {
              final p = promotions[index];
              final isExpired = p.expiryDate.isBefore(DateTime.now());

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: isExpired ? Colors.grey : Colors.orange,
                    child: const Icon(Icons.campaign, color: Colors.white),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${p.discountPercentage.toInt()}% OFF',
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(p.description),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.event, size: 14, color: isExpired ? Colors.red : Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'Expires: ${DateFormat('MMM dd, yyyy').format(p.expiryDate)}',
                            style: TextStyle(
                              color: isExpired ? Colors.red : Colors.grey[700],
                              fontSize: 12,
                              fontWeight: isExpired ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showPromotionForm(context, promotion: p),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, p),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPromotionForm(context),
        label: const Text('Add Promo'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFFC2185B),
      ),
    );
  }

  void _showPromotionForm(BuildContext context, {PromotionModel? promotion}) {
    final isEditing = promotion != null;
    final titleController = TextEditingController(text: promotion?.title ?? '');
    final descController = TextEditingController(text: promotion?.description ?? '');
    final discController = TextEditingController(text: promotion?.discountPercentage.toString() ?? '');
    DateTime selectedDate = promotion?.expiryDate ?? DateTime.now().add(const Duration(days: 7));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Update Promotion' : 'Create New Promotion',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Promo Title',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: discController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Discount %',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.percent),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setModalState(() => selectedDate = date);
                          }
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC2185B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (titleController.text.isEmpty || descController.text.isEmpty || discController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill all fields')),
                        );
                        return;
                      }

                      final newPromotion = PromotionModel(
                        id: isEditing ? promotion!.id : DateTime.now().millisecondsSinceEpoch.toString(),
                        title: titleController.text,
                        description: descController.text,
                        discountPercentage: double.tryParse(discController.text) ?? 0,
                        expiryDate: selectedDate,
                      );

                      if (isEditing) {
                        ref.read(supabaseServiceProvider).updatePromotion(newPromotion);
                      } else {
                        ref.read(supabaseServiceProvider).addPromotion(newPromotion);
                      }

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(isEditing ? 'Promotion updated!' : 'Promotion published!')),
                      );
                    },
                    child: Text(
                      isEditing ? 'Update Promotion' : 'Publish Promotion',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, PromotionModel promotion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Promotion?'),
        content: Text('Are you sure you want to remove "${promotion.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(supabaseServiceProvider).deletePromotion(promotion.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Promotion deleted')));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
