import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _recentSearches = [
    'Flutter Developers Group',
    'Dart Programming Language',
    'Mark Zuckerberg',
    'SpaceX Launch',
    'Viral Cat Videos',
  ];

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
          IconButton(
            icon: Icon(Icons.mic, color: isDark ? Colors.white : Colors.black),
            onPressed: () {},
          )
        ],
      ),
      body: ListView(
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
            onTap: () {},
          )),
        ],
      ),
    );
  }
}
