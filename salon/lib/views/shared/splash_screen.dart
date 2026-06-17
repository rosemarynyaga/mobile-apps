import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../auth/login_screen.dart';
import '../customer/customer_home.dart';
import '../staff/staff_dashboard.dart';
import '../admin/admin_dashboard.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final authState = ref.read(authStateProvider);
    
    authState.when(
      data: (state) async {
        final user = state.session?.user;
        if (user == null) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
        } else {
          UserModel? userModel = await ref.read(authServiceProvider).getUserData(user.id);
          
          // Retry logic for splash screen auto-login
          int retries = 0;
          while (userModel == null && retries < 3) {
            await Future.delayed(const Duration(seconds: 1));
            userModel = await ref.read(authServiceProvider).getUserData(user.id);
            retries++;
          }

          if (!mounted) return;
          if (userModel != null) {
            final role = userModel.role.toLowerCase().trim();
            debugPrint('Splash navigating with role: $role');

            if (role == 'admin') {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
            } else if (role == 'staff') {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StaffDashboard()));
            } else {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CustomerHome()));
            }
          } else {
             Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
          }
        }
      },
      loading: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
      error: (_, __) => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Using the Zuri Logo
            Image.asset(
              'assets/images/zuri.png', 
              height: 220, 
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.spa, size: 100, color: Color(0xFFC2185B));
              }
            ),
            const SizedBox(height: 20),
            const Text(
              'Zuri Salon',
              style: TextStyle(
                fontSize: 28, 
                fontWeight: FontWeight.bold, 
                color: Color(0xFFC2185B),
                letterSpacing: 2,
              ),
            ),
            const Text(
              'BEAUTY • CONFIDENCE • YOU',
              style: TextStyle(
                fontSize: 12, 
                color: Colors.grey,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            const SpinKitThreeBounce(color: Color(0xFFC2185B), size: 30),
          ],
        ),
      ),
    );
  }
}
