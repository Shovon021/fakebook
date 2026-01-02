import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../theme/app_theme.dart';
import '../widgets/post_card.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF18191A) : const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text(
          'Groups',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF242526) : Colors.white,
        elevation: 0,
        leading: BackButton(color: isDark ? Colors.white : AppTheme.black),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: isDark ? Colors.white : AppTheme.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.add_circle, color: isDark ? Colors.white : AppTheme.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // "Your Groups" Horizontal List
            Container(
              color: isDark ? const Color(0xFF242526) : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                     child: Text(
                       'Your groups',
                       style: TextStyle(
                         fontSize: 17,
                         fontWeight: FontWeight.bold,
                         color: isDark ? Colors.white : AppTheme.black,
                       ),
                     ),
                   ),
                   const SizedBox(height: 12),
                   SizedBox(
                     height: 110,
                     child: ListView.builder(
                       scrollDirection: Axis.horizontal,
                       padding: const EdgeInsets.symmetric(horizontal: 12),
                       itemCount: 8,
                       itemBuilder: (context, index) {
                         return _buildGroupIcon(index, isDark);
                       },
                     ),
                   ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            
            // "Updated Recently" / Feed
            // We'll reuse PostCards but simulate they are from groups by modifying header text 
            // naturally we'd need a GroupModel, but for UI fidelity we can just list posts.
            // In a real app we'd map "Posted in GroupName" text.
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: DummyData.posts.length,
              itemBuilder: (context, index) {
                // Hack: Pass a modified post model or just show regular posts for now to simulate feed
                // Ideally we wrap it in a Column to show a "Suggested for you" or "Group Activity" header
                final post = DummyData.posts[index];
                return Column(
                   children: [
                     PostCard(post: post),
                     const SizedBox(height: 8),
                   ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupIcon(int index, bool isDark) {
    return Container(
      width: 80,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage('https://picsum.photos/seed/group$index/200/200'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Group ${index + 1}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : AppTheme.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
