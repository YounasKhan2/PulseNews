import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../article/article_detail_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  Future<List<Map<String, dynamic>>> _fetchBookmarks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return [];
    }

    final snapshot =
    await FirebaseFirestore.instance
        .collection('bookmarks')
        .doc(user.uid)
        .collection('userBookmarks')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Include the document ID for deletion
      return data;
    }).toList();
  }

  Future<void> _deleteBookmark(String bookmarkId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('bookmarks')
        .doc(user.uid)
        .collection('userBookmarks')
        .doc(bookmarkId)
        .delete();
  }

  Future<void> _deleteAllBookmarks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot =
    await FirebaseFirestore.instance
        .collection('bookmarks')
        .doc(user.uid)
        .collection('userBookmarks')
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, size: 24),
            color: Colors.white,
            tooltip: 'Delete all bookmarks',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  title: const Text('Delete All Bookmarks'),
                  content: const Text(
                    'Are you sure you want to delete all bookmarks? This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete All'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await _deleteAllBookmarks();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('All bookmarks deleted'),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: RefreshIndicator(
          color: Theme.of(context).colorScheme.primary,
          onRefresh: () async {
            await _fetchBookmarks();
          },
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchBookmarks(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading bookmarks',
                        style: theme.textTheme.titleMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          // Force refresh
                          _fetchBookmarks();
                        },
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                );
              }

              final bookmarks = snapshot.data ?? [];

              if (bookmarks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_border,
                        size: 80,
                        color: Colors.deepPurple.shade200,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No bookmarks yet',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.deepPurple.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Save articles to read them later',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: bookmarks.length,
                  itemBuilder: (context, index) {
                    final bookmark = bookmarks[index];
                    return _buildBookmarkCard(context, bookmark);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBookmarkCard(BuildContext context, Map<String, dynamic> bookmark) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ArticleDetailScreen(
                title: bookmark['title'] ?? 'No Title',
                description: bookmark['description'] ?? 'No Description',
                imageUrl: bookmark['imageUrl'] ?? '',
                sourceName: bookmark['sourceName'] ?? 'Unknown Source',
                content: bookmark['content'],
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section with gradient overlay
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  // Article image
                  SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: bookmark['imageUrl'] != null
                        ? Image.network(
                      bookmark['imageUrl'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                          ),
                        );
                      },
                    )
                        : Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.article, size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                  // Delete button with semi-transparent background
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () async {
                          // Confirm deletion
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Bookmark'),
                              content: const Text('Are you sure you want to remove this bookmark?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await _deleteBookmark(bookmark['id']);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Bookmark deleted'),
                                  backgroundColor: Theme.of(context).colorScheme.surface,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  action: SnackBarAction(
                                    label: 'UNDO',
                                    textColor: Colors.white,
                                    onPressed: () {
                                      // Ideally add an undo feature here
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Not implemented')),
                                      );
                                    },
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Icon(Icons.delete_outline, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bookmark['title'] ?? 'No Title',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bookmark['description'] ?? 'No description available',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Source name with icon
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.public, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                bookmark['sourceName'] ?? 'Unknown Source',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Read more button
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ArticleDetailScreen(
                                title: bookmark['title'] ?? 'No Title',
                                description: bookmark['description'] ?? 'No Description',
                                imageUrl: bookmark['imageUrl'] ?? '',
                                sourceName: bookmark['sourceName'] ?? 'Unknown Source',
                                content: bookmark['content'],
                              ),
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Read',
                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward, size: 16, color: Colors.deepPurple),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
