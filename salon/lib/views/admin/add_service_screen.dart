import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/service_model.dart';
import '../../providers/salon_provider.dart';

class AddServiceScreen extends ConsumerStatefulWidget {
  final ServiceModel? service;
  const AddServiceScreen({super.key, this.service});

  @override
  ConsumerState<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends ConsumerState<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _durationController;
  late String _selectedCategory;
  final List<String> _categories = ['Hair', 'Spa', 'Nails', 'Massage', 'Makeup'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service?.name);
    _descController = TextEditingController(text: widget.service?.description);
    _priceController = TextEditingController(text: widget.service?.price.toString() ?? '');
    _durationController = TextEditingController(text: widget.service?.durationInMinutes.toString() ?? '');
    _selectedCategory = widget.service?.category ?? 'Hair';
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final service = ServiceModel(
        id: widget.service?.id ?? '',
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        durationInMinutes: int.parse(_durationController.text.trim()),
        category: _selectedCategory,
      );
      
      if (widget.service == null) {
        await ref.read(supabaseServiceProvider).addService(service);
      } else {
        await ref.read(supabaseServiceProvider).updateService(service);
      }
      
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.service == null ? 'Add Service' : 'Edit Service')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Service Name', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _descController, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'Price (KES)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: TextFormField(controller: _durationController, decoration: const InputDecoration(labelText: 'Duration (mins)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
              const SizedBox(height: 32),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _save, child: Text(widget.service == null ? 'Add Service' : 'Update Service'))),
            ],
          ),
        ),
      ),
    );
  }
}
