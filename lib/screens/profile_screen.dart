import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../theme/app_theme.dart';
import '../services/user_service.dart';
import '../widgets/messenger_icon.dart';
import '../services/post_service.dart';
import '../services/storage_service.dart';
import '../widgets/post_card.dart';
import '../utils/image_helper.dart';
import '../providers/current_user_provider.dart';
import '../services/story_service.dart';
import 'edit_profile_screen.dart';
import 'search_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;

  const ProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late UserModel _user;
  final List<String> _tabs = ['Posts', 'Photos', 'Reels'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _user = widget.user;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _changeCoverPhoto() async {
    try {
      final file = await StorageService().pickImageFromGallery();
      if (file == null) return;

      // Show loading
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(color: AppTheme.facebookBlue),
          ),
        );
      }

      final url = await StorageService().uploadCoverPhoto(_user.id, file);
      if (url != null) {
        await UserService().updateUserProfile(userId: _user.id, coverUrl: url);
        setState(() {
          _user = _user.copyWith(coverUrl: url);
        });

        // Create post for cover photo update
        await PostService().createPost(
          authorId: _user.id,
          content: '', // No text content needed, header will handle it
          imageUrl: url,
          type: 'cover_photo',
        );

        if (mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cover photo updated!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading if open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update cover: $e')),
        );
      }
    }
  }

  Future<void> _changeProfilePicture() async {
    try {
      final file = await StorageService().pickImageFromGallery();
      if (file == null) return;

      // Show loading
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(color: AppTheme.facebookBlue),
          ),
        );
      }

      final url = await StorageService().uploadProfilePicture(_user.id, file);
      if (url != null) {
        await UserService().updateUserProfile(userId: _user.id, avatarUrl: url);
        setState(() {
          _user = _user.copyWith(avatarUrl: url);
        });

        // Create post for profile picture update
        await PostService().createPost(
          authorId: _user.id,
          content: '', // No text content needed, header will handle it
          imageUrl: url,
          type: 'profile_picture',
        );

        if (mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading if open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile picture: $e')),
        );
      }
    }
  }

  void _showMoreOptions(BuildContext context, bool isDark) {
    // Only show on own profile
    final isOwnProfile = currentUserProvider.currentUser?.id == _user.id;
    
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
            if (isOwnProfile) ...[
              ListTile(
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.red.withValues(alpha: 0.15),
                  child: const Icon(Icons.delete_forever, color: Colors.red, size: 22),
                ),
                title: Text(
                  'Delete Account',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Permanently delete your account and all data',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // Close sheet
                  _confirmDeleteAccount(context, isDark);
                },
              ),
            ] else ...[
              ListTile(
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: isDark ? const Color(0xFF3A3B3C) : Colors.grey[200],
                  child: Icon(Icons.block, color: isDark ? Colors.white : Colors.black, size: 22),
                ),
                title: Text(
                  'Block ${_user.name.split(' ').first}',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Blocked ${_user.name}')),
                  );
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: isDark ? const Color(0xFF3A3B3C) : Colors.grey[200],
                  child: Icon(Icons.report, color: isDark ? Colors.white : Colors.black, size: 22),
                ),
                title: Text(
                  'Report Profile',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report submitted')),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context, bool isDark) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF242526) : Colors.white,
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Text(
              'Delete Account?',
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
          ],
        ),
        content: Text(
          'This action is PERMANENT and IRREVERSIBLE.\n\nAll your data will be deleted:\n• Posts\n• Stories\n• Messages\n• Profile information\n\nAre you absolutely sure?',
          style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Forever', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.red),
        ),
      );

      final errorCode = await UserService().deleteAccount(_user.id);

      if (mounted) {
        Navigator.pop(context); // Close loading

        if (errorCode == null) {
          // Success - clear local user and navigate to login
          currentUserProvider.clearUser();
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        } else if (errorCode == 'requires-recent-login') {
          // User needs to re-authenticate
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: isDark ? const Color(0xFF242526) : Colors.white,
              title: Row(
                children: [
                  Icon(Icons.lock_outline, color: Colors.orange, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    'Re-authentication Required',
                    style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18),
                  ),
                ],
              ),
              content: Text(
                'For security, you need to log out and log back in before deleting your account.\n\nPlease log out, sign in again, and then try deleting your account.',
                style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800]),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK', style: TextStyle(color: AppTheme.facebookBlue)),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete account. Please try again.')),
          );
        }
      }
    }
  }


  Future<void> _createStory() async {
    final file = await StorageService().pickImageFromGallery();
    if (file == null) return;

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppTheme.facebookBlue),
        ),
      );
    }

    try {
      final imageUrl = await StorageService().uploadImage(
        file: file,
        folder: 'fakebook/stories/${_user.id}',
      );

      if (imageUrl != null) {
        await StoryService().createStory(
          userId: _user.id,
          imageUrl: imageUrl,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Story posted!')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post story: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOwnProfile = currentUserProvider.currentUser?.id == _user.id;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF18191A) : Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // App Bar
            SliverAppBar(
              pinned: true,
              backgroundColor: isDark ? const Color(0xFF242526) : Colors.white,
              title: Text(
                _user.name,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.search, color: isDark ? Colors.white : Colors.black),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    );
                  },
                ),
              ],
            ),
            
            // Profile Header - StreamBuilder for real-time updates
            SliverToBoxAdapter(
              child: StreamBuilder<UserModel?>(
                stream: UserService().getUserStream(_user.id),
                builder: (context, snapshot) {
                  // Update local _user when stream provides new data
                  if (snapshot.hasData && snapshot.data != null) {
                    final newUser = snapshot.data!;
                    // Check if any field has changed
                    if (_user.avatarUrl != newUser.avatarUrl ||
                        _user.coverUrl != newUser.coverUrl ||
                        _user.name != newUser.name ||
                        _user.bio != newUser.bio ||
                        _user.details.length != newUser.details.length ||
                        _user.friendsCount != newUser.friendsCount) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            _user = newUser;
                          });
                        }
                      });
                    }
                  }
                  return _buildProfileHeader(isDark, isOwnProfile);
                },
              ),
            ),
            
            // Sticky TabBar
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppTheme.facebookBlue,
                  indicatorWeight: 3,
                  labelColor: AppTheme.facebookBlue,
                  unselectedLabelColor: isDark ? Colors.grey : Colors.grey.shade600,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  tabs: _tabs.map((t) => Tab(text: t)).toList(),
                ),
                backgroundColor: isDark ? const Color(0xFF242526) : Colors.white,
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPostsTab(isDark),
            _buildPhotosTab(isDark),
            _buildReelsTab(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark, bool isOwnProfile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Ensure left alignment
      children: [
        // Cover Photo with Profile Picture
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Cover Photo
            GestureDetector(
              onTap: isOwnProfile ? _changeCoverPhoto : null,
              child: Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey.shade300,
                child: _user.coverUrl != null
                    ? ImageHelper.getNetworkImage(
                        imageUrl: _user.coverUrl!,
                        fit: BoxFit.cover,
                      )
                    : Center(
                        child: Icon(
                          Icons.add_photo_alternate,
                          size: 48,
                          color: Colors.grey.shade500,
                        ),
                      ),
              ),
            ),
            // Camera icon on cover
            if (isOwnProfile)
              Positioned(
                right: 12,
                bottom: 12,
                child: GestureDetector(
                  onTap: _changeCoverPhoto,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF3A3B3C) : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            // Profile Picture
            Positioned(
              left: 16,
              bottom: -50,
              child: GestureDetector(
                onTap: isOwnProfile ? _changeProfilePicture : null,
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF242526) : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 70,
                        backgroundImage: ImageHelper.getImageProvider(_user.avatarUrl),
                      ),
                    ),
                    // Camera icon on profile pic
                    if (isOwnProfile)
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF3A3B3C) : Colors.grey.shade200,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? const Color(0xFF242526) : Colors.white,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 60),
        
        // Name and Friends Count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _user.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_user.friendsCount} friends',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey : Colors.grey.shade600,
                ),
              ),
              // Bio section
              if (_user.bio != null && _user.bio!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  _user.bio!,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Action Buttons - Different for own profile vs friend's profile
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: isOwnProfile
              ? _buildOwnProfileButtons(isDark)
              : _buildFriendProfileButtons(isDark),
        ),
        const SizedBox(height: 16),

        // Divider
        Divider(color: isDark ? const Color(0xFF3A3B3C) : Colors.grey.shade300, height: 1),
        
        // Details Section
        _buildDetailsSection(isDark, isOwnProfile),
        
        Divider(color: isDark ? const Color(0xFF3A3B3C) : Colors.grey.shade300, height: 1),
      ],
    );
  }

  Widget _buildDetailsSection(bool isDark, bool isOwnProfile) {
    final textColor = isDark ? Colors.white : Colors.black;
    final iconColor = isDark ? Colors.grey : Colors.grey.shade600;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          
          // Show user details if available
          if (_user.details.isNotEmpty)
            ...(_user.details.map((detail) => _buildDetailRow(
              _getIconForDetail(detail),
              detail,
              textColor,
              iconColor,
            ))),
          
          // Show placeholder details if empty
          if (_user.details.isEmpty) ...[
            _buildDetailRow(Icons.school, 'Add education', textColor, iconColor, isPlaceholder: true),
            _buildDetailRow(Icons.work, 'Add workplace', textColor, iconColor, isPlaceholder: true),
            _buildDetailRow(Icons.home, 'Add current city', textColor, iconColor, isPlaceholder: true),
            _buildDetailRow(Icons.location_on, 'Add hometown', textColor, iconColor, isPlaceholder: true),
          ],
          
          // See your About info
          _buildDetailRow(Icons.more_horiz, 'See your About info', textColor, iconColor),
          
          const SizedBox(height: 12),
          
          // Edit public details button
          if (isOwnProfile)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditProfileScreen(user: _user)),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.facebookBlue,
                  side: const BorderSide(color: AppTheme.facebookBlue),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Edit public details',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Buttons for viewing own profile
  Widget _buildOwnProfileButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _createStory,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add to story'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.facebookBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditProfileScreen(user: _user)),
              );
              if (result == true) {
                final updated = await UserService().getUserById(_user.id);
                if (updated != null) setState(() => _user = updated);
              }
            },
            icon: Icon(Icons.edit, size: 18, color: isDark ? Colors.white : Colors.black),
            label: Text('Edit profile', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFF3A3B3C) : Colors.grey.shade200,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF3A3B3C) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_horiz, color: isDark ? Colors.white : Colors.black),
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(10),
          ),
        ),
      ],
    );
  }

  // Buttons for viewing friend's profile
  Widget _buildFriendProfileButtons(bool isDark) {
    final currentUser = currentUserProvider.currentUser;
    final bool isFriend = currentUser?.friends?.contains(_user.id) ?? false;
    
    return Row(
      children: [
        // Add Friend / Friends button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Send friend request
              if (!isFriend) {
                UserService().sendFriendRequest(
                  currentUserProvider.currentUser?.id ?? '',
                  _user.id,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Friend request sent!')),
                );
              }
            },
            icon: Icon(
              isFriend ? Icons.person : Icons.person_add,
              size: 18,
            ),
            label: Text(isFriend ? 'Friends' : 'Add Friend'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isFriend 
                  ? (isDark ? const Color(0xFF3A3B3C) : Colors.grey.shade200)
                  : AppTheme.facebookBlue,
              foregroundColor: isFriend 
                  ? (isDark ? Colors.white : Colors.black)
                  : Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Message button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Navigate to message screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Message ${_user.name}')),
              );
            },
            icon: MessengerIcon(
              size: 20, 
              color: isDark ? Colors.white : Colors.black,
              boltColor: isDark ? const Color(0xFF3A3B3C) : Colors.grey.shade200, // Match button background
            ),
            label: Text('Message', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFF3A3B3C) : Colors.grey.shade200,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // More button
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF3A3B3C) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            onPressed: () => _showMoreOptions(context, isDark),
            icon: Icon(Icons.more_horiz, color: isDark ? Colors.white : Colors.black),
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(10),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text, Color textColor, Color iconColor, {bool isPlaceholder = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: isPlaceholder ? iconColor : textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForDetail(String detail) {
    final lowerDetail = detail.toLowerCase();
    if (lowerDetail.contains('university') || lowerDetail.contains('studied') || lowerDetail.contains('college')) {
      return Icons.school;
    } else if (lowerDetail.contains('school') || lowerDetail.contains('went to')) {
      return Icons.school_outlined;
    } else if (lowerDetail.contains('works') || lowerDetail.contains('work')) {
      return Icons.work;
    } else if (lowerDetail.contains('lives')) {
      return Icons.home;
    } else if (lowerDetail.contains('from')) {
      return Icons.location_on;
    } else if (lowerDetail.contains('joined')) {
      return Icons.access_time;
    } else if (lowerDetail.contains('gender')) {
      return Icons.person;
    } else if (lowerDetail.contains('relationship')) {
      return Icons.favorite;
    }
    return Icons.info_outline;
  }

  Widget _buildPostsTab(bool isDark) {
    return StreamBuilder<List<PostModel>>(
      stream: PostService().getPostsStream(),
      builder: (context, snapshot) {
        final allPosts = snapshot.data ?? [];
        final userPosts = allPosts.where((p) => p.author.id == _user.id).toList();

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (userPosts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.article_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No posts yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your posts will appear here',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          itemCount: userPosts.length,
          separatorBuilder: (_, __) => Container(
            height: 8,
            color: isDark ? const Color(0xFF18191A) : Colors.grey.shade100,
          ),
          itemBuilder: (context, index) => PostCard(post: userPosts[index]),
        );
      },
    );
  }

  Widget _buildPhotosTab(bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      itemCount: 12,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemBuilder: (context, index) {
        return Container(
          color: Colors.grey.shade300,
          child: ImageHelper.getNetworkImage(
            imageUrl: 'https://picsum.photos/seed/photo$index/400/400',
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  Widget _buildReelsTab(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No reels yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final Color backgroundColor;

  _SliverAppBarDelegate(this._tabBar, {required this.backgroundColor});

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
