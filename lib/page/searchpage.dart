import 'package:flutter/material.dart';
import 'package:test_app/page/post_detailpage.dart';

class SearchPage extends StatefulWidget {
  final List<dynamic> posts;

  const SearchPage({super.key, required this.posts});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  List<Map<String, dynamic>> get _filteredPosts {
    final query = _query.trim().toLowerCase();
    return widget.posts
        .whereType<Map>()
        .map((post) => Map<String, dynamic>.from(post))
        .where((post) {
          if (query.isEmpty) return true;
          final title = (post['title'] ?? '').toString().toLowerCase();
          final content = (post['content'] ?? '').toString().toLowerCase();
          final category = _categoryName(post).toLowerCase();
          return title.contains(query) ||
              content.contains(query) ||
              category.contains(query);
        })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredPosts;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFA),
        elevation: 0,
        title: const Text(
          'Cari Artikel',
          style: TextStyle(
            color: Color(0xFF1E1E2C),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1E1E2C)),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Cari judul, isi, atau kategori...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF0F4C5C)),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Hapus pencarian',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF0F4C5C),
                    width: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _query.trim().isEmpty
                  ? 'Semua artikel'
                  : '${results.length} artikel ditemukan',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E2C),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Text(
                        'Artikel yang cocok belum ditemukan.',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.separated(
                      itemCount: results.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _buildResultCard(context, results[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, Map<String, dynamic> post) {
    final title = (post['title'] ?? 'Tanpa Judul').toString();
    final content = (post['content'] ?? 'Tidak ada isi konten.').toString();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PostDetailPage(post: post)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.article_outlined,
                color: Color(0xFF0F4C5C),
                size: 32,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _categoryName(post),
                      style: const TextStyle(
                        color: Color(0xFF0F4C5C),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E2C),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
