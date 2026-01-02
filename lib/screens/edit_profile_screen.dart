import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final StorageService _storageService = StorageService();
  final UserService _userService = UserService();
  
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  
  File? _newAvatar;
  File? _newCover;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final file = await _storageService.pickImageFromGallery();
    if (file != null) {
      setState(() => _newAvatar = file);
    }
  }

  Future<void> _pickCover() async {
    final file = await _storageService.pickImageFromGallery();
    if (file != null) {
      setState(() => _newCover = file);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    try {
      String? newAvatarUrl;
      String? newCoverUrl;

      // Upload new avatar if selected
      if (_newAvatar != null) {
        newAvatarUrl = await _storageService.uploadProfilePicture(
          widget.user.id,
          _newAvatar!,
        );
      }

      // Upload new cover if selected
      if (_newCover != null) {
        newCoverUrl = await _storageService.uploadCoverPhoto(
          widget.user.id,
          _newCover!,
        );
      }

      // Update profile in Firestore
      await _userService.updateUserProfile(
        userId: widget.user.id,
        name: _nameController.text != widget.user.name ? _nameController.text : null,
        bio: _bioController.text != (widget.user.bio ?? '') ? _bioController.text : null,
        avatarUrl: newAvatarUrl,
        coverUrl: newCoverUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF18191A) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF242526) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Save',
                    style: TextStyle(
                      color: AppTheme.facebookBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture Section
            _buildSectionHeader('Profile Picture', isDark),
            const SizedBox(height: 12),
            Center(
              child: GestureDetector(
                onTap: _pickAvatar,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _newAvatar != null
                          ? FileImage(_newAvatar!)
                          : CachedNetworkImageProvider(widget.user.avatarUrl) as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.facebookBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Cover Photo Section
            _buildSectionHeader('Cover Photo', isDark),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickCover,
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[300],
                ),
                child: _newCover != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_newCover!, fit: BoxFit.cover),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, 
                                 size: 40, 
                                 color: isDark ? Colors.white54 : Colors.grey),
                            const SizedBox(height: 8),
                            Text(
                              'Add Cover Photo',
                              style: TextStyle(
                                color: isDark ? Colors.white54 : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Name Section
            _buildSectionHeader('Name', isDark),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? const Color(0xFF3A3B3C) : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Bio Section
            _buildSectionHeader('Bio', isDark),
            const SizedBox(height: 8),
            TextField(
              controller: _bioController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Write something about yourself...',
                hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                filled: true,
                fillColor: isDark ? const Color(0xFF3A3B3C) : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }
}
