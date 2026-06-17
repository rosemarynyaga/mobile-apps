import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../customer/customer_home.dart';
import '../staff/staff_dashboard.dart';
import '../admin/admin_dashboard.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _selectedRole = 'customer';

  @override
  void initState() {
    super.initState();
    _emailController.text = '';
    _passwordController.text = '';
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final response = await ref.read(authServiceProvider).signIn(
              _emailController.text.trim(),
              _passwordController.text.trim(),
            );

        if (response?.user != null && mounted) {
          // 1. Fetch user data from DB
          UserModel? userModel = await ref.read(authServiceProvider).getUserData(response!.user!.id);
          
          // 2. Retry logic if DB hasn't synced yet (common for first-time login)
          int retries = 0;
          while (userModel == null && retries < 3) {
            await Future.delayed(const Duration(seconds: 1));
            userModel = await ref.read(authServiceProvider).getUserData(response.user!.id);
            retries++;
          }

          if (userModel != null) {
            final dbRole = userModel.role.toLowerCase().trim();
            final selectedRole = _selectedRole.toLowerCase().trim();

            // 3. Logic check: If I select 'admin' but am 'customer' in DB, warn and redirect to customer
            if (dbRole != selectedRole) {
              debugPrint('Role mismatch: DB=$dbRole, UI=$selectedRole');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logged in as ${dbRole.toUpperCase()}')),
                );
              }
            }
            
            _navigateToDashboard(userModel);
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User profile not found. Please try again or re-register.')),
              );
            }
          }
        }
      } catch (e) {
        if (mounted) {
          String errorMsg = e.toString();
          if (errorMsg.contains('SocketException')) {
            errorMsg = 'No internet connection.';
          } else if (errorMsg.contains('Invalid login credentials')) {
            errorMsg = 'Wrong email or password.';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg)),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToDashboard(UserModel userModel) {
    if (mounted) {
      final role = userModel.role.toLowerCase().trim();
      debugPrint('Navigating with role: $role');
      
      if (role == 'admin') {
        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
          (route) => false
        );
      } else if (role == 'staff') {
        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(builder: (_) => const StaffDashboard()),
          (route) => false
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(builder: (_) => const CustomerHome()),
          (route) => false
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryColor, primaryColor.withAlpha(200), Colors.white],
            stops: const [0.0, 0.4, 0.4],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 30),
                Image.asset(
                  'assets/images/zuri.png', 
                  height: 120, 
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.spa, size: 80, color: Colors.white)
                ),
                const SizedBox(height: 10),
                const Text(
                  'Zuri Salon',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const Text(
                  'BEAUTY • CONFIDENCE • YOU',
                  style: TextStyle(fontSize: 12, color: Colors.white70, letterSpacing: 1),
                ),
                const SizedBox(height: 40),
                Card(
                  elevation: 10,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Login as',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _roleIcon(Icons.person_outline, 'Customer', 'customer'),
                              _roleIcon(Icons.badge_outlined, 'Staff', 'staff'),
                              _roleIcon(Icons.admin_panel_settings_outlined, 'Admin', 'admin'),
                            ],
                          ),
                          const SizedBox(height: 30),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: Icon(Icons.email_outlined, color: primaryColor),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            validator: (val) => val!.isEmpty ? 'Enter email' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            obscureText: true,
                            validator: (val) => val!.length < 6 ? 'Password too short' : null,
                          ),
                          const SizedBox(height: 24),
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: _login,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    elevation: 5,
                                  ),
                                  child: const Text('LOGIN'),
                                ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                              child: const Text('Forgot Password?'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Don\'t have an account? '),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                      child: Text(
                        'Register Now',
                        style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleIcon(IconData icon, String label, String role) {
    bool isSelected = _selectedRole == role;
    Color primaryColor = Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor : Colors.white,
              shape: BoxShape.circle,
              boxShadow: isSelected 
                ? [BoxShadow(color: primaryColor.withAlpha(100), blurRadius: 10, spreadRadius: 2)] 
                : [const BoxShadow(color: Colors.black12, blurRadius: 5)],
            ),
            child: Icon(
              icon, 
              color: isSelected ? Colors.white : Colors.grey[400], 
              size: 30
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? primaryColor : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
