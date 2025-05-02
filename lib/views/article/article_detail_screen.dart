import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ArticleDetailScreen extends StatefulWidget {
  final String? title;
  final String? description;
  final String? imageUrl;
  final String? sourceName;
  final String? content;
  final String? url;
  final String? author;
  final DateTime? publishedAt;

  const ArticleDetailScreen({
    Key? key,
    this.title,
    this.description,
    this.imageUrl,
    this.sourceName,
    this.content,
    this.url,
    this.author,
    this.publishedAt,
  }) : super(key: key);

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  bool _isBookmarked = false;
  bool _isLoading = true;
  double _textScaleFactor = 1.0;

  @override
  void initState() {
    super.initState();
    _checkIfBookmarked();
  }

  Future<void> _checkIfBookmarked() async {
    setState(() {
      _isBookmarked = false;
      _isLoading = false;
    });
  }

  void _openArticleUrl() async {
    if (widget.url != null && widget.url!.isNotEmpty) {
      try {
        final Uri uri = Uri.parse(widget.url!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Could not launch URL')));
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Invalid URL: ${widget.url}')));
      }
    }
  }

  void _increaseTextSize() {
    setState(() {
      _textScaleFactor += 0.1;
      if (_textScaleFactor > 1.5) _textScaleFactor = 1.5;
    });
  }

  void _decreaseTextSize() {
    setState(() {
      _textScaleFactor -= 0.1;
      if (_textScaleFactor < 0.8) _textScaleFactor = 0.8;
    });
  }

  String _formatContent(String? content) {
    if (content == null || content.isEmpty) {
      return '<p>No content available</p>';
    }

    final cleanContent =
        content.replaceAll(RegExp(r'\[.*\]$'), '').replaceAll('...', '').trim();

    if (cleanContent.isEmpty) {
      return '<p>No content available</p>';
    }

    if (!cleanContent.startsWith('<')) {
      return '<p>$cleanContent</p>';
    }

    return cleanContent;
  }

  Future<void> _saveToBookmarks(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to save bookmarks.')),
      );
      return;
    }

    final bookmarkData = {
      'title': widget.title,
      'description': widget.description,
      'imageUrl': widget.imageUrl,
      'sourceName': widget.sourceName,
      'content': widget.content,
      'url': widget.url,
      'author': widget.author,
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('bookmarks')
              .doc(user.uid)
              .collection('userBookmarks')
              .where('title', isEqualTo: widget.title)
              .get();

      if (snapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This article is already in your bookmarks.'),
          ),
        );
        return;
      }

      await FirebaseFirestore.instance
          .collection('bookmarks')
          .doc(user.uid)
          .collection('userBookmarks')
          .add(bookmarkData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Article saved to bookmarks.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving bookmark: $e')));
    }
  }

  Future<void> _incrementReadingHistory(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final historyData = {
      'title': widget.title,
      'description': widget.description,
      'imageUrl': widget.imageUrl,
      'sourceName': widget.sourceName,
      'content': widget.content,
      'url': widget.url,
      'author': widget.author,
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('readingHistory')
          .doc(user.uid)
          .collection('userHistory')
          .add(historyData);
    } catch (e) {
      // Handle error silently
    }
  }

  String _getDomainFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return url.length > 50 ? '${url.substring(0, 50)}...' : url;
    }
  }

  @override
  Widget build(BuildContext context) {
    _incrementReadingHistory(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Article Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildArticleImage(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.title ?? 'No title',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Author and source information
                  if (widget.author != null || widget.sourceName != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          if (widget.author != null)
                            Text(
                              'By ${widget.author!}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          if (widget.author != null &&
                              widget.sourceName != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Text(
                                '•',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          if (widget.sourceName != null)
                            Text(
                              widget.sourceName!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),

                  // Description
                  if (widget.description != null &&
                      widget.description!.isNotEmpty)
                    Column(
                      children: [
                        Text(
                          widget.description!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),

                  // Content
                  Html(
                    data: _formatContent(widget.content),
                    style: {
                      "body": Style(
                        fontSize: FontSize(16 * _textScaleFactor),
                        lineHeight: LineHeight(1.6),
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                      ),
                      "p": Style(margin: Margins.only(bottom: 16)),
                      "a": Style(
                        color: Theme.of(context).primaryColor,
                        textDecoration: TextDecoration.none,
                      ),
                    },
                    onLinkTap: (String? url, _, __) async {
                      if (url != null && url.isNotEmpty) {
                        try {
                          final Uri uri = Uri.parse(url);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Could not open link: $url'),
                            ),
                          );
                        }
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // Source URL Section - Matches your reference image
                  if (widget.url != null && widget.url!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        const Text(
                          'Source:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _openArticleUrl,
                          child: Text(
                            _getDomainFromUrl(widget.url!),
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.bookmark_add_rounded,
                label: 'Save',
                onTap: () => _saveToBookmarks(context),
              ),
              _buildActionButton(
                icon: Icons.text_increase,
                label: 'Increase Text',
                onTap: _increaseTextSize,
              ),
              _buildActionButton(
                icon: Icons.text_decrease,
                label: 'Decrease Text',
                onTap: _decreaseTextSize,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArticleImage() {
    if (widget.imageUrl == null ||
        widget.imageUrl!.isEmpty ||
        !Uri.parse(widget.imageUrl!).isAbsolute) {
      return Container(
        height: 240,
        color: Colors.grey.shade300,
        child: const Icon(Icons.image_not_supported, size: 50),
      );
    }

    return CachedNetworkImage(
      imageUrl: widget.imageUrl!,
      height: 240,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder:
          (context, url) => Container(
            height: 240,
            color: Colors.grey.shade300,
            child: const Center(child: CircularProgressIndicator()),
          ),
      errorWidget:
          (context, url, error) => Container(
            height: 240,
            color: Colors.grey.shade300,
            child: const Icon(Icons.image_not_supported, size: 50),
          ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color ?? Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
