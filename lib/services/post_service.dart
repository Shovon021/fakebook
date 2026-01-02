import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get posts stream (real-time updates)
  // Get posts stream (real-time updates)
  Stream<List<PostModel>> getPostsStream({String? currentUserId}) {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .asyncMap((snapshot) async {
          List<PostModel> posts = [];
          for (var doc in snapshot.docs) {
            final data = doc.data();
            
            // 1. Fetch author data
            final authorDoc = await _firestore
                .collection('users')
                .doc(data['authorId'])
                .get();
            
            final author = authorDoc.exists
                ? UserModel.fromMap(authorDoc.data()!)
                : UserModel(id: data['authorId'], name: 'Unknown', avatarUrl: '');

            // 2. Check if current user liked this post
            ReactionType? userReaction;
            if (currentUserId != null) {
              final likeDoc = await _firestore
                  .collection('posts')
                  .doc(doc.id)
                  .collection('likes')
                  .doc(currentUserId)
                  .get();
              if (likeDoc.exists) {
                userReaction = ReactionType.like; // Default to like for now
              }
            }

            // 3. Fetch Shared Post if applicable
            PostModel? sharedPost;
            bool isShared = data['sharedPostId'] != null;
            
            if (isShared) {
              final sharedDoc = await _firestore.collection('posts').doc(data['sharedPostId']).get();
              if (sharedDoc.exists) {
                final sharedData = sharedDoc.data()!;
                // Fetch shared post author
                final sharedAuthorDoc = await _firestore.collection('users').doc(sharedData['authorId']).get();
                final sharedAuthor = sharedAuthorDoc.exists
                    ? UserModel.fromMap(sharedAuthorDoc.data()!)
                    : UserModel(id: sharedData['authorId'], name: 'Unknown', avatarUrl: '');

                sharedPost = PostModel(
                  id: sharedDoc.id,
                  author: sharedAuthor,
                  content: sharedData['content'] ?? '',
                  imageUrl: sharedData['imageUrl'],
                  imagesUrl: sharedData['imagesUrl'] != null 
                      ? List<String>.from(sharedData['imagesUrl']) 
                      : null,
                  createdAt: (sharedData['createdAt'] as Timestamp).toDate(),
                  likesCount: sharedData['likesCount'] ?? 0,
                  commentsCount: sharedData['commentsCount'] ?? 0,
                  sharesCount: sharedData['sharesCount'] ?? 0,
                );
              }
            }
            
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
              userReaction: userReaction,
              isShared: isShared,
              sharedPost: sharedPost,
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
    String? sharedPostId,
  }) async {
    try {
      final data = {
        'authorId': authorId,
        'content': content,
        'imageUrl': imageUrl,
        'imagesUrl': imagesUrl,
        'sharedPostId': sharedPostId,
        'likesCount': 0,
        'commentsCount': 0,
        'sharesCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      };
      
      final docRef = await _firestore.collection('posts').add(data);
      
      // If sharing, increment shares count on original post
      if (sharedPostId != null) {
        await _firestore.collection('posts').doc(sharedPostId).update({
          'sharesCount': FieldValue.increment(1),
        });
      }

      return docRef.id;
    } catch (e) {
      print('Create Post Error: $e');
      return null;
    }
  }

  // Toggle like
  Future<void> toggleLike(String postId, String userId) async {
    final likeRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(userId);

    final doc = await likeRef.get();

    if (doc.exists) {
      // Unlike
      await likeRef.delete();
      await _firestore.collection('posts').doc(postId).update({
        'likesCount': FieldValue.increment(-1),
      });
    } else {
      // Like
      await likeRef.set({
        'createdAt': FieldValue.serverTimestamp(),
      });
      await _firestore.collection('posts').doc(postId).update({
        'likesCount': FieldValue.increment(1),
      });
    }
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
