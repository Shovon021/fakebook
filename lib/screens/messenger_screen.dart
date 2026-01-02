import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../data/dummy_data.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_ui.dart';

class MessengerScreen extends StatelessWidget {
  const MessengerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        leading: BackButton(color: isDark ? Colors.white : Colors.black),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: CachedNetworkImageProvider(
                DummyData.currentUser.avatarUrl,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Chats',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.camera_alt, color: isDark ? Colors.white : Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.edit, color: isDark ? Colors.white : Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2B2C) : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: isDark ? Colors.grey : Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Search',
                    style: TextStyle(
                      color: isDark ? Colors.grey : Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Active Now
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: DummyData.users.length,
                itemBuilder: (context, index) {
                  final user = DummyData.users[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundImage: CachedNetworkImageProvider(user.avatarUrl),
                            ),
                            if (index % 2 == 0) // random active status
                               Positioned(
                                 right: 2,
                                 bottom: 2,
                                 child: Container(
                                   width: 14,
                                   height: 14,
                                   decoration: BoxDecoration(
                                     color: Colors.green,
                                     shape: BoxShape.circle,
                                     border: Border.all(
                                       color: isDark ? Colors.black : Colors.white,
                                       width: 2,
                                     ),
                                   ),
                                 ),
                               ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.name.split(' ')[0], // First name
                          style: TextStyle(
                            color: isDark ? Colors.grey[300] : Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Chat List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: DummyData.users.length,
              itemBuilder: (context, index) {
                final user = DummyData.users[index];
                final isUnread = index < 3;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    children: [
                       CircleAvatar(
                         radius: 28,
                         backgroundImage: CachedNetworkImageProvider(user.avatarUrl),
                       ),
                       const SizedBox(width: 12),
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(
                               user.name,
                               style: TextStyle(
                                 color: isDark ? Colors.white : Colors.black,
                                 fontWeight: FontWeight.w600,
                                 fontSize: 16,
                               ),
                             ),
                             const SizedBox(height: 2),
                             Row(
                               children: [
                                 Expanded(
                                   child: index == 0
                                     ? const TypingIndicator()
                                     : Text(
                                         isUnread 
                                            ? 'You: Hey, are we still on for later?' 
                                            : 'Sent a photo.',
                                         maxLines: 1,
                                         overflow: TextOverflow.ellipsis,
                                         style: TextStyle(
                                           color: isDark 
                                               ? (isUnread ? Colors.white : Colors.grey)
                                               : (isUnread ? Colors.black : Colors.grey[600]),
                                           fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                                           fontSize: 14,
                                         ),
                                       ),
                                 ),
                                 const SizedBox(width: 8),
                                 Text(
                                   '${index + 1}h',
                                   style: TextStyle(
                                     color: isDark ? Colors.grey : Colors.grey[600],
                                     fontSize: 12,
                                   ),
                                 ),
                               ],
                             ),
                           ],
                         ),
                       ),
                       if (isUnread)
                         Container(
                           width: 12,
                           height: 12,
                           decoration: const BoxDecoration(
                             color: AppTheme.facebookBlue,
                             shape: BoxShape.circle,
                           ),
                         ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
