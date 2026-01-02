import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920, // Higher quality for storage
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

  // Upload image to Firebase Storage
  Future<String?> uploadImage({
    required File file,
    required String path, 
  }) async {
    try {
      final ref = _storage.ref().child(path).child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Upload Error: $e');
      return null;
    }
  }

  // Helper getters/wrappers
  Future<String?> uploadProfilePicture(String userId, File file) async {
    return uploadImage(file: file, path: 'users/$userId/profile');
  }

  Future<String?> uploadCoverPhoto(String userId, File file) async {
    return uploadImage(file: file, path: 'users/$userId/cover');
  }

  Future<String?> uploadPostImage(String userId, File file) async {
    return uploadImage(file: file, path: 'posts/$userId');
  }

  Future<String?> uploadStoryImage(String userId, File file) async {
    return uploadImage(file: file, path: 'stories/$userId');
  }
}
