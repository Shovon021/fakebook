import 'package:cloud_firestore/cloud_firestore.dart';

class MessengerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get or create a chat room between two users
  Future<String> getOrCreateChatRoom(String userId1, String userId2) async {
    // Sort IDs to ensure consistent room ID
    final sortedIds = [userId1, userId2]..sort();
    final roomId = '${sortedIds[0]}_${sortedIds[1]}';

    final roomDoc = await _firestore.collection('chatRooms').doc(roomId).get();
    
    if (!roomDoc.exists) {
      await _firestore.collection('chatRooms').doc(roomId).set({
        'participants': sortedIds,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return roomId;
  }

  // Send a message
  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String content,
    String? imageUrl,
  }) async {
    // Add message to sub-collection
    await _firestore
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .add({
      'senderId': senderId,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
    });

    // Update last message in chat room
    await _firestore.collection('chatRooms').doc(roomId).update({
      'lastMessage': content,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  // Get messages stream for a chat room
  Stream<QuerySnapshot> getMessagesStream(String roomId) {
    return _firestore
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  // Get user's chat rooms
  Stream<QuerySnapshot> getChatRoomsStream(String userId) {
    return _firestore
        .collection('chatRooms')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String roomId, String readerId) async {
    final messagesQuery = await _firestore
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .where('senderId', isNotEqualTo: readerId)
        .where('read', isEqualTo: false)
        .get();

    for (var doc in messagesQuery.docs) {
      await doc.reference.update({'read': true});
    }
  }
}
