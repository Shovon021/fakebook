import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/story_model.dart';
import '../models/user_model.dart';

class StoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new story
  Future<String?> createStory({
    required String userId,
    required String imageUrl,
    String? content,
  }) async {
    try {
      // Stories expire after 24 hours
      final expiresAt = DateTime.now().add(const Duration(hours: 24));
      
      final docRef = await _firestore.collection('stories').add({
        'userId': userId,
        'imageUrl': imageUrl,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(expiresAt),
        'viewers': [],
      });
      return docRef.id;
    } catch (e) {
      print('Create Story Error: $e');
      return null;
    }
  }

  // Get active stories (not expired)
  Stream<List<StoryModel>> getActiveStoriesStream() {
    final now = DateTime.now();
    
    return _firestore
        .collection('stories')
        .where('expiresAt', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('expiresAt')
        .snapshots()
        .asyncMap((snapshot) async {
          List<StoryModel> stories = [];
          
          for (var doc in snapshot.docs) {
            final data = doc.data();
            
            // Fetch user data
            final userDoc = await _firestore
                .collection('users')
                .doc(data['userId'])
                .get();
            
            final user = userDoc.exists
                ? UserModel.fromMap(userDoc.data()!)
                : UserModel(id: data['userId'], name: 'Unknown', avatarUrl: '');
            
            stories.add(StoryModel(
              id: doc.id,
              user: user,
              imageUrl: data['imageUrl'],
              isViewed: false, // Will be updated based on viewer list
              isOwnStory: false, // Set by UI based on current user
              createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            ));
          }
          
          return stories;
        });
  }

  // Mark story as viewed
  Future<void> markStoryAsViewed(String storyId, String viewerId) async {
    await _firestore.collection('stories').doc(storyId).update({
      'viewers': FieldValue.arrayUnion([viewerId]),
    });
  }

  // Delete expired stories (can be called periodically)
  Future<void> cleanupExpiredStories() async {
    final now = DateTime.now();
    final expiredQuery = await _firestore
        .collection('stories')
        .where('expiresAt', isLessThan: Timestamp.fromDate(now))
        .get();

    for (var doc in expiredQuery.docs) {
      await doc.reference.delete();
    }
  }
}
