import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/service_model.dart';
import '../models/appointment_model.dart';
import '../models/staff_model.dart';
import '../models/promotion_model.dart';
import '../models/beauty_product_model.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

// Create a single instance that holds state
final supabaseServiceProvider = Provider<SupabaseService>((ref) => SupabaseService());
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final servicesProvider = StreamProvider<List<ServiceModel>>((ref) {
  return ref.watch(supabaseServiceProvider).getServices();
});

final staffProvider = StreamProvider<List<StaffModel>>((ref) {
  return ref.watch(supabaseServiceProvider).getStaff();
});

final promotionsProvider = StreamProvider<List<PromotionModel>>((ref) {
  return ref.watch(supabaseServiceProvider).getPromotions();
});

final beautyProductsProvider = FutureProvider<List<BeautyProductModel>>((ref) {
  return ref.watch(apiServiceProvider).getBeautyProducts();
});

final appointmentsProvider = StreamProvider<List<AppointmentModel>>((ref) {
  final user = ref.watch(userModelProvider).value;
  // Fallback to demo user if not logged in
  final uid = user?.uid ?? 'demo_uid';
  final role = user?.role ?? 'customer';
  
  return ref.watch(supabaseServiceProvider).getAppointments(uid, role);
});
