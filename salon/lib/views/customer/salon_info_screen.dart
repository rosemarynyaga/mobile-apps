import 'package:flutter/material.dart';

class SalonInfoScreen extends StatelessWidget {
  const SalonInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Salon Information')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.pink[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.spa, size: 100, color: Colors.pink),
            ),
            const SizedBox(height: 24),
            const Text('Smart Salon & Spa', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const Text('Your beauty, our passion.', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
            const SizedBox(height: 24),
            const Divider(),
            _buildInfoRow(Icons.location_on, '123 Beauty Plaza, Nairobi, Kenya'),
            _buildInfoRow(Icons.phone, '+254 700 000 000'),
            _buildInfoRow(Icons.access_time, 'Mon - Sat: 8:00 AM - 8:00 PM\nSun: 10:00 AM - 4:00 PM'),
            const SizedBox(height: 24),
            const Text('About Us', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'We provide top-notch beauty and grooming services with a focus on hygiene, customer satisfaction, and professional excellence. Our team of experts is dedicated to making you look and feel your best.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.pink),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
