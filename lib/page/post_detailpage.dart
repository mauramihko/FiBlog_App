import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PostDetailPage extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final String _baseUrl = 'http://localhost:5000/api';

  late String _title;
  late String _content;
  String _categoryName = 'General';
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _title = widget.post['title'] ?? '';
    _content = widget.post['content'] ?? '';

    if (widget.post['category'] != null && widget.post['category']['name'] != null) {
      _categoryName = widget.post['category']['name'];
    } else if (widget.post['category_name'] != null) {
      _categoryName = widget.post['category_name'];
    }
  }

  // FUNGSI HAPUS POST
  Future<void> _deletePost() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Artikel'),
        content: const Text('Apakah Anda yakin ingin menghapus artikel ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isDeleting = true);

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/posts/${widget.post['id']}'),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Artikel berhasil dihapus!')),
          );
          Navigator.pop(context, true);
        }
      } else {
        _showSnackBar('Gagal menghapus artikel');
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan koneksi: $e');
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  // FUNGSI EDIT POST (DIALOG)
  void _showEditPostDialog() {
    final titleController = TextEditingController(text: _title);
    final contentController = TextEditingController(text: _content);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Artikel'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Artikel',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Isi Artikel',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty || contentController.text.isEmpty) {
                _showSnackBar('Judul dan isi tidak boleh kosong');
                return;
              }

              try {
                final response = await http.put(
                  Uri.parse('$_baseUrl/posts/${widget.post['id']}'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'title': titleController.text,
                    'content': contentController.text,
                  }),
                );

                if (response.statusCode == 200) {
                  setState(() {
                    _title = titleController.text;
                    _content = contentController.text;
                  });
                  if (mounted) {
                    Navigator.pop(context);
                    _showSnackBar('Artikel berhasil diperbarui!');
                  }
                } else {
                  _showSnackBar('Gagal mengedit artikel');
                }
              } catch (e) {
                _showSnackBar('Koneksi error: $e');
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Artikel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            tooltip: 'Edit Artikel',
            onPressed: _showEditPostDialog,
          ),
          IconButton(
            icon: _isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Hapus Artikel',
            onPressed: _isDeleting ? null : _deletePost,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER BARIS: IKON ARTIKEL + BADGE KATEGORI
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.article_outlined,
                    color: Colors.blue.shade600,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.purple.shade200),
                  ),
                  child: Text(
                    _categoryName,
                    style: TextStyle(
                      color: Colors.purple.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // JUDUL ARTIKEL
            Text(
              _title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // ISI KONTEN ARTIKEL
            Text(
              _content.isNotEmpty ? _content : 'Tidak ada isi konten artikel.',
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}