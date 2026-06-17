import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/salon_provider.dart';
import '../../models/service_model.dart';
import 'booking_screen.dart';

class ServiceListView extends ConsumerStatefulWidget {
  const ServiceListView({super.key});

  @override
  ConsumerState<ServiceListView> createState() => _ServiceListViewState();
}

class _ServiceListViewState extends ConsumerState<ServiceListView> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final List<String> _categories = ['All', 'Hair', 'Spa', 'Nails', 'Massage', 'Makeup'];

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(servicesProvider);
    final promotionsAsync = ref.watch(promotionsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(servicesProvider),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text('Special Offers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _buildPromotions(promotionsAsync),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text('Our Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _buildCategoryFilter(),
            servicesAsync.when(
              data: (services) {
                final filtered = services.where((s) {
                  final matchesCategory = _selectedCategory == 'All' || s.category == _selectedCategory;
                  final matchesSearch = s.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                                      s.description.toLowerCase().contains(_searchQuery.toLowerCase());
                  return matchesCategory && matchesSearch;
                }).toList();
                
                if (filtered.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.search_off, size: 60, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('No services found matching your criteria.', textAlign: TextAlign.center),
                          TextButton(
                            onPressed: () => setState(() {
                              _selectedCategory = 'All';
                              _searchQuery = '';
                            }),
                            child: const Text('Clear Filters'),
                          )
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final service = filtered[index];
                    return _buildServiceCard(service);
                  },
                );
              },
              loading: () => const Center(child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              )),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 40),
                      const SizedBox(height: 16),
                      Text('Error: $err', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.refresh(servicesProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotions(AsyncValue<List<dynamic>> promotionsAsync) {
    return promotionsAsync.when(
      data: (promotions) {
        if (promotions.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('No active promotions at the moment.', style: TextStyle(color: Colors.grey)),
          );
        }
        return SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: promotions.length,
            itemBuilder: (context, index) {
              final p = promotions[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFC2185B), Color(0xFFE91E63)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(p.description, style: const TextStyle(color: Colors.white70, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                      child: Text('${p.discountPercentage.toInt()}% OFF', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFFC2185B),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Find your best look', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search services...',
              prefixIcon: const Icon(Icons.search),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: _categories.length,
        itemBuilder: (context, i) {
          final isSelected = _selectedCategory == _categories[i];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_categories[i]),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedCategory = _categories[i]),
              selectedColor: const Color(0xFFC2185B),
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingScreen(service: service))),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC2185B).withOpacity(0.1),
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
                  ),
                  child: Icon(
                    _getCategoryIcon(service.category),
                    size: 45,
                    color: const Color(0xFFC2185B),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          service.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.3),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'KES ${service.price.toInt()}',
                              style: const TextStyle(
                                color: Color(0xFFC2185B),
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${service.durationInMinutes} min',
                                    style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'hair': return Icons.content_cut;
      case 'nails': return Icons.back_hand;
      case 'spa': return Icons.spa;
      case 'makeup': return Icons.face_retouching_natural;
      case 'massage': return Icons.self_improvement;
      default: return Icons.auto_awesome;
    }
  }
}
