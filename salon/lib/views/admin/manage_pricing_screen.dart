import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/salon_provider.dart';

class ManagePricingScreen extends ConsumerWidget {
  const ManagePricingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Pricing')),
      body: servicesAsync.when(
        data: (services) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final s = services[index];
            return Card(
              child: ListTile(
                title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Category: ${s.category}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${s.price} KES', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC2185B))),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _updatePriceDialog(context, ref, s.id, s.name, s.price),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _updatePriceDialog(BuildContext context, WidgetRef ref, String id, String name, double currentPrice) {
    final controller = TextEditingController(text: currentPrice.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Price: $name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'New Price (KES)', suffixText: 'KES'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newPrice = double.tryParse(controller.text);
              if (newPrice != null) {
                ref.read(supabaseServiceProvider).updateServicePrice(id, newPrice);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Price updated for $name')));
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
