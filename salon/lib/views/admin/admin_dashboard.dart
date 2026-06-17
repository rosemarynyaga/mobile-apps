import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/salon_provider.dart';
import '../auth/login_screen.dart';
import 'manage_services_screen.dart';
import 'reports_screen.dart';
import 'manage_staff_screen.dart';
import 'manage_customers_screen.dart';
import 'global_appointments_screen.dart';
import 'manage_payments_screen.dart';
import 'manage_reviews_screen.dart';
import 'manage_categories_screen.dart';
import 'manage_promotions_screen.dart';
import 'manage_pricing_screen.dart';
import 'beauty_products_screen.dart';
import '../../models/service_model.dart';
import '../../models/promotion_model.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/zuri.png', height: 40, errorBuilder: (c, e, s) => const Icon(Icons.spa)),
            const SizedBox(width: 10),
            const Text('Zuri Manager'),
          ],
        ),
        actions: [
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: ref.read(supabaseServiceProvider).getStats(),
        builder: (context, snapshot) {
          final stats = snapshot.data ?? {
            'activeCustomers': 0,
            'totalAppointments': 0,
          };
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Live Performance', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildStatGrid(stats),
                const SizedBox(height: 32),
                const Text('Business Modules', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildManagementGrid(context, ref),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildStatGrid(Map<String, dynamic> stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _statCard('Active Customers', stats['activeCustomers'].toString(), Icons.people, Colors.blue),
        _statCard('Daily Revenue', '4,200 KES', Icons.payments, Colors.green),
        _statCard('Total Bookings', stats['totalAppointments'].toString(), Icons.event_available, Colors.orange),
        _statCard('Monthly Growth', '+12%', Icons.trending_up, Colors.purple),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildManagementGrid(BuildContext context, WidgetRef ref) {
    final List<Map<String, dynamic>> items = [
      {'title': 'Services', 'icon': Icons.spa, 'page': const ManageServicesScreen()},
      {'title': 'Staff', 'icon': Icons.badge, 'page': const ManageStaffScreen()},
      {'title': 'Customers', 'icon': Icons.group, 'page': const ManageCustomersScreen()},
      {'title': 'Bookings', 'icon': Icons.calendar_month, 'page': const GlobalAppointmentsScreen()},
      {'title': 'Payments', 'icon': Icons.receipt, 'page': const ManagePaymentsScreen()},
      {'title': 'Promotions', 'icon': Icons.discount, 'page': const ManagePromotionsScreen()},
      {'title': 'Pricing', 'icon': Icons.sell, 'page': const ManagePricingScreen()},
      {'title': 'Categories', 'icon': Icons.category, 'page': const ManageCategoriesScreen()},
      {'title': 'Reviews', 'icon': Icons.star_rate, 'page': const ManageReviewsScreen()},
      {'title': 'Reports', 'icon': Icons.bar_chart, 'page': const ReportsScreen()},
      {'title': 'Products', 'icon': Icons.shopping_bag, 'page': const BeautyProductsScreen()},
      {'title': 'Setup Data', 'icon': Icons.settings_suggest, 'action': () => _showSetupDataDialog(context, ref)},
      {'title': 'Broadcast', 'icon': Icons.notification_add, 'action': () => _showNotificationDialog(context, ref)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => InkWell(
        onTap: () {
          if (items[i].containsKey('page')) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => items[i]['page']));
          } else if (items[i].containsKey('action')) {
            items[i]['action']();
          }
        },
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              child: Icon(items[i]['icon'], color: const Color(0xFFC2185B)),
            ),
            const SizedBox(height: 8),
            Text(items[i]['title'], textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  void _showSetupDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Initialize Salon Data'),
        content: const Text('This will add professional salon services and prices to your database. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final services = [
                ServiceModel(id: '', name: 'Gentlemen\'s Haircut', description: 'Precision fade and beard grooming with hot towel finish.', price: 500, durationInMinutes: 30, category: 'Hair'),
                ServiceModel(id: '', name: 'Ladies Styling & Cut', description: 'Professional wash, cut, and blow-dry styling.', price: 1500, durationInMinutes: 60, category: 'Hair'),
                ServiceModel(id: '', name: 'Classic Manicure', description: 'Nail shaping, cuticle care, and polish of your choice.', price: 800, durationInMinutes: 45, category: 'Nails'),
                ServiceModel(id: '', name: 'Deluxe Pedicure', description: 'Relaxing foot soak, scrub, massage, and nail polish.', price: 1200, durationInMinutes: 60, category: 'Nails'),
                ServiceModel(id: '', name: 'Deep Tissue Massage', description: 'Relieve muscle tension with a 60-minute therapeutic massage.', price: 3500, durationInMinutes: 60, category: 'Spa'),
                ServiceModel(id: '', name: 'Organic Facial', description: 'Skin rejuvenation using 100% natural organic products.', price: 2500, durationInMinutes: 45, category: 'Spa'),
                ServiceModel(id: '', name: 'Wedding Makeup', description: 'Full glam professional makeup for your special day.', price: 5000, durationInMinutes: 90, category: 'Makeup'),
                ServiceModel(id: '', name: 'Hair Braiding (Lines)', description: 'Expert braiding and neat lines for any hair type.', price: 2000, durationInMinutes: 120, category: 'Hair'),
              ];

              final promos = [
                PromotionModel(id: 'p1', title: 'New Year Glow', description: 'Get 20% off all Facial and Spa services this month!', discountPercentage: 20, expiryDate: DateTime.now().add(const Duration(days: 30))),
                PromotionModel(id: 'p2', title: 'Monday Special', description: 'Half price on all Gentlemen cuts every Monday.', discountPercentage: 50, expiryDate: DateTime.now().add(const Duration(days: 14))),
              ];

              final service = ref.read(supabaseServiceProvider);
              for (var s in services) {
                await service.addService(s);
              }
              for (var p in promos) {
                await service.addPromotion(p);
              }

              // Invalidate providers to force UI refresh
              ref.invalidate(servicesProvider);
              ref.invalidate(promotionsProvider);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Salon data initialized successfully!')));
              }
            },
            child: const Text('Initialize'),
          ),
        ],
      ),
    );
  }

  void _showNotificationDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Broadcast Notification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: bodyController, decoration: const InputDecoration(labelText: 'Message'), maxLines: 2),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && bodyController.text.isNotEmpty) {
                ref.read(supabaseServiceProvider).broadcastNotification(
                  titleController.text,
                  bodyController.text,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification sent to all users!')));
              }
            },
            child: const Text('Send to All'),
          ),
        ],
      ),
    );
  }
}
