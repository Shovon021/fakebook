import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Get User Error: $e');
      return null;
    }
  }

  // Get user stream (real-time)
  Stream<UserModel?> getUserStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromMap(doc.data()!) : null);
  }

  // Update user profile
  Future<bool> updateUserProfile({
    required String userId,
    String? name,
    String? avatarUrl,
    String? coverUrl,
    String? bio,
    List<String>? details,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (avatarUrl != null) updateData['avatarUrl'] = avatarUrl;
      if (coverUrl != null) updateData['coverUrl'] = coverUrl;
      if (bio != null) updateData['bio'] = bio;
      if (details != null) updateData['details'] = details;

      await _firestore.collection('users').doc(userId).update(updateData);
      return true;
    } catch (e) {
      print('Update Profile Error: $e');
      return false;
    }
  }

  // Send friend request
  Future<void> sendFriendRequest(String fromUserId, String toUserId) async {
    await _firestore.collection('friendRequests').add({
      'from': fromUserId,
      'to': toUserId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Accept friend request
  Future<void> acceptFriendRequest(String requestId, String userId1, String userId2) async {
    // Update request status
    await _firestore.collection('friendRequests').doc(requestId).update({
      'status': 'accepted',
    });

    // Add to friends lists
    await _firestore.collection('users').doc(userId1).update({
      'friends': FieldValue.arrayUnion([userId2]),
      'friendsCount': FieldValue.increment(1),
    });
    await _firestore.collection('users').doc(userId2).update({
      'friends': FieldValue.arrayUnion([userId1]),
      'friendsCount': FieldValue.increment(1),
    });
  }

  // Get friend requests for user
  Stream<QuerySnapshot> getFriendRequestsStream(String userId) {
    return _firestore
        .collection('friendRequests')
        .where('to', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  // Get all users (for "People You May Know")
  Future<List<UserModel>> getAllUsers({int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Get All Users Error: $e');
      return [];
    }
  }
  // Search users by name (simple prefix search)
  Future<List<UserModel>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    try {
      // Capitalize first letter to match stored format if needed, 
      // but ideally we'd store a lowercase 'searchName' field for better results.
      // For now, let's assume case-sensitive or user types correctly.
      final snapshot = await _firestore
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Search Users Error: $e');
      return [];
    }
  }
}
