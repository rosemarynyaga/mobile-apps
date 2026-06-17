import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/salon_provider.dart';
import '../auth/login_screen.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import 'package:fl_chart/fl_chart.dart';

class StaffDashboard extends ConsumerStatefulWidget {
  const StaffDashboard({super.key});

  @override
  ConsumerState<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends ConsumerState<StaffDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userModelProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Workspace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
               _showStaffNotifications(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStaffHeader(user),
          Expanded(
            child: [
              _buildSchedule(),
              _buildCustomerRecords(),
              _buildPerformance(user),
            ][_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFFC2185B),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Clients'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Performance'),
        ],
      ),
    );
  }

  Widget _buildStaffHeader(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFFC2185B),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.badge, size: 40, color: Color(0xFFC2185B)),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome, ${user?.name ?? "Staff"}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const Text('Professional Stylist', style: TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSchedule() {
    final appointmentsAsync = ref.watch(appointmentsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Today\'s Schedule', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(DateFormat('EEEE, MMM dd').format(DateTime.now()), style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        Expanded(
          child: appointmentsAsync.when(
            data: (appointments) => appointments.isEmpty
                ? const Center(child: Text('No assigned appointments for today'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final appt = appointments[index];
                      return Card(
                        child: ListTile(
                          title: Text(appt.serviceId, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Time: ${DateFormat('hh:mm a').format(appt.dateTime)}\nStatus: ${appt.status.toUpperCase()}'),
                          trailing: _buildStatusAction(appt),
                        ),
                      );
                    },
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, __) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }

  Widget? _buildStatusAction(dynamic appt) {
    if (appt.status == 'completed' || appt.status == 'cancelled') return null;
    
    return PopupMenuButton<String>(
      onSelected: (val) {
        ref.read(supabaseServiceProvider).updateAppointmentStatus(appt.id, val);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to $val')));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: Colors.pink[50], borderRadius: BorderRadius.circular(10)),
        child: const Text('Update', style: TextStyle(color: Color(0xFFC2185B), fontWeight: FontWeight.bold)),
      ),
      itemBuilder: (context) => [
        if (appt.status == 'pending') const PopupMenuItem(value: 'approved', child: Text('Approve Appointment')),
        if (appt.status == 'approved' || appt.status == 'pending') const PopupMenuItem(value: 'completed', child: Text('Mark as Completed')),
        const PopupMenuItem(value: 'cancelled', child: Text('Cancel Appointment')),
      ],
    );
  }

  Widget _buildCustomerRecords() {
    final customersStream = ref.watch(supabaseServiceProvider).getCustomers();
    
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Align(alignment: Alignment.centerLeft, child: Text('Customer Service Records', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        ),
        Expanded(
          child: StreamBuilder(
            stream: customersStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final customers = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  final c = customers[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text(c.name.substring(0, 1))),
                      title: Text(c.name),
                      subtitle: Text('Last Service: Hair Cut\nPhone: ${c.phone}'),
                      trailing: const Icon(Icons.edit_note, color: Colors.blue),
                      onTap: () => _viewCustomerHistory(context, c),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _viewCustomerHistory(BuildContext context, UserModel customer) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service History: ${customer.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text('Hair Cut & Styling'),
              subtitle: Text('Completed on Oct 20, 2023'),
            ),
            const ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text('Full Body Massage'),
              subtitle: Text('Completed on Sept 15, 2023'),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Back')),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPerformance(dynamic user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Performance Statistics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              _statCard('Total Services', '42', Colors.blue),
              const SizedBox(width: 16),
              _statCard('Completed', '38', Colors.green),
            ],
          ),
          const SizedBox(height: 16),
          _buildPerformanceChart(),
          const SizedBox(height: 24),
          const Text('Top Services', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const ListTile(title: Text('1. Hair Cutting'), trailing: Text('15')),
          const ListTile(title: Text('2. Scalp Treatment'), trailing: Text('12')),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: BarChart(
        BarChartData(
          barGroups: [
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 5, color: Colors.pink)]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 8, color: Colors.pink)]),
            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 6, color: Colors.pink)]),
            BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 9, color: Colors.pink)]),
            BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 7, color: Colors.pink)]),
          ],
        ),
      ),
    );
  }

  void _showStaffNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.event, color: Colors.blue),
              title: const Text('New Appointment Assigned'),
              subtitle: const Text('John Doe for Hair Cut at 2:00 PM'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.orange),
              title: const Text('Schedule Update'),
              subtitle: const Text('The salon will close early this Friday.'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
