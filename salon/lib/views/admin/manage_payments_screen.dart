import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/salon_provider.dart';
import '../../models/payment_model.dart';
import 'package:intl/intl.dart';

class ManagePaymentsScreen extends ConsumerStatefulWidget {
  const ManagePaymentsScreen({super.key});

  @override
  ConsumerState<ManagePaymentsScreen> createState() => _ManagePaymentsScreenState();
}

class _ManagePaymentsScreenState extends ConsumerState<ManagePaymentsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final paymentsStream = ref.watch(supabaseServiceProvider).getPayments();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments & Invoices'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by customer or service...',
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
      body: StreamBuilder<List<PaymentModel>>(
        stream: paymentsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final payments = snapshot.data!.where((p) => 
            p.customerName.toLowerCase().contains(_searchQuery) || 
            p.serviceName.toLowerCase().contains(_searchQuery)
          ).toList();

          if (payments.isEmpty) return const Center(child: Text('No transactions found.'));
          
          return ListView.builder(
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final p = payments[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.receipt_long, color: Colors.green),
                  title: Text('${p.amount} KES - ${p.customerName}'),
                  subtitle: Text('${p.method} | ${DateFormat('MMM dd').format(p.date)}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (val) => _handleAction(context, val, p),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'receipt', child: Text('Generate Receipt')),
                      const PopupMenuItem(value: 'invoice', child: Text('View Invoice')),
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

  void _handleAction(BuildContext context, String action, PaymentModel payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(action == 'receipt' ? 'Receipt' : 'Invoice'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transaction ID: ${payment.id}'),
            Text('Customer: ${payment.customerName}'),
            Text('Service: ${payment.serviceName}'),
            Text('Amount: ${payment.amount} KES'),
            Text('Date: ${payment.date}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Download PDF')),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}
