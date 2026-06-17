import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import 'edit_profile_screen.dart';
import 'salon_info_screen.dart';
import '../auth/login_screen.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userModelAsync = ref.watch(userModelProvider);

    return userModelAsync.when(
      data: (user) => SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(user),
            const SizedBox(height: 20),
            _buildProfileMenu(context, ref),
            const SizedBox(height: 40),
            _buildLogoutButton(context, ref),
            const SizedBox(height: 20),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(30),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFC2185B),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 60, color: Color(0xFFC2185B)),
          ),
          const SizedBox(height: 16),
          Text(
            user?.name ?? 'Guest User',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            user?.email ?? '',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenu(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _menuItem(Icons.edit_outlined, 'Edit Profile', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
          }),
          _menuItem(Icons.info_outline, 'Salon Information', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SalonInfoScreen()));
          }),
          _menuItem(Icons.history, 'Appointment History', () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('See "Bookings" tab for history')));
          }),
          _menuItem(Icons.notifications_none, 'Notification Settings', () {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifications are always ON')));
          }),
          _menuItem(Icons.help_outline, 'Help & Support', () {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact: +254 700 000 000')));
          }),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[100]!)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFC2185B)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () async {
            await ref.read(authServiceProvider).signOut();
            if (context.mounted) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            }
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text('LOGOUT ACCOUNT'),
        ),
      ),
    );
  }
}
