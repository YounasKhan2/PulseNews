import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';
import '../views/article/article_detail_screen.dart';
import 'package:intl/intl.dart'; // Add this for date formatting

class LatestNewsList extends StatefulWidget {
  const LatestNewsList({super.key});

  @override
  State<LatestNewsList> createState() => _LatestNewsListState();
}

class _LatestNewsListState extends State<LatestNewsList> {
  List<dynamic> _latestNews = [];
  bool _isLoading = true;
  bool _isFetchingMore = false;
  int _page = 1;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchLatestNews();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchLatestNews({bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (mounted) {
        setState(() {
          _isFetchingMore = true;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
    }

    try {
      final response = await http.get(
        Uri.parse(
          '${ApiService.baseUrl}/everything?q=news&page=$_page&apiKey=${ApiService.apiKey}',
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            if (isLoadMore) {
              _latestNews.addAll(
                data['articles']
                    .where(
                      (article) =>
                  article['urlToImage'] != null &&
                      article['urlToImage'].toString().trim().isNotEmpty &&
                      article['title'] != null &&
                      article['source'] != null &&
                      article['source']['name'] != null,
                )
                    .toList(),
              );
            } else {
              _latestNews =
                  data['articles']
                      .where(
                        (article) =>
                    article['urlToImage'] != null &&
                        article['urlToImage']
                            .toString()
                            .trim()
                            .isNotEmpty &&
                        article['title'] != null &&
                        article['source'] != null &&
                        article['source']['name'] != null,
                  )
                      .toList();
            }
            _isLoading = false;
            _isFetchingMore = false;
          });
        }
      } else {
        throw Exception('Failed to load latest news');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isFetchingMore = false;
        });
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching news: $e')));
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent &&
        !_isFetchingMore) {
      _page++;
      _fetchLatestNews(isLoadMore: true);
    }
  }

  String _formatPublishedDate(String? dateStr) {
    if (dateStr == null) return 'Unknown date';
    try {
      final DateTime date = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return 'Unknown date';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: SizedBox(
          height: 60,
          width: 60,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            strokeWidth: 3,
          ),
        ),
      );
    }

    if (_latestNews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No latest news available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _fetchLatestNews(),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepPurple,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: _latestNews.length + (_isFetchingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _latestNews.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: SizedBox(
                height: 40,
                width: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                  strokeWidth: 2,
                ),
              ),
            ),
          );
        }

        final news = _latestNews[index];
        final imageUrl = news['urlToImage'] ?? '';
        final title = news['title'] ?? 'No Title';
        final description = news['description'] ?? '';
        final publishedAt = news['publishedAt'];

        return Container(
          margin: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface, // Adapt to theme
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ArticleDetailScreen(
                      title: news['title'] ?? 'No Title',
                      description: news['description'] ?? 'No Description',
                      imageUrl: news['urlToImage']?.isNotEmpty == true
                          ? news['urlToImage']
                          : '',
                      sourceName: news['source']?['name'] ?? 'Unknown Source',
                      content: news['content'],
                    ),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Section
                  Hero(
                    tag: 'image_${news['title']}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade100,
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Content Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Source & Date row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Source Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                news['source']?['name'] ?? 'Unknown Source',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ),

                            // Date
                            Text(
                              _formatPublishedDate(publishedAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Title
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8),

                        // Description
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 12),

                        // Read more link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Read more',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: Colors.deepPurple,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
