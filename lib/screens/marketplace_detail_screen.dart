import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../utils/image_helper.dart';

class MarketplaceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const MarketplaceDetailScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF18191A) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color: isDark ? Colors.white : Colors.black,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: isDark ? Colors.white : Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_horiz, color: isDark ? Colors.white : Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Gallery
            CachedNetworkImage(
              imageUrl: product['image'],
              height: 400,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['title'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product['price'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? const Color(0xFFE4E6EB) : const Color(0xFFE4E6EB), // Consistent light background for primary button on dark mode? No usually blue or grey. Let's stick to standard messenger blue.
                            // Actually FB often uses the message blue here
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text(
                            'Send seller a message',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF3A3B3C) : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.bookmark_border, color: isDark ? Colors.white : Colors.black),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  Divider(color: isDark ? const Color(0xFF3A3B3C) : Colors.grey[300]),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                     "Category: ${product['category'] ?? 'Miscellaneous'}",
                     style: TextStyle(
                         fontWeight: FontWeight.bold,
                         fontSize: 16,
                         color: isDark ? Colors.white : AppTheme.black,
                     ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product['description'] ?? 'No description provided.',
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? const Color(0xFFB0B3B8) : Colors.grey[800],
                      height: 1.4,
                    ),
                  ),

                   const SizedBox(height: 24),
                  Divider(color: isDark ? const Color(0xFF3A3B3C) : Colors.grey[300]),
                  const SizedBox(height: 16),
                  
                  // Seller Info
                  Text(
                    'Seller Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('users').doc(product['sellerId']).get(),
                    builder: (context, snapshot) {
                       if (!snapshot.hasData) {
                         return const SizedBox.shrink(); 
                       }
                       final userData = snapshot.data!.data() as Map<String, dynamic>?;
                       final name = userData?['name'] ?? 'Unknown Seller';
                       final avatarUrl = userData?['avatarUrl'];

                       return Row(
                        children: [
                           CircleAvatar(
                             radius: 24,
                             backgroundImage: ImageHelper.getImageProvider(avatarUrl),
                           ),
                           const SizedBox(width: 12),
                           Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(
                                 name,
                                 style: TextStyle(
                                   fontWeight: FontWeight.bold,
                                   fontSize: 16,
                                   color: isDark ? Colors.white : AppTheme.black,
                                 ),
                               ),
                               Text(
                                 'Seller on Fakebook',
                                 style: TextStyle(
                                   color: isDark ? const Color(0xFFB0B3B8) : Colors.grey[600],
                                   fontSize: 13,
                                 ),
                               ),
                             ],
                           ),
                        ],
                      );
                    }
                  ),
                   
                  const SizedBox(height: 24),
                  // Map Placeholder
                  Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'San Francisco, CA',
                    style: TextStyle(
                      color: isDark ? const Color(0xFFB0B3B8) : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                           CachedNetworkImage(
                             imageUrl: 'https://picsum.photos/seed/map/800/400',
                             fit: BoxFit.cover,
                           ),
                           const Center(
                             child: Icon(Icons.location_on, color: Colors.red, size: 40),
                           ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
