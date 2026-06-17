import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/salon_provider.dart';
import 'package:intl/intl.dart';

class GlobalAppointmentsScreen extends ConsumerWidget {
  const GlobalAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(appointmentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Global Booking Management')),
      body: appointmentsAsync.when(
        data: (appts) {
          if (appts.isEmpty) return const Center(child: Text('No bookings found.'));
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appts.length,
            itemBuilder: (context, index) {
              final a = appts[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text('Client: ${a.customerId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'Time: ${DateFormat('MMM dd, hh:mm a').format(a.dateTime)}\nStatus: ${a.status.toUpperCase()}',
                    style: TextStyle(color: _getStatusColor(a.status)),
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (val) => _handleAction(context, ref, a.id, val),
                    itemBuilder: (context) => [
                      if (a.status == 'pending') const PopupMenuItem(value: 'approved', child: Text('Approve Booking')),
                      if (a.status == 'pending') const PopupMenuItem(value: 'rejected', child: Text('Reject Booking')),
                      const PopupMenuItem(value: 'reschedule', child: Text('Reschedule')),
                      if (a.status != 'cancelled') const PopupMenuItem(value: 'cancelled', child: Text('Cancel Appointment')),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, __) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String id, String action) async {
    if (action == 'reschedule') {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now().add(const Duration(days: 1)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 60)),
      );
      if (picked != null) {
        await ref.read(supabaseServiceProvider).rescheduleAppointment(id, picked);
      }
    } else {
      await ref.read(supabaseServiceProvider).updateAppointmentStatus(id, action);
    }
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Appointment $action successfully!')));
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'approved': return Colors.blue;
      case 'completed': return Colors.green;
      case 'rejected':
      case 'cancelled': return Colors.red;
      default: return Colors.black;
    }
  }
}
