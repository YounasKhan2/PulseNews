import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Primary API Key
  static const String baseUrl = 'https://newsapi.org/v2';
  static const String apiKey = '67286b996b91454a92ed458e449b50bd';

  // Fallback API details
  static const String fallbackUrl = 'https://newsapi.org/v2';
  static const String fallbackApiKey = 'd8e40efffb8947a8b1c8aa8b91f83fcc';

  static const int dailyRequestLimit = 100;

  static Future<bool> _canMakeRequest() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T').first;

      final lastResetDate = prefs.getString('lastResetDate') ?? '';
      int requestCount = prefs.getInt('requestCount') ?? 0;

      if (lastResetDate != today) {
        // Reset the counter if the date has changed
        await prefs.setString('lastResetDate', today);
        await prefs.setInt('requestCount', 0);
        requestCount = 0;
      }

      return requestCount < dailyRequestLimit;
    } catch (e) {
      print('Error accessing SharedPreferences: $e');
      return true; // Allow requests if SharedPreferences fails
    }
  }

  static Future<void> _incrementRequestCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int requestCount = prefs.getInt('requestCount') ?? 0;
      await prefs.setInt('requestCount', requestCount + 1);
    } catch (e) {
      print('Error incrementing request count in SharedPreferences: $e');
    }
  }

  static String getTrendingNewsUrl() {
    return '$baseUrl/top-headlines?country=us&apiKey=$apiKey';
  }

  static String getFallbackNewsUrl() {
    return '$fallbackUrl/top-headlines?country=us&apiKey=$fallbackApiKey';
  }

  static Future<List<dynamic>> fetchArticles(String url) async {
    if (!await _canMakeRequest()) {
      print('Daily API request limit reached. Switching to fallback API.');
      return await _fetchFallbackArticles();
    }

    await Future.delayed(
      const Duration(seconds: 1),
    ); // Add a delay to throttle requests
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        await _incrementRequestCount(); // Increment the request count
        final data = json.decode(response.body);
        return data['articles'] ?? [];
      } else if (response.statusCode == 429) {
        print('Primary API rate limit reached. Switching to fallback API.');
        return await _fetchFallbackArticles();
      } else {
        throw Exception('Failed to fetch articles: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching articles from primary API: $e');
      return await _fetchFallbackArticles(); // Fallback in case of other errors
    }
  }

  static Future<List<dynamic>> _fetchFallbackArticles() async {
    try {
      final response = await http.get(Uri.parse(getFallbackNewsUrl()));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['articles'] ?? []; // Ensure consistency with primary APIr
      } else {
        throw Exception(
          'Failed to fetch fallback articles: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching articles from fallback API: $e');
      throw Exception('Error fetching fallback articles: $e');
    }
  }
}
