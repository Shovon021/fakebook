import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  // Pick image from camera
  Future<File?> pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  // Upload image and return URL
  Future<String?> uploadImage({
    required File file,
    required String path, // e.g., 'posts/userId/timestamp.jpg'
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Upload Error: $e');
      return null;
    }
  }

  // Upload profile picture
  Future<String?> uploadProfilePicture(String userId, File file) async {
    return uploadImage(
      file: file,
      path: 'users/$userId/profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
  }

  // Upload cover photo
  Future<String?> uploadCoverPhoto(String userId, File file) async {
    return uploadImage(
      file: file,
      path: 'users/$userId/cover_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
  }

  // Upload post image
  Future<String?> uploadPostImage(String userId, File file) async {
    return uploadImage(
      file: file,
      path: 'posts/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
  }

  // Upload story image
  Future<String?> uploadStoryImage(String userId, File file) async {
    return uploadImage(
      file: file,
      path: 'stories/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
  }
}
