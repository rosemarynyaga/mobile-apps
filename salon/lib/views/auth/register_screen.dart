import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../customer/customer_home.dart';
import '../staff/staff_dashboard.dart';
import '../admin/admin_dashboard.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  String _selectedGender = 'Female';
  String _selectedRole = 'customer';
  bool _isLoading = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final response = await ref.read(authServiceProvider).signUp(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
              name: _nameController.text.trim(),
              phone: _phoneController.text.trim(),
              address: _addressController.text.trim(),
              gender: _selectedGender,
              role: _selectedRole,
            );
            
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account Created! Redirecting...')),
          );
          // Small delay to allow database sync
          await Future.delayed(const Duration(seconds: 1));
          
          if (response?.session != null) {
            final userModel = await ref.read(authServiceProvider).getUserData(response!.user!.id);
            if (userModel != null) {
              _navigateToDashboard(userModel);
              return;
            }
          }
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          String errorMsg = e.toString();
          if (errorMsg.contains('SocketException')) {
            errorMsg = 'No internet connection. Please check your data or Wi-Fi.';
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
    final role = userModel.role.toLowerCase().trim();
    if (role == 'admin') {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AdminDashboard()), (r) => false);
    } else if (role == 'staff') {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const StaffDashboard()), (r) => false);
    } else {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const CustomerHome()), (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Join Smart Salon',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Role Selector
              const Text('Register as:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'customer', label: Text('Customer'), icon: Icon(Icons.person)),
                  ButtonSegment(value: 'staff', label: Text('Staff'), icon: Icon(Icons.badge)),
                  ButtonSegment(value: 'admin', label: Text('Admin'), icon: Icon(Icons.admin_panel_settings)),
                ],
                selected: {_selectedRole},
                onSelectionChanged: (val) => setState(() => _selectedRole = val.first),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
                validator: (val) => val!.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
                validator: (val) => val!.isEmpty ? 'Enter email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined)),
                validator: (val) => val!.isEmpty ? 'Enter phone' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.location_on_outlined)),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                decoration: const InputDecoration(labelText: 'Gender', prefixIcon: Icon(Icons.people_outline)),
                items: ['Female', 'Male', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (val) => setState(() => _selectedGender = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
                obscureText: true,
                validator: (val) => val!.length < 6 ? 'Password too short (min 6 chars)' : null,
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _register,
                      child: const Text('REGISTER'),
                    ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? '),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Login', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
