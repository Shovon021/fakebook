import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/marketplace_model.dart';

class MarketplaceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get marketplace items (with optional category filter)
  Stream<List<MarketplaceItemModel>> getItemsStream({String? category}) {
    Query query = _firestore.collection('marketplace').orderBy('createdAt', descending: true).limit(50);
    
    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return MarketplaceItemModel(
        id: doc.id,
        title: data['title'] ?? '',
        price: (data['price'] ?? 0).toDouble(),
        imageUrl: data['imageUrl'] ?? '',
        location: data['location'] ?? '',
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        category: data['category'] ?? 'Miscellaneous',
        description: data['description'] ?? 'No description provided.',
        sellerId: data['sellerId'] ?? '',
      );
    }).toList());
  }

  // Create marketplace item
  Future<String?> createItem({
    required String sellerId,
    required String title,
    required double price,
    required String imageUrl,
    required String location,
    required String category,
    required String description,
  }) async {
    try {
      final docRef = await _firestore.collection('marketplace').add({
        'sellerId': sellerId,
        'title': title,
        'price': price,
        'imageUrl': imageUrl,
        'location': location,
        'category': category,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print('Create Item Error: $e');
      return null;
    }
  }

  // Get placeholder items when Firebase isn't ready
  List<MarketplaceItemModel> getPlaceholderItems() {
    return [
      MarketplaceItemModel(
        id: '1', title: 'iPhone 13 Pro', price: 899, imageUrl: 'https://picsum.photos/300/300?random=1', location: 'New York',
        createdAt: DateTime.now(), category: 'Electronics', description: 'Like new, no scratches.', sellerId: 'dummy1',
      ),
      MarketplaceItemModel(
        id: '2', title: 'Leather Sofa', price: 450, imageUrl: 'https://picsum.photos/300/300?random=2', location: 'Los Angeles',
        createdAt: DateTime.now(), category: 'Furniture', description: 'Comfortable leather sofa.', sellerId: 'dummy2',
      ),
      MarketplaceItemModel(
        id: '3', title: 'Mountain Bike', price: 350, imageUrl: 'https://picsum.photos/300/300?random=3', location: 'Chicago',
        createdAt: DateTime.now(), category: 'Vehicles', description: 'Great for trails.', sellerId: 'dummy3',
      ),
    ];
  }
}
