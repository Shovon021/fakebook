import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get posts stream (real-time updates)
  Stream<List<PostModel>> getPostsStream() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .asyncMap((snapshot) async {
          List<PostModel> posts = [];
          for (var doc in snapshot.docs) {
            final data = doc.data();
            // Fetch author data
            final authorDoc = await _firestore
                .collection('users')
                .doc(data['authorId'])
                .get();
            
            final author = authorDoc.exists
                ? UserModel.fromMap(authorDoc.data()!)
                : UserModel(id: data['authorId'], name: 'Unknown', avatarUrl: '');
            
            posts.add(PostModel(
              id: doc.id,
              author: author,
              content: data['content'] ?? '',
              imageUrl: data['imageUrl'],
              imagesUrl: data['imagesUrl'] != null 
                  ? List<String>.from(data['imagesUrl']) 
                  : null,
              likesCount: data['likesCount'] ?? 0,
              commentsCount: data['commentsCount'] ?? 0,
              sharesCount: data['sharesCount'] ?? 0,
              createdAt: (data['createdAt'] as Timestamp).toDate(),
            ));
          }
          return posts;
        });
  }

  // Create a new post
  Future<String?> createPost({
    required String authorId,
    required String content,
    String? imageUrl,
    List<String>? imagesUrl,
  }) async {
    try {
      final docRef = await _firestore.collection('posts').add({
        'authorId': authorId,
        'content': content,
        'imageUrl': imageUrl,
        'imagesUrl': imagesUrl,
        'likesCount': 0,
        'commentsCount': 0,
        'sharesCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print('Create Post Error: $e');
      return null;
    }
  }

  // Like a post
  Future<void> likePost(String postId) async {
    await _firestore.collection('posts').doc(postId).update({
      'likesCount': FieldValue.increment(1),
    });
  }

  // Add comment
  Future<void> addComment({
    required String postId,
    required String userId,
    required String content,
  }) async {
    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add({
      'userId': userId,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    await _firestore.collection('posts').doc(postId).update({
      'commentsCount': FieldValue.increment(1),
    });
  }

  // Get comments for a post
  Stream<QuerySnapshot> getCommentsStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }
}
