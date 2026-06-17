import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/salon_provider.dart';
import 'add_service_screen.dart';

class ManageServicesScreen extends ConsumerStatefulWidget {
  const ManageServicesScreen({super.key});

  @override
  ConsumerState<ManageServicesScreen> createState() => _ManageServicesScreenState();
}

class _ManageServicesScreenState extends ConsumerState<ManageServicesScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(servicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Services'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search services...',
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
      body: servicesAsync.when(
        data: (services) {
          final filteredServices = services.where((s) => 
            s.name.toLowerCase().contains(_searchQuery) || 
            s.category.toLowerCase().contains(_searchQuery)
          ).toList();

          if (filteredServices.isEmpty) return const Center(child: Text('No services found.'));

          return ListView.builder(
            itemCount: filteredServices.length,
            itemBuilder: (context, index) {
              final service = filteredServices[index];
              return ListTile(
                title: Text(service.name),
                subtitle: Text('${service.price} KES'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => ref.read(supabaseServiceProvider).deleteService(service.id),
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AddServiceScreen(service: service)));
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddServiceScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
