import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/video_model.dart';

class VideoService {
  // Pexels API Key - For production, use environment variables or secure storage
  // The actual key is stored in .env (gitignored) for reference
  static const String _apiKey = 'PUaAq8so2S5d0vYudcBIBccUvS668gq3xgPwGTtmCZOeHSJt17BlO2qy';
  static const String _baseUrl = 'https://api.pexels.com/videos';

  /// Fetch popular videos from Pexels API
  Future<List<VideoModel>> getPopularVideos({int perPage = 15, int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/popular?per_page=$perPage&page=$page'),
        headers: {'Authorization': _apiKey},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final videos = (data['videos'] as List?) ?? [];
        return videos.map((v) => VideoModel.fromPexelsJson(v)).toList();
      } else {
        debugPrint('Pexels API Error: ${response.statusCode}');
        return _getFallbackVideos();
      }
    } catch (e) {
      debugPrint('VideoService Error: $e');
      return _getFallbackVideos();
    }
  }

  /// Search videos by query
  Future<List<VideoModel>> searchVideos(String query, {int perPage = 15}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search?query=$query&per_page=$perPage'),
        headers: {'Authorization': _apiKey},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final videos = (data['videos'] as List?) ?? [];
        return videos.map((v) => VideoModel.fromPexelsJson(v)).toList();
      } else {
        return _getFallbackVideos();
      }
    } catch (e) {
      debugPrint('VideoService Search Error: $e');
      return _getFallbackVideos();
    }
  }

  /// Fallback videos when API is unavailable
  List<VideoModel> _getFallbackVideos() {
    // High-quality, royalty-free videos from Pixabay/Pexels (direct links)
    return [
      VideoModel(
        id: 'fallback_1',
        videoUrl: 'https://videos.pexels.com/video-files/3571264/3571264-sd_640_360_30fps.mp4',
        thumbnailUrl: 'https://images.pexels.com/videos/3571264/free-video-3571264.jpg?w=640',
        userName: 'Nature Vibes',
        description: 'Beautiful nature scenery 🌿',
        duration: 15,
      ),
      VideoModel(
        id: 'fallback_2',
        videoUrl: 'https://videos.pexels.com/video-files/856973/856973-sd_640_360_25fps.mp4',
        thumbnailUrl: 'https://images.pexels.com/videos/856973/free-video-856973.jpg?w=640',
        userName: 'City Life',
        description: 'Urban exploration 🏙️',
        duration: 20,
      ),
      VideoModel(
        id: 'fallback_3',
        videoUrl: 'https://videos.pexels.com/video-files/1409899/1409899-sd_640_360_25fps.mp4',
        thumbnailUrl: 'https://images.pexels.com/videos/1409899/free-video-1409899.jpg?w=640',
        userName: 'Ocean Waves',
        description: 'Relaxing beach vibes 🌊',
        duration: 18,
      ),
      VideoModel(
        id: 'fallback_4',
        videoUrl: 'https://videos.pexels.com/video-files/3015510/3015510-sd_640_360_24fps.mp4',
        thumbnailUrl: 'https://images.pexels.com/videos/3015510/free-video-3015510.jpg?w=640',
        userName: 'Tech World',
        description: 'Future is here 🚀',
        duration: 12,
      ),
      VideoModel(
        id: 'fallback_5',
        videoUrl: 'https://videos.pexels.com/video-files/4434242/4434242-sd_506_960_25fps.mp4',
        thumbnailUrl: 'https://images.pexels.com/videos/4434242/free-video-4434242.jpg?w=640',
        userName: 'Adventure Time',
        description: 'Life is an adventure ⛰️',
        duration: 22,
      ),
      VideoModel(
        id: 'fallback_6',
        videoUrl: 'https://videos.pexels.com/video-files/2795173/2795173-sd_640_360_25fps.mp4',
        thumbnailUrl: 'https://images.pexels.com/videos/2795173/free-video-2795173.jpg?w=640',
        userName: 'Night Sky',
        description: 'Stars and beyond ✨',
        duration: 16,
      ),
    ];
  }
}
