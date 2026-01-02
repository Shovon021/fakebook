import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/marketplace_service.dart';
import '../models/marketplace_model.dart'; // Fixed import
import '../theme/app_theme.dart';
import 'marketplace_detail_screen.dart';
import 'create_marketplace_item_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String? _selectedCategory;

  void _selectCategory(String category) {
    setState(() {
      if (_selectedCategory == category) {
        _selectedCategory = null; // Deselect
      } else {
        _selectedCategory = category;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        // Header
        Container(
          color: isDark ? const Color(0xFF242526) : Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Marketplace',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppTheme.black,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF3A3B3C) : AppTheme.lightGrey,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_outline,
                      color: isDark ? Colors.white : AppTheme.black,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF3A3B3C) : AppTheme.lightGrey,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.search,
                      color: isDark ? Colors.white : AppTheme.black,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Categories
        Container(
          color: isDark ? const Color(0xFF242526) : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _buildCategoryButton(
                  Icons.sell, 
                  'Sell', 
                  isDark, 
                  isActive: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateMarketplaceItemScreen(),
                      ),
                    );
                  }
                ),
                _buildCategoryButton(Icons.category, 'All', isDark, isActive: _selectedCategory == null, onTap: () => setState(() => _selectedCategory = null)),
                _buildCategoryButton(Icons.directions_car, 'Vehicles', isDark, isActive: _selectedCategory == 'Vehicles', onTap: () => _selectCategory('Vehicles')),
                _buildCategoryButton(Icons.home, 'Property', isDark, isActive: _selectedCategory == 'Property', onTap: () => _selectCategory('Property')),
                _buildCategoryButton(Icons.checkroom, 'Clothing', isDark, isActive: _selectedCategory == 'Clothing', onTap: () => _selectCategory('Clothing')),
                _buildCategoryButton(Icons.phone_iphone, 'Electronics', isDark, isActive: _selectedCategory == 'Electronics', onTap: () => _selectCategory('Electronics')),
                _buildCategoryButton(Icons.weekend, 'Furniture', isDark, isActive: _selectedCategory == 'Furniture', onTap: () => _selectCategory('Furniture')),
              ],
            ),
          ),
        ),
        // Divider
        Container(
          height: 8,
          color: isDark ? const Color(0xFF18191A) : AppTheme.lightGrey,
        ),
        // Product grid
        Expanded(
          child: StreamBuilder<List<MarketplaceItemModel>>(
            stream: MarketplaceService().getItemsStream(category: _selectedCategory),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final items = snapshot.data!;
              
              if (items.isEmpty) {
                 return Center(
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Icon(Icons.storefront, size: 60, color: Colors.grey[400]),
                       const SizedBox(height: 16),
                       Text(
                         _selectedCategory == null ? 'No items for sale yet' : 'No items in $_selectedCategory', 
                         style: TextStyle(color: Colors.grey[600])
                       ),
                     ],
                   ),
                 );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MarketplaceDetailScreen(
                            product: {
                              'title': item.title,
                              'price': item.formattedPrice,
                              'image': item.imageUrl,
                              'location': item.location,
                              'description': item.description,
                              'sellerId': item.sellerId,
                              'category': item.category,
                            },
                          ),
                        ),
                      );
                    },
                    child: _buildProductCard(item, isDark),
                  );
                },
              );
            }
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryButton(IconData icon, String label, bool isDark, {bool isActive = false, VoidCallback? onTap}) {
    final activeColor = Colors.blueAccent.withValues(alpha: 0.1);
    final activeIconColor = Colors.blueAccent;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isActive ? activeColor : (isDark ? const Color(0xFF3A3B3C) : AppTheme.lightGrey),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isActive ? activeIconColor : (isDark ? Colors.white : AppTheme.black),
                size: 26,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? activeIconColor : (isDark ? Colors.white : AppTheme.black),
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(MarketplaceItemModel item, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242526) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: Icon(Icons.image_not_supported, color: Colors.grey[500]),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.isSaved ? Icons.bookmark : Icons.bookmark_outline,
                      color: item.isSaved 
                          ? AppTheme.facebookBlue 
                          : (isDark ? Colors.white : AppTheme.black),
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Details
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.formattedPrice,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: isDark ? Colors.white : AppTheme.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark 
                        ? const Color(0xFFB0B3B8) 
                        : AppTheme.mediumGrey,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: isDark 
                          ? const Color(0xFFB0B3B8) 
                          : AppTheme.mediumGrey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark 
                              ? const Color(0xFFB0B3B8) 
                              : AppTheme.mediumGrey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
