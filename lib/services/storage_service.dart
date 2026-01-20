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

  // Upload image to Cloudinary (FREE!) with timeout
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
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('❌ Cloudinary upload timed out after 30 seconds');
          throw Exception('Upload timed out. Please try again.');
        },
      );
      debugPrint('✅ Cloudinary upload success: ${response.secureUrl}');
      return response.secureUrl;
    } catch (e) {
      debugPrint('❌ Cloudinary upload error: $e');
      return null; // Return null instead of throwing to prevent crash
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

  // Pick video from gallery
  Future<File?> pickVideoFromGallery() async {
    final XFile? video = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 5),
    );
    if (video != null) {
      return File(video.path);
    }
    return null;
  }

  // Upload video to Cloudinary with timeout
  Future<String?> uploadVideo(String userId, File file) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          folder: 'fakebook/videos/$userId',
          resourceType: CloudinaryResourceType.Video,
        ),
      ).timeout(
        const Duration(seconds: 60), // Videos need more time
        onTimeout: () {
          debugPrint('❌ Cloudinary video upload timed out after 60 seconds');
          throw Exception('Video upload timed out. Please try again.');
        },
      );
      debugPrint('✅ Cloudinary video upload success: ${response.secureUrl}');
      return response.secureUrl;
    } catch (e) {
      debugPrint('❌ Cloudinary video upload error: $e');
      return null; // Return null instead of throwing to prevent crash
    }
  }
}
