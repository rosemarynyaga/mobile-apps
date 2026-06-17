import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/salon_provider.dart';
import '../../models/user_model.dart';

class ManageCustomersScreen extends ConsumerStatefulWidget {
  const ManageCustomersScreen({super.key});

  @override
  ConsumerState<ManageCustomersScreen> createState() => _ManageCustomersScreenState();
}

class _ManageCustomersScreenState extends ConsumerState<ManageCustomersScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final customersStream = ref.watch(supabaseServiceProvider).getCustomers();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Management'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
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
      body: StreamBuilder<List<UserModel>>(
        stream: customersStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final customers = snapshot.data!.where((c) => 
            c.name.toLowerCase().contains(_searchQuery) || 
            c.email.toLowerCase().contains(_searchQuery)
          ).toList();

          if (customers.isEmpty) return const Center(child: Text('No customers found.'));

          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final c = customers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(child: Text(c.name[0])),
                  title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${c.email}\nPhone: ${c.phone}\nGender: ${c.gender ?? "N/A"}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.history, color: Colors.blue), 
                        onPressed: () => _viewHistory(c),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange), 
                        onPressed: () => _editCustomerDialog(context, c),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _confirmDelete(context, c),
                      ),
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

  void _viewHistory(UserModel customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Booking History: ${customer.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: 2, // Mock history
                  itemBuilder: (context, i) => ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                    title: Text(i == 0 ? 'Hair Cut' : 'Manicure'),
                    subtitle: Text(i == 0 ? 'Oct 12, 2023' : 'Sept 28, 2023'),
                    trailing: const Text('Completed'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editCustomerDialog(BuildContext context, UserModel customer) {
    final nameController = TextEditingController(text: customer.name);
    final phoneController = TextEditingController(text: customer.phone);
    final addressController = TextEditingController(text: customer.address);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Customer Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
              TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Address')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Customer profile updated!')));
              Navigator.pop(context);
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, UserModel customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer?'),
        content: Text('Are you sure you want to remove ${customer.name} from the database?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(supabaseServiceProvider).deleteCustomer(customer.uid);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
