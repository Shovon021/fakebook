import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/marketplace_item_model.dart';

class MarketplaceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get marketplace items
  Stream<List<MarketplaceItemModel>> getItemsStream() {
    return _firestore
        .collection('marketplace')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return MarketplaceItemModel(
                id: doc.id,
                title: data['title'] ?? '',
                price: (data['price'] ?? 0).toDouble(),
                imageUrl: data['imageUrl'] ?? '',
                location: data['location'] ?? '',
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
  }) async {
    try {
      final docRef = await _firestore.collection('marketplace').add({
        'sellerId': sellerId,
        'title': title,
        'price': price,
        'imageUrl': imageUrl,
        'location': location,
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
      MarketplaceItemModel(id: '1', title: 'iPhone 13 Pro', price: 899, imageUrl: 'https://picsum.photos/300/300?random=1', location: 'New York'),
      MarketplaceItemModel(id: '2', title: 'Leather Sofa', price: 450, imageUrl: 'https://picsum.photos/300/300?random=2', location: 'Los Angeles'),
      MarketplaceItemModel(id: '3', title: 'Mountain Bike', price: 350, imageUrl: 'https://picsum.photos/300/300?random=3', location: 'Chicago'),
      MarketplaceItemModel(id: '4', title: 'MacBook Pro', price: 1299, imageUrl: 'https://picsum.photos/300/300?random=4', location: 'San Francisco'),
      MarketplaceItemModel(id: '5', title: 'Gaming Console', price: 399, imageUrl: 'https://picsum.photos/300/300?random=5', location: 'Miami'),
      MarketplaceItemModel(id: '6', title: 'Office Desk', price: 199, imageUrl: 'https://picsum.photos/300/300?random=6', location: 'Seattle'),
    ];
  }
}
