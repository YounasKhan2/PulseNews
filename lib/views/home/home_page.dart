import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_navigation_bar.dart';
import '../../widgets/trending_news_slider.dart';
import '../../widgets/latest_news_list.dart';
import 'categories_screen.dart';
import 'bookmarks_screen.dart';
import 'profile_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/api_service.dart';
import '../article/article_detail_screen.dart';
import 'package:intl/intl.dart'; // Add this for date formatting


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CategoriesScreen(),
    const BookmarksScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // Display the selected screen
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _trendingNews = [];
  List<dynamic> _latestNews = [];
  bool _isLoadingTrending = true;
  bool _isLoadingLatest = true;
  bool _isFetchingMoreLatest = false;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _fetchTrendingNews();
    _fetchLatestNews();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchTrendingNews() async {
    try {
      final data = await ApiService.fetchArticles(
        ApiService.getTrendingNewsUrl(),
      );
      if (mounted) {
        setState(() {
          _trendingNews = data;
          _isLoadingTrending = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingTrending = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching trending news: $e')),
      );
    }
  }

  Future<void> _fetchLatestNews({bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (mounted) {
        setState(() {
          _isFetchingMoreLatest = true;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoadingLatest = true;
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
            _isLoadingLatest = false;
            _isFetchingMoreLatest = false;
          });
        }
      } else {
        throw Exception('Failed to load latest news');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLatest = false;
          _isFetchingMoreLatest = false;
        });
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching news: $e')));
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !_isFetchingMoreLatest) {
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

  Future<void> _handleRefresh() async {
    _page = 1;
    await Future.wait([
      _fetchTrendingNews(),
      _fetchLatestNews(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'News Feed',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // Trending News Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trending News',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary, // Removed const
                    ),
                  ),
                ],
              ),
            ),

            // Trending News Cards
            if (_isLoadingTrending)
              const SizedBox(
                height: 220,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_trendingNews.isEmpty)
              const SizedBox(
                height: 220,
                child: Center(
                  child: Text(
                    'No trending news available.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              )
            else
              _buildTrendingNewsSlider(),

            // Latest News Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Latest News',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary, // Removed const
                    ),
                  ),
                ],
              ),
            ),

            // Latest News List embedded directly in the ListView
            if (_isLoadingLatest)
              SizedBox(
                height: 60,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary, // Removed const
                    ),
                    strokeWidth: 3,
                  ),
                ),
              )
            else
              _buildLatestNewsList(),

            // Loading indicator for infinite scroll
            if (_isFetchingMoreLatest)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: SizedBox(
                    height: 40,
                    width: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary, // Removed const
                      ),
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingNewsSlider() {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _trendingNews.length,
        itemBuilder: (context, index) {
          final news = _trendingNews[index];
          final imageUrl = news['urlToImage'] ?? '';
          final title = news['title'] ?? 'No Title';
          final sourceName = news['source']?['name'] ?? 'Unknown Source';
          final description = news['description'] ?? 'No Description';
          final content = news['content'];

          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) => ArticleDetailScreen(
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
              width: 320,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        imageUrl,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox(
                            height: 140,
                            child: Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        sourceName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLatestNewsList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: _latestNews.length,
      itemBuilder: (context, index) {
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
            color: Theme.of(context).colorScheme.surface, // Adapt to theme
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
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                news['source']?['name'] ?? 'Unknown Source',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.primary,
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
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
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

