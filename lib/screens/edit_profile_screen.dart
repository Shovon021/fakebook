import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../services/user_service.dart';
import '../utils/image_helper.dart';

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
  late TextEditingController _schoolController;
  late TextEditingController _collegeController;
  late TextEditingController _universityController;
  late TextEditingController _workController;
  late TextEditingController _locationController;
  
  String? _selectedGender;
  String? _selectedRelationship;
  
  File? _newAvatar;
  File? _newCover;
  bool _isSaving = false;

  final List<String> _genderOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];
  final List<String> _relationshipOptions = ['Single', 'In a relationship', 'Engaged', 'Married', 'Complicated', 'Prefer not to say'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    
    // Parse existing details
    final details = widget.user.details;
    _schoolController = TextEditingController(text: _getDetailValue(details, 'School'));
    _collegeController = TextEditingController(text: _getDetailValue(details, 'College'));
    _universityController = TextEditingController(text: _getDetailValue(details, 'University'));
    _workController = TextEditingController(text: _getDetailValue(details, 'Works at'));
    _locationController = TextEditingController(text: _getDetailValue(details, 'Lives in'));
    _selectedGender = _getDetailValue(details, 'Gender');
    _selectedRelationship = _getDetailValue(details, 'Relationship');
  }

  String? _getDetailValue(List<String> details, String prefix) {
    for (var detail in details) {
      if (detail.startsWith('$prefix: ')) {
        return detail.substring(prefix.length + 2);
      }
    }
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _schoolController.dispose();
    _collegeController.dispose();
    _universityController.dispose();
    _workController.dispose();
    _locationController.dispose();
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

  List<String> _buildDetails() {
    final details = <String>[];
    if (_workController.text.isNotEmpty) details.add('Works at: ${_workController.text}');
    if (_universityController.text.isNotEmpty) details.add('University: ${_universityController.text}');
    if (_collegeController.text.isNotEmpty) details.add('College: ${_collegeController.text}');
    if (_schoolController.text.isNotEmpty) details.add('School: ${_schoolController.text}');
    if (_locationController.text.isNotEmpty) details.add('Lives in: ${_locationController.text}');
    if (_selectedGender != null && _selectedGender!.isNotEmpty) details.add('Gender: $_selectedGender');
    if (_selectedRelationship != null && _selectedRelationship!.isNotEmpty) details.add('Relationship: $_selectedRelationship');
    return details;
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
        details: _buildDetails(),
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
                : const Text(
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
                          : ImageHelper.getImageProvider(widget.user.avatarUrl),
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
                  color: isDark ? const Color(0xFF3A3B3C) : Colors.grey[300],
                  image: widget.user.coverUrl != null && _newCover == null
                      ? DecorationImage(
                          image: ImageHelper.getImageProvider(widget.user.coverUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _newCover != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_newCover!, fit: BoxFit.cover),
                      )
                    : widget.user.coverUrl == null
                        ? Center(
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
                          )
                        : null,
              ),
            ),
            const SizedBox(height: 24),

            // Name Section
            _buildSectionHeader('Name', isDark),
            const SizedBox(height: 8),
            _buildTextField(_nameController, 'Your name', isDark),
            const SizedBox(height: 24),

            // Bio Section
            _buildSectionHeader('Bio', isDark),
            const SizedBox(height: 8),
            _buildTextField(_bioController, 'Write something about yourself...', isDark, maxLines: 3),
            const SizedBox(height: 24),

            // Work Section
            _buildSectionHeader('Work', isDark),
            const SizedBox(height: 8),
            _buildTextField(_workController, 'Where do you work?', isDark, prefixIcon: Icons.work),
            const SizedBox(height: 24),

            // Education Section
            _buildSectionHeader('Education', isDark),
            const SizedBox(height: 8),
            _buildTextField(_universityController, 'University', isDark, prefixIcon: Icons.school),
            const SizedBox(height: 12),
            _buildTextField(_collegeController, 'College', isDark, prefixIcon: Icons.school),
            const SizedBox(height: 12),
            _buildTextField(_schoolController, 'High School', isDark, prefixIcon: Icons.school),
            const SizedBox(height: 24),

            // Location Section
            _buildSectionHeader('Current City', isDark),
            const SizedBox(height: 8),
            _buildTextField(_locationController, 'Where do you live?', isDark, prefixIcon: Icons.location_on),
            const SizedBox(height: 24),

            // Gender Section
            _buildSectionHeader('Gender', isDark),
            const SizedBox(height: 8),
            _buildDropdown(_genderOptions, _selectedGender, (val) => setState(() => _selectedGender = val), isDark),
            const SizedBox(height: 24),

            // Relationship Section
            _buildSectionHeader('Relationship Status', isDark),
            const SizedBox(height: 8),
            _buildDropdown(_relationshipOptions, _selectedRelationship, (val) => setState(() => _selectedRelationship = val), isDark),
            const SizedBox(height: 40),
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

  Widget _buildTextField(TextEditingController controller, String hint, bool isDark, {int maxLines = 1, IconData? prefixIcon}) {
    return TextField(
      controller: controller,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: isDark ? Colors.white54 : Colors.grey) : null,
        filled: true,
        fillColor: isDark ? const Color(0xFF3A3B3C) : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> options, String? value, Function(String?) onChanged, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3A3B3C) : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        hint: Text('Select', style: TextStyle(color: isDark ? Colors.white54 : Colors.grey)),
        dropdownColor: isDark ? const Color(0xFF3A3B3C) : Colors.white,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
