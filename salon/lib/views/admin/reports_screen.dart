import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/salon_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => _exportReport(context),
          )
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ref.read(supabaseServiceProvider).getStats(),
        builder: (context, snapshot) {
          final stats = snapshot.data ?? {
            'activeCustomers': 0,
            'totalAppointments': 0,
            'revenue': 0.0,
          };
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatSummary(stats),
                const SizedBox(height: 32),
                const Text('Revenue Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildBarChart(stats),
                const SizedBox(height: 32),
                const Text('Staff Performance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildStaffPerformance(),
                const SizedBox(height: 32),
                const Text('Popular Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildPieChart(),
              ],
            ),
          );
        }
      ),
    );
  }

  void _exportReport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(leading: const Icon(Icons.picture_as_pdf), title: const Text('Export as PDF'), onTap: () => Navigator.pop(context)),
          ListTile(leading: const Icon(Icons.table_view), title: const Text('Export as Excel'), onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Widget _buildStatSummary(Map<String, dynamic> stats) {
    return Column(
      children: [
        Row(
          children: [
            _statCard('Customers', stats['activeCustomers'].toString(), Colors.purple),
            const SizedBox(width: 16),
            _statCard('Bookings', stats['totalAppointments'].toString(), Colors.blue),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _statCard('Daily Revenue', '4,500 KES', Colors.orange),
            const SizedBox(width: 16),
            _statCard('Monthly Revenue', '${stats['revenue']} KES', Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        color: color.withAlpha(25),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(Map<String, dynamic> stats) {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barGroups: [
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 5000, color: Colors.pink)]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 8000, color: Colors.pink)]),
            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: stats['revenue'].toDouble(), color: Colors.blue)]),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffPerformance() {
    return Column(
      children: [
        _staffProgress('Alice Smith', 0.9),
        _staffProgress('Bob Johnson', 0.75),
      ],
    );
  }

  Widget _staffProgress(String name, double val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(name)),
          Expanded(child: LinearProgressIndicator(value: val, color: Colors.green, backgroundColor: Colors.grey[200])),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(value: 45, title: 'Hair', color: Colors.blue, radius: 40),
            PieChartSectionData(value: 30, title: 'Nails', color: Colors.orange, radius: 40),
            PieChartSectionData(value: 25, title: 'Facial', color: Colors.green, radius: 40),
          ],
        ),
      ),
    );
  }
}
