import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/service_model.dart';
import '../../models/appointment_model.dart';
import '../../providers/salon_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:intl/intl.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final ServiceModel service;
  const BookingScreen({super.key, required this.service});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  String? _selectedStaffId;

  @override
  Widget build(BuildContext context) {
    final staffAsync = ref.watch(staffProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Book ${widget.service.name}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Staff Member', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            staffAsync.when(
              data: (staffList) => DropdownButtonFormField<String>(
                initialValue: _selectedStaffId,
                items: staffList.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                onChanged: (val) => setState(() => _selectedStaffId = val),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Error loading staff'),
            ),
            const SizedBox(height: 24),
            const Text('Select Date', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListTile(
              title: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
            ),
            const SizedBox(height: 16),
            const Text('Select Time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListTile(
              title: Text(_selectedTime.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final picked = await showTimePicker(context: context, initialTime: _selectedTime);
                if (picked != null) setState(() => _selectedTime = picked);
              },
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _bookAppointment,
                child: const Text('Confirm Booking'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _bookAppointment() async {
    if (_selectedStaffId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a staff member')));
      return;
    }

    final user = ref.read(userModelProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not logged in')));
      return;
    }

    final appointment = AppointmentModel(
      id: '',
      customerId: user.uid,
      staffId: _selectedStaffId!,
      serviceId: widget.service.id,
      dateTime: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ),
      status: 'pending',
    );

    await ref.read(supabaseServiceProvider).bookAppointment(appointment);
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
          content: const Text(
            'Booking Confirmed!\n\nYou will receive a notification 1 hour before your appointment.',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to services
              },
              child: const Text('Great!'),
            ),
          ],
        ),
      );
    }
  }
}
