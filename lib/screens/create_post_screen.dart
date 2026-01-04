import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../services/post_service.dart';
import '../services/storage_service.dart';

class CreatePostScreen extends StatefulWidget {
  final UserModel currentUser;

  final bool initPhoto;

  const CreatePostScreen({
    super.key,
    required this.currentUser,
    this.initPhoto = false,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _controller = TextEditingController();
  final PostService _postService = PostService();
  final StorageService _storageService = StorageService();
  
  bool _isPosting = false;
  File? _selectedImage;
  File? _selectedVideo;
  final List<File> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    
    if (widget.initPhoto) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pickImage();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canPost => _controller.text.isNotEmpty || _selectedImage != null || _selectedImages.isNotEmpty || _selectedVideo != null;

  Future<void> _pickImage() async {
    final file = await _storageService.pickImageFromGallery();
    if (file != null) {
      setState(() {
        _selectedImage = file;
      });
    }
  }

  Future<void> _takePhoto() async {
    final file = await _storageService.pickImageFromCamera();
    if (file != null) {
      setState(() {
        _selectedImage = file;
      });
    }
  }

  Future<void> _pickVideo() async {
    final file = await _storageService.pickVideoFromGallery();
    if (file != null) {
      setState(() {
        _selectedVideo = file;
        _selectedImage = null; // Clear image if video is selected
        _selectedImages.clear();
      });
    }
  }

  void _showImageOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF242526) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.green.withValues(alpha: 0.15),
                child: const Icon(Icons.photo_library, color: Colors.green, size: 24),
              ),
              title: Text(
                'Photo',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Choose a photo from your gallery',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.purple.withValues(alpha: 0.15),
                child: const Icon(Icons.videocam, color: Colors.purple, size: 24),
              ),
              title: Text(
                'Video',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Choose a video from your gallery',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickVideo();
              },
            ),
            ListTile(
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue.withValues(alpha: 0.15),
                child: const Icon(Icons.camera_alt, color: Colors.blue, size: 24),
              ),
              title: Text(
                'Camera',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Take a photo with your camera',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePost() async {
    if (!_canPost) return;

    setState(() => _isPosting = true);

    try {
      String? imageUrl;
      List<String>? imagesUrls;

      // Upload single image if selected
      if (_selectedImage != null) {
        imageUrl = await _storageService.uploadPostImage(
          widget.currentUser.id,
          _selectedImage!,
        );
      }

      // Upload multiple images if selected
      if (_selectedImages.isNotEmpty) {
        imagesUrls = [];
        for (var img in _selectedImages) {
          final url = await _storageService.uploadPostImage(
            widget.currentUser.id,
            img,
          );
          if (url != null) imagesUrls.add(url);
        }
      }

      // Upload video if selected
      String? videoUrl;
      if (_selectedVideo != null) {
        videoUrl = await _storageService.uploadVideo(
          widget.currentUser.id,
          _selectedVideo!,
        );
      }

      // Create the post
      await _postService.createPost(
        authorId: widget.currentUser.id,
        content: _controller.text,
        imageUrl: imageUrl,
        imagesUrl: imagesUrls,
        videoUrl: videoUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully!')),
        );
        Navigator.pop(context, true); // Return true to indicate post created
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create post: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF18191A) : Colors.white,
      appBar: AppBar(
        title: Text(
          'Create Post',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.black,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF242526) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: isDark ? Colors.white : AppTheme.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: ElevatedButton(
              onPressed: _canPost && !_isPosting ? _handlePost : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canPost
                    ? AppTheme.facebookBlue
                    : (isDark ? const Color(0xFF4E4F50) : const Color(0xFFE4E6EB)),
                foregroundColor: _canPost
                    ? Colors.white
                    : (isDark ? const Color(0xFFAAB0B8) : const Color(0xFFBCC0C4)),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: _isPosting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Post',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // User Info & Privacy
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: CachedNetworkImageProvider(
                          widget.currentUser.avatarUrl,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.currentUser.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppTheme.black,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isDark ? const Color(0xFF3A3B3C) : Colors.grey[400]!,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.public,
                                  size: 12,
                                  color: isDark ? const Color(0xFFB0B3B8) : Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Public',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? const Color(0xFFB0B3B8) : Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_drop_down,
                                  size: 14,
                                  color: isDark ? const Color(0xFFB0B3B8) : Colors.grey[600],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Text Field
                  TextField(
                    controller: _controller,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: "What's on your mind?",
                      hintStyle: TextStyle(
                        fontSize: 24,
                        color: isDark ? const Color(0xFFB0B3B8) : Colors.grey,
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      fontSize: 24,
                      color: isDark ? Colors.white : AppTheme.black,
                    ),
                  ),

                  // Selected Image Preview
                  if (_selectedImage != null) ...[
                    const SizedBox(height: 16),
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedImage = null),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Selected Video Preview
                  if (_selectedVideo != null) ...[
                    const SizedBox(height: 16),
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.videocam,
                                  color: Colors.white,
                                  size: 48,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Video selected',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  _selectedVideo!.path.split('/').last,
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedVideo = null),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Bottom Action Panel
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF242526) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? const Color(0xFF3A3B3C) : Colors.grey[300]!,
                ),
              ),
            ),
            child: Column(
              children: [
                _buildActionRow(
                  Icons.photo_library,
                  Colors.green,
                  "Photo/video",
                  isDark,
                  onTap: _showImageOptions,
                ),
                const SizedBox(height: 12),
                _buildActionRow(
                  Icons.person_add,
                  AppTheme.facebookBlue,
                  "Tag people",
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildActionRow(
                  Icons.emoji_emotions,
                  Colors.orange,
                  "Feeling/activity",
                  isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(IconData icon, Color iconColor, String label, bool isDark, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : AppTheme.black,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
