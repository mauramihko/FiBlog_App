import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test_app/page/create_post.dart';
import 'package:test_app/page/favoritepage.dart';
import 'package:test_app/page/post_detailpage.dart';
import 'package:test_app/page/searchpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  int _selectedTab = 0;

  final String _baseUrl = 'http://localhost:5000/api';
  List<dynamic> _posts = [];
  List<dynamic> _categories = [];
  final Set<String> _favoritePostIds = <String>{};
  bool _isLoading = true;
  bool _isLoadingCategories = false;

  final List<String> _tabs = ['Me', 'Edit task', 'Categories'];

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  // Ambil data post dari server Express
  Future<void> _fetchPosts() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('$_baseUrl/posts'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _posts = data is List ? data : (data['data'] ?? []);
        });
      }
    } catch (e) {
      debugPrint('Error fetch posts: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 100,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Transform.translate(
            offset: const Offset(0, 13),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: 'Fi',
                    style: TextStyle(color: Color(0xFF333333)),
                  ),
                  TextSpan(
                    text: 'Blog',
                    style: TextStyle(color: Color(0xFF1E2F4F)),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[300],
              child: ClipOval(
                child: Image.asset(
                  'asset/fotoku.png',
                  fit: BoxFit.cover,
                  width: 36,
                  height: 36,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.person, color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchPosts, // Tarik ke bawah buat reload data
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                const Text(
                  'Hi, Good Day!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E2C),
                  ),
                ),
                const SizedBox(height: 20),

                // Featured Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF4F5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 75,
                          height: 75,
                          color: Colors.grey[300],
                          child: Image.asset(
                            'asset/logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image, color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FEATURED FOR YOU',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Discover new perspectives today',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Tabs Filter
                SizedBox(
                  height: 35,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _tabs.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedTab == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedTab = index);
                          if (index == 2) _fetchCategories();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _tabs[index],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.grey[500],
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (isSelected)
                                Container(
                                  width: 30,
                                  height: 2,
                                  color: const Color(0xFF0F4C5C),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                if (_selectedTab == 1) ...[
                  const Text(
                    'Pilih artikel yang ingin kamu edit',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F4C5C),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                if (_selectedTab == 2)
                  _buildCategoriesSection()
                else if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_posts.isEmpty)
                  _buildEmptyState()
                else
                  _buildArticleList(),
              ],
            ),
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[200]!)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) async {
            if (index == 1) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchPage(posts: _posts),
                ),
              );
              return;
            }

            if (index == 3) {
              // Pindah ke CreatePostPage & refresh saat kembali
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreatePostPage()),
              );
              _fetchPosts(); // Auto refresh data postingan terbaru!
              return;
            }

            if (index == 2) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritePage(
                    posts: _posts
                        .where(
                          (post) => _favoritePostIds.contains(_postId(post)),
                        )
                        .toList(),
                    favoritePostIds: _favoritePostIds,
                    onToggleFavorite: _toggleFavorite,
                  ),
                ),
              );
              setState(() {});
              return;
            }

            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF0F4C5C),
          unselectedItemColor: Colors.grey[400],
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 28),
              activeIcon: Icon(Icons.home, size: 28),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search, size: 28),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_border, size: 28),
              activeIcon: Icon(Icons.bookmark, size: 28),
              label: 'Bookmark',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline, size: 28),
              activeIcon: Icon(Icons.add_circle, size: 28),
              label: 'Add',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF8E2DE2).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.article_outlined,
                size: 56,
                color: Color(0xFF8E2DE2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada artikel',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E2C),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Artikel yang kamu tambahkan\nakan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Render list dinamis sesuai data API
  Widget _buildArticleList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        final String title = post['title'] ?? 'Tanpa Judul';
        final String categoryName = _getCategoryName(post);
        final String postId = _postId(post);

        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetailPage(post: post),
                ),
              );
              if (mounted) _fetchPosts();
            },
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
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: _favoritePostIds.contains(postId)
                      ? 'Hapus dari favorite'
                      : 'Tambah ke favorite',
                  icon: Icon(
                    _favoritePostIds.contains(postId)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: _favoritePostIds.contains(postId)
                        ? Colors.red
                        : Colors.grey[500],
                  ),
                  onPressed: () => _toggleFavorite(post),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getCategoryName(Map<String, dynamic> post) {
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

  Future<void> _fetchCategories() async {
    if (_isLoadingCategories) return;
    setState(() => _isLoadingCategories = true);
    try {
      final response = await http.get(Uri.parse('$_baseUrl/categories'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _categories = data is List ? data : (data['data'] ?? []);
          });
        }
      } else {
        _showSnackBar('Gagal mengambil kategori');
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan koneksi: $e');
    } finally {
      if (mounted) setState(() => _isLoadingCategories = false);
    }
  }

  Widget _buildCategoriesSection() {
    if (_isLoadingCategories) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Kelola kategori',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: _showAddCategoryDialog,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_categories.isEmpty)
          Text('Belum ada kategori.', style: TextStyle(color: Colors.grey[600]))
        else
          ..._categories.map((category) => _buildCategoryCard(category)),
      ],
    );
  }

  Widget _buildCategoryCard(dynamic category) {
    final name = (category['name'] ?? 'Tanpa Nama').toString();
    final id = category['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8F8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCE8E9)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF0F4C5C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.sell_outlined, color: Color(0xFF0F4C5C)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            tooltip: 'Edit kategori',
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF0F4C5C)),
            onPressed: () => _showEditCategoryDialog(id, name),
          ),
          IconButton(
            tooltip: 'Hapus kategori',
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _deleteCategory(id),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Kategori'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nama kategori'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(context);
              await _saveCategory(name: name);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(dynamic id, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Kategori'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nama kategori'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(context);
              await _saveCategory(id: id, name: name);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCategory({dynamic id, required String name}) async {
    final isEditing = id != null;
    try {
      final response = isEditing
          ? await http.put(
              Uri.parse('$_baseUrl/categories/$id'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'name': name}),
            )
          : await http.post(
              Uri.parse('$_baseUrl/categories'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'name': name}),
            );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar(
          isEditing ? 'Kategori diperbarui' : 'Kategori ditambahkan',
        );
        _fetchCategories();
      } else {
        _showSnackBar('Gagal menyimpan kategori');
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan koneksi: $e');
    }
  }

  Future<void> _deleteCategory(dynamic id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/categories/$id'));
      if (response.statusCode == 200) {
        _showSnackBar('Kategori dihapus');
        _fetchCategories();
      } else {
        _showSnackBar('Gagal menghapus kategori');
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan koneksi: $e');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _postId(Map<String, dynamic> post) {
    return (post['id'] ?? post['title'] ?? '').toString();
  }

  void _toggleFavorite(Map<String, dynamic> post) {
    final postId = _postId(post);
    setState(() {
      if (!_favoritePostIds.add(postId)) {
        _favoritePostIds.remove(postId);
      }
    });
  }
}
