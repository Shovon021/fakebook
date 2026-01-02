import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final ImagePicker _picker = ImagePicker();

  // Pick image from gallery (Compressed for Firestore)
  Future<File?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,  // Reduced size to fit in database
      maxHeight: 800,
      imageQuality: 60, // Reduced quality
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
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 60,
    );
    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  // Convert image to Base64 String (No Upload needed)
  Future<String?> uploadImage({
    required File file,
    required String path, 
  }) async {
    try {
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      // Return Data URI
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      print('Encoding Error: $e');
      return null;
    }
  }

  // Helper getters/wrappers
  Future<String?> uploadProfilePicture(String userId, File file) async {
    return uploadImage(file: file, path: 'ignored');
  }

  Future<String?> uploadCoverPhoto(String userId, File file) async {
    return uploadImage(file: file, path: 'ignored');
  }

  Future<String?> uploadPostImage(String userId, File file) async {
    return uploadImage(file: file, path: 'ignored');
  }

  Future<String?> uploadStoryImage(String userId, File file) async {
    return uploadImage(file: file, path: 'ignored');
  }
}
