import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/salon_provider.dart';
import '../../models/staff_model.dart';

class ManageStaffScreen extends ConsumerStatefulWidget {
  const ManageStaffScreen({super.key});

  @override
  ConsumerState<ManageStaffScreen> createState() => _ManageStaffScreenState();
}

class _ManageStaffScreenState extends ConsumerState<ManageStaffScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final staffAsync = ref.watch(staffProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Staff'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search staff by name or position...',
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
      body: staffAsync.when(
        data: (staff) {
          final filteredStaff = staff.where((s) => 
            s.name.toLowerCase().contains(_searchQuery) || 
            s.position.toLowerCase().contains(_searchQuery)
          ).toList();

          if (filteredStaff.isEmpty) {
            return const Center(child: Text('No staff members found.'));
          }

          return ListView.builder(
            itemCount: filteredStaff.length,
            itemBuilder: (context, index) {
              final s = filteredStaff[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(child: Text(s.name[0])),
                  title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${s.position}\n${s.specialization}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.calendar_today, color: Colors.blue),
                        onPressed: () => _assignSchedule(context, s),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _addEditStaffDialog(context, ref, staff: s),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => ref.read(supabaseServiceProvider).deleteStaff(s.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addEditStaffDialog(context, ref),
        label: const Text('Add Staff'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _addEditStaffDialog(BuildContext context, WidgetRef ref, {StaffModel? staff}) {
    final nameController = TextEditingController(text: staff?.name);
    final posController = TextEditingController(text: staff?.position);
    final specController = TextEditingController(text: staff?.specialization);
    final phoneController = TextEditingController(text: staff?.phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(staff == null ? 'Add Staff Member' : 'Edit Staff Member'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full Name')),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
              TextField(controller: posController, decoration: const InputDecoration(labelText: 'Position')),
              TextField(controller: specController, decoration: const InputDecoration(labelText: 'Specialization')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newStaff = StaffModel(
                id: staff?.id ?? DateTime.now().toString(),
                name: nameController.text,
                email: staff?.email ?? '',
                phone: phoneController.text,
                position: posController.text,
                specialization: specController.text,
                profilePhoto: staff?.profilePhoto,
              );

              if (staff == null) {
                ref.read(supabaseServiceProvider).addStaff(newStaff);
              } else {
                ref.read(supabaseServiceProvider).updateStaff(newStaff);
              }
              Navigator.pop(context);
            },
            child: Text(staff == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _assignSchedule(BuildContext context, StaffModel staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assign Schedule: ${staff.name}'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text('Monday - Friday'), subtitle: Text('08:00 AM - 05:00 PM')),
            ListTile(title: Text('Saturday'), subtitle: Text('09:00 AM - 01:00 PM')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Update Schedule')),
        ],
      ),
    );
  }
}
