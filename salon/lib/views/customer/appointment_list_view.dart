import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/salon_provider.dart';
import 'package:intl/intl.dart';
import 'review_screen.dart';

class AppointmentListView extends ConsumerWidget {
  const AppointmentListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(appointmentsProvider);

    return appointmentsAsync.when(
      data: (appointments) => appointments.isEmpty
          ? const Center(child: Text('No appointments yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appt = appointments[index];
                return Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text('Status: ${appt.status.toUpperCase()}', 
                          style: TextStyle(fontWeight: FontWeight.bold, color: _getStatusColor(appt.status))),
                        subtitle: Text(DateFormat('MMM dd, yyyy - hh:mm a').format(appt.dateTime)),
                        trailing: appt.status == 'pending'
                            ? PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'cancel') {
                                    ref.read(supabaseServiceProvider).updateAppointmentStatus(appt.id, 'cancelled');
                                  } else if (value == 'reschedule') {
                                    _reschedule(context, ref, appt.id);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: 'reschedule', child: Text('Reschedule')),
                                  const PopupMenuItem(value: 'cancel', child: Text('Cancel Appointment')),
                                ],
                              )
                            : null,
                      ),
                      if (appt.status == 'completed')
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReviewScreen(appointment: appt))),
                              child: const Text('Rate Experience'),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  void _reschedule(BuildContext context, WidgetRef ref, String apptId) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      await ref.read(supabaseServiceProvider).rescheduleAppointment(apptId, picked);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment Rescheduled!')));
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'approved': return Colors.blue;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.black;
    }
  }
}
