import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

class StorageService {
  final ImagePicker _picker = ImagePicker();
  
  // Cloudinary credentials - FREE 25GB storage!
  static const String _cloudName = 'dwgvksico';
  static const String _uploadPreset = 'fakebook_uploads';
  
  late final CloudinaryPublic _cloudinary;
  
  StorageService() {
    _cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);
  }

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 80,
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
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 80,
    );
    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  // Upload image to Cloudinary (FREE!)
  Future<String?> uploadImage({
    required File file,
    required String folder,
  }) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          folder: folder,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      debugPrint('✅ Cloudinary upload success: ${response.secureUrl}');
      return response.secureUrl;
    } catch (e) {
      debugPrint('❌ Cloudinary upload error: $e');
      throw Exception('Upload failed: $e');
    }
  }

  // Helper wrappers
  Future<String?> uploadProfilePicture(String userId, File file) async {
    return uploadImage(file: file, folder: 'fakebook/users/$userId/profile');
  }

  Future<String?> uploadCoverPhoto(String userId, File file) async {
    return uploadImage(file: file, folder: 'fakebook/users/$userId/cover');
  }

  Future<String?> uploadPostImage(String userId, File file) async {
    return uploadImage(file: file, folder: 'fakebook/posts/$userId');
  }

  Future<String?> uploadStoryImage(String userId, File file) async {
    return uploadImage(file: file, folder: 'fakebook/stories/$userId');
  }
}
