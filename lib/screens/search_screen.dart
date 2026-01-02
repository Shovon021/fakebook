import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../utils/image_helper.dart';
import 'profile_screen.dart';
import '../widgets/empty_states.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final UserService _userService = UserService();
  
  List<UserModel> _searchResults = [];
  bool _isSearching = false;
  bool _isLoading = false;
  String _query = '';

  // Mock recent searches for demo
  final List<String> _recentSearches = [
    'Flutter Developers',
    'Mark Zuckerberg',
    'Tech News',
  ];

  void _onSearchChanged(String value) async {
    setState(() {
      _query = value;
      _isSearching = value.isNotEmpty;
      _isLoading = value.isNotEmpty;
    });

    if (value.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    // Debounce - wait a bit before searching
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Check if query is still the same (user might have typed more)
    if (value != _query) return;

    final results = await _userService.searchUsers(value);
    if (mounted && value == _query) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF18191A) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF242526) : Colors.white,
        elevation: 1,
        leading: BackButton(color: isDark ? Colors.white : Colors.black),
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search Facebook',
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: isDark ? const Color(0xFFB0B3B8) : Colors.grey,
            ),
          ),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16,
          ),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
              onPressed: () {
                _controller.clear();
                _onSearchChanged('');
              },
            ),
        ],
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_query.isEmpty) {
      return _buildRecentSearches(isDark);
    }

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: EmptyStates.noResults(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return ListTile(
          leading: CircleAvatar(
            radius: 24,
            backgroundImage: ImageHelper.getImageProvider(user.avatarUrl),
          ),
          title: Text(
            user.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          subtitle: Text(
            'Person', // Or 'Friend' if connected
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(user: user),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRecentSearches(bool isDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : AppTheme.black,
                ),
              ),
              Text(
                'See All',
                style: TextStyle(
                  color: AppTheme.facebookBlue,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        ..._recentSearches.map((search) => ListTile(
          leading: CircleAvatar(
            radius: 16,
            backgroundColor: isDark ? const Color(0xFF3A3B3C) : AppTheme.facebookBlue,
            child: const Icon(Icons.search, size: 18, color: Colors.white),
          ),
          title: Text(
            search,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.close, size: 18, color: isDark ? Colors.white : Colors.grey),
            onPressed: () {
              setState(() {
                _recentSearches.remove(search);
              });
            },
          ),
          onTap: () {
            _controller.text = search;
            _onSearchChanged(search);
          },
        )),
      ],
    );
  }
}
