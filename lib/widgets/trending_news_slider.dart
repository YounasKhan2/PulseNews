import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../views/article/article_detail_screen.dart';

class TrendingNewsSlider extends StatefulWidget {
  const TrendingNewsSlider({super.key});

  @override
  State<TrendingNewsSlider> createState() => _TrendingNewsSliderState();
}

class _TrendingNewsSliderState extends State<TrendingNewsSlider> {
  List<dynamic> _trendingNews = [];
  bool _isLoading = true;
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _fetchTrendingNews();

    // Auto slide functionality
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _startAutoSlide();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _trendingNews.isNotEmpty) {
        final nextPage = (_currentPage + 1) % _trendingNews.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        _startAutoSlide();
      }
    });
  }

  Future<void> _fetchTrendingNews() async {
    try {
      final data = await ApiService.fetchArticles(
        ApiService.getTrendingNewsUrl(),
      );
      if (mounted) {
        setState(() {
          _trendingNews = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching trending news: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    if (_trendingNews.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _trendingNews.length,
            itemBuilder: (context, index) {
              return _buildNewsCard(index);
            },
          ),
        ),
        const SizedBox(height: 12),
        _buildPageIndicator(),
      ],
    );
  }



  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.newspaper,
            size: 60,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No trending news available.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _fetchTrendingNews();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(int index) {
    final news = _trendingNews[index];
    final imageUrl = news['urlToImage'] ?? '';
    final title = news['title'] ?? 'No Title';
    final sourceName = news['source']?['name'] ?? 'Unknown Source';
    final description = news['description'] ?? 'No Description';
    final content = news['content'];
    final publishedAt = news['publishedAt'];

    // Format date if available
    String formattedDate = '';
    if (publishedAt != null) {
      try {
        final date = DateTime.parse(publishedAt);
        final now = DateTime.now();
        final difference = now.difference(date);

        if (difference.inDays > 0) {
          formattedDate = '${difference.inDays}d ago';
        } else if (difference.inHours > 0) {
          formattedDate = '${difference.inHours}h ago';
        } else {
          formattedDate = '${difference.inMinutes}m ago';
        }
      } catch (e) {
        formattedDate = '';
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Hero(
        tag: 'trending_${news['title']}',
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ArticleDetailScreen(
                  title: title,
                  description: description,
                  imageUrl: imageUrl,
                  sourceName: sourceName,
                  content: content,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Background Image
                  Positioned.fill(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey,
                              size: 60,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Theme.of(context).colorScheme.background.withOpacity(0.1),
                            Theme.of(context).colorScheme.background.withOpacity(0.6),
                            Theme.of(context).colorScheme.background.withOpacity(0.9),
                          ],
                          stops: const [0.0, 0.3, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Content
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badge - Trending + Source
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.trending_up,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'TRENDING',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  sourceName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              if (formattedDate.isNotEmpty)
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Title
                          Text(
                            title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Read More Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Read More',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _trendingNews.length,
            (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? Colors.deepPurple
                : Colors.grey.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
