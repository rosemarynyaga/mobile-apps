import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/service_model.dart';
import '../models/appointment_model.dart';
import '../models/staff_model.dart';
import '../models/payment_model.dart';
import '../models/review_model.dart';
import '../models/user_model.dart';
import '../models/promotion_model.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Services
  Stream<List<ServiceModel>> getServices() {
    // We use SELECT for reliable initial fetch + stream for updates
    // If Realtime is not enabled in dashboard, it will still work as a static fetch
    return _client
        .from('services')
        .stream(primaryKey: ['id'])
        .map((data) => data.map((item) => ServiceModel.fromMap(item, item['id'].toString())).toList());
  }

  Future<void> addService(ServiceModel service) async {
    await _client.from('services').insert(service.toMap());
  }

  Future<void> updateService(ServiceModel service) async {
    await _client.from('services').update(service.toMap()).eq('id', service.id);
  }

  Future<void> deleteService(String id) async {
    await _client.from('services').delete().eq('id', id);
  }

  Future<void> updateServicePrice(String id, double newPrice) async {
    await _client.from('services').update({'price': newPrice}).eq('id', id);
  }

  Stream<List<String>> getCategories() {
    return _client
        .from('services')
        .stream(primaryKey: ['id'])
        .map((data) => data.map((item) => item['category'].toString()).toSet().toList());
  }

  // Staff
  Stream<List<StaffModel>> getStaff() {
    return _client
        .from('staff')
        .stream(primaryKey: ['id'])
        .map((data) => data.map((item) => StaffModel.fromMap(item, item['id'].toString())).toList());
  }

  Future<void> addStaff(StaffModel staff) async {
    await _client.from('staff').insert(staff.toMap());
  }

  Future<void> updateStaff(StaffModel staff) async {
    await _client.from('staff').update(staff.toMap()).eq('id', staff.id);
  }

  Future<void> deleteStaff(String id) async {
    await _client.from('staff').delete().eq('id', id);
  }

  // Appointments
  Stream<List<AppointmentModel>> getAppointments(String? userId, String? role) {
    return _client
        .from('appointments')
        .stream(primaryKey: ['id'])
        .map((data) {
          final filtered = data.where((item) {
            if (role == 'customer') return item['customerId'] == userId;
            if (role == 'staff') return item['staffId'] == userId;
            return true;
          }).toList();
          return filtered.map((item) => AppointmentModel.fromMap(item, item['id'].toString())).toList();
        });
  }

  Future<void> bookAppointment(AppointmentModel appointment) async {
    await _client.from('appointments').insert(appointment.toMap());
    await broadcastNotification('New Booking', 'Appointment added.');
  }

  Future<void> updateAppointmentStatus(String id, String status) async {
    await _client.from('appointments').update({'status': status}).eq('id', id);
    await broadcastNotification('Status Updated', 'Appointment $id is now $status.');
  }

  Future<void> rescheduleAppointment(String id, DateTime newDate) async {
    await _client.from('appointments').update({
      'dateTime': newDate.toIso8601String(),
      'status': 'pending',
    }).eq('id', id);
  }

  // Customers
  Stream<List<UserModel>> getCustomers() {
    return _client
        .from('users')
        .stream(primaryKey: ['uid'])
        .eq('role', 'customer')
        .map((data) => data.map((item) => UserModel.fromMap(item)).toList());
  }

  Future<void> deleteCustomer(String uid) async {
    await _client.from('users').delete().eq('uid', uid);
  }

  // Promotions
  Stream<List<PromotionModel>> getPromotions() {
    return _client
        .from('promotions')
        .stream(primaryKey: ['id'])
        .map((data) => data.map((item) => PromotionModel.fromMap(item, item['id'].toString())).toList());
  }

  Future<void> addPromotion(PromotionModel promotion) async {
    await _client.from('promotions').insert(promotion.toMap());
    await broadcastNotification('New Promotion!', '${promotion.title}: ${promotion.description}');
  }

  Future<void> updatePromotion(PromotionModel promotion) async {
    await _client.from('promotions').update(promotion.toMap()).eq('id', promotion.id);
  }

  Future<void> deletePromotion(String id) async {
    await _client.from('promotions').delete().eq('id', id);
  }

  // Payments
  Future<void> recordPayment(PaymentModel payment) async {
    await _client.from('payments').insert(payment.toMap());
  }

  Stream<List<PaymentModel>> getPayments() {
    return _client
        .from('payments')
        .stream(primaryKey: ['id'])
        .map((data) => data.map((item) => PaymentModel.fromMap(item, item['id'].toString())).toList());
  }

  // Reviews
  Future<void> addReview(ReviewModel review) async {
    await _client.from('reviews').insert(review.toMap());
  }

  Future<void> deleteReview(String id) async {
    await _client.from('reviews').delete().eq('id', id);
  }

  Stream<List<ReviewModel>> getReviews() {
    return _client
        .from('reviews')
        .stream(primaryKey: ['id'])
        .map((data) => data.map((item) => ReviewModel.fromMap(item, item['id'].toString())).toList());
  }

  // Notifications
  Stream<List<Map<String, String>>> getNotifications() {
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .order('time', ascending: false)
        .map((data) => data.map((item) {
          return {
            'title': item['title']?.toString() ?? '',
            'body': item['body']?.toString() ?? '',
            'time': item['time']?.toString() ?? '',
          };
        }).toList());
  }

  Future<void> broadcastNotification(String title, String body) async {
    await _client.from('notifications').insert({
      'title': title,
      'body': body,
      'time': DateTime.now().toIso8601String(),
    });
  }

  // Stats
  Future<Map<String, dynamic>> getStats() async {
    final appointmentsResponse = await _client.from('appointments').select();
    final customersResponse = await _client.from('users').select().eq('role', 'customer');
    
    final appointments = appointmentsResponse as List;
    final customers = customersResponse as List;
    
    return {
      'totalAppointments': appointments.length,
      'activeCustomers': customers.length,
      'completed': appointments.where((d) => d['status'] == 'completed').length,
      'revenue': appointments.where((d) => d['status'] == 'completed').fold(0.0, (sum, item) => sum + 1000.0),
    };
  }

  // Automatic Seeding Logic - "Doing it myself" to ensure data exists
  Future<void> seedDatabaseIfEmpty() async {
    try {
      final existingServices = await _client.from('services').select('id').limit(1);
      if ((existingServices as List).isEmpty) {
        debugPrint('Database is empty. Seeding professional salon data...');
        
        final services = [
          {'name': 'Gentlemen\'s Haircut', 'description': 'Precision fade and beard grooming with hot towel finish.', 'price': 500, 'durationInMinutes': 30, 'category': 'Hair'},
          {'name': 'Ladies Styling & Cut', 'description': 'Professional wash, cut, and blow-dry styling.', 'price': 1500, 'durationInMinutes': 60, 'category': 'Hair'},
          {'name': 'Classic Manicure', 'description': 'Nail shaping, cuticle care, and polish of your choice.', 'price': 800, 'durationInMinutes': 45, 'category': 'Nails'},
          {'name': 'Deluxe Pedicure', 'description': 'Relaxing foot soak, scrub, massage, and nail polish.', 'price': 1200, 'durationInMinutes': 60, 'category': 'Nails'},
          {'name': 'Deep Tissue Massage', 'description': 'Relieve muscle tension with a 60-minute therapeutic massage.', 'price': 3500, 'durationInMinutes': 60, 'category': 'Spa'},
          {'name': 'Organic Facial', 'description': 'Skin rejuvenation using 100% natural organic products.', 'price': 2500, 'durationInMinutes': 45, 'category': 'Spa'},
          {'name': 'Wedding Makeup', 'description': 'Full glam professional makeup for your special day.', 'price': 5000, 'durationInMinutes': 90, 'category': 'Makeup'},
          {'name': 'Hair Braiding (Lines)', 'description': 'Expert braiding and neat lines for any hair type.', 'price': 2000, 'durationInMinutes': 120, 'category': 'Hair'},
        ];

        final promos = [
          {'title': 'New Year Glow', 'description': 'Get 20% off all Facial and Spa services this month!', 'discountPercentage': 20, 'expiryDate': DateTime.now().add(const Duration(days: 30)).toIso8601String()},
          {'title': 'Monday Special', 'description': 'Half price on all Gentlemen cuts every Monday.', 'discountPercentage': 50, 'expiryDate': DateTime.now().add(const Duration(days: 14)).toIso8601String()},
        ];

        await _client.from('services').insert(services);
        await _client.from('promotions').insert(promos);
        debugPrint('Seeding completed successfully!');
      }
    } catch (e) {
      debugPrint('Seeding error (check if tables exist): $e');
    }
  }
}
