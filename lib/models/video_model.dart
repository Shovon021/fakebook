class VideoModel {
  final String id;
  final String videoUrl;
  final String thumbnailUrl;
  final String userName;
  final String userAvatar;
  final int likes;
  final String description;
  final int duration; // in seconds

  VideoModel({
    required this.id,
    required this.videoUrl,
    required this.thumbnailUrl,
    this.userName = 'Unknown',
    this.userAvatar = '',
    this.likes = 0,
    this.description = '',
    this.duration = 0,
  });

  factory VideoModel.fromPexelsJson(Map<String, dynamic> json) {
    // Pexels API response structure
    final videoFiles = json['video_files'] as List? ?? [];
    final user = json['user'] as Map<String, dynamic>? ?? {};
    
    // Get the best quality video (prefer HD)
    String videoUrl = '';
    for (final file in videoFiles) {
      if (file['quality'] == 'hd' || file['quality'] == 'sd') {
        videoUrl = file['link'] ?? '';
        break;
      }
    }
    if (videoUrl.isEmpty && videoFiles.isNotEmpty) {
      videoUrl = videoFiles.first['link'] ?? '';
    }

    return VideoModel(
      id: json['id']?.toString() ?? '',
      videoUrl: videoUrl,
      thumbnailUrl: json['image'] ?? '',
      userName: user['name'] ?? 'Pexels User',
      userAvatar: user['url'] ?? '',
      likes: 0,
      description: '',
      duration: json['duration'] ?? 0,
    );
  }
}
