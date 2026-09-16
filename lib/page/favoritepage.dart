import 'package:flutter/material.dart';
import 'package:test_app/page/post_detailpage.dart';

class FavoritePage extends StatefulWidget {
  final List<dynamic> posts;
  final Set<String> favoritePostIds;
  final void Function(Map<String, dynamic> post) onToggleFavorite;

  const FavoritePage({
    super.key,
    required this.posts,
    required this.favoritePostIds,
    required this.onToggleFavorite,
  });

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  String _categoryName(Map<String, dynamic> post) {
    final category = post['category'];
    if (category is Map && category['name'] != null) {
      return category['name'].toString();
    }

    for (final key in ['category_name', 'categoryName']) {
      if (post[key] != null && post[key].toString().isNotEmpty) {
        return post[key].toString();
      }
    }

    return 'General';
  }

  String _postId(Map<String, dynamic> post) {
    return (post['id'] ?? post['title'] ?? '').toString();
  }

  @override
  Widget build(BuildContext context) {
    final favoritePosts = widget.posts
        .where((post) => widget.favoritePostIds.contains(_postId(post)))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Favorite',
          style: TextStyle(
            color: Color(0xFF1E1E2C),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1E1E2C)),
      ),
      body: favoritePosts.isEmpty
          ? Center(
              child: Text(
                'Belum ada artikel favorite.',
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              itemCount: favoritePosts.length,
              itemBuilder: (context, index) =>
                  _buildArticleCard(context, favoritePosts[index]),
            ),
    );
  }

  Widget _buildArticleCard(BuildContext context, dynamic rawPost) {
    final post = Map<String, dynamic>.from(rawPost as Map);
    final title = (post['title'] ?? 'Tanpa Judul').toString();
    final categoryName = _categoryName(post);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PostDetailPage(post: post)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 100,
                height: 100,
                color: Colors.grey[200],
                child: const Icon(
                  Icons.article_outlined,
                  color: Color(0xFF0F4C5C),
                  size: 42,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      categoryName,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.grey[300],
                        child: const Icon(
                          Icons.person,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'User • Recently',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Hapus dari favorite',
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () {
                widget.onToggleFavorite(post);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}