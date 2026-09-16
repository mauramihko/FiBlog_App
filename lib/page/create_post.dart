import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  final String _baseUrl = 'http://localhost:5000/api';

  List<dynamic> _categories = [];
  int? _selectedCategoryId;
  bool _isLoadingCategories = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  // 1. GET ALL CATEGORIES
  Future<void> _fetchCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final response = await http.get(Uri.parse('$_baseUrl/categories'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _categories = data is List ? data : (data['data'] ?? []);
          _isLoadingCategories = false;
        });
      } else {
        _showSnackBar('Gagal mengambil kategori: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan koneksi: $e');
    } finally {
      setState(() => _isLoadingCategories = false);
    }
  }

  // 2. CREATE POST (Kirim JSON biasa tanpa file/gambar)
  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      _showSnackBar('Pilih kategori terlebih dahulu');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/posts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': _titleController.text,
          'content': _contentController.text,
          'categoryId': _selectedCategoryId,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showSnackBar('Post berhasil dibuat!');
        _titleController.clear();
        _contentController.clear();
        setState(() {
          _selectedCategoryId = null;
        });
      } else {
        _showSnackBar('Gagal membuat post: ${response.body}');
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan koneksi: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  // 3. ADD NEW CATEGORY
  Future<void> _addCategory(String name) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/categories'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showSnackBar('Kategori berhasil ditambahkan!');
        _fetchCategories();
      } else {
        _showSnackBar('Gagal menambah kategori');
      }
    } catch (e) {
      _showSnackBar('Kesalahan koneksi: $e');
    }
  }

  // 4. UPDATE CATEGORY
  Future<void> _updateCategory(int id, String newName) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/categories/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': newName}),
      );

      if (response.statusCode == 200) {
        _showSnackBar('Kategori berhasil diperbarui!');
        _fetchCategories();
      }
    } catch (e) {
      _showSnackBar('Kesalahan koneksi: $e');
    }
  }

  // 5. DELETE CATEGORY
  Future<void> _deleteCategory(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/categories/$id'),
      );

      if (response.statusCode == 200) {
        _showSnackBar('Kategori berhasil dihapus!');
        if (_selectedCategoryId == id) {
          setState(() => _selectedCategoryId = null);
        }
        _fetchCategories();
      }
    } catch (e) {
      _showSnackBar('Kesalahan koneksi: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // DIALOG TAMBAH KATEGORI
  void _showAddCategoryDialog() {
    final categoryController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Kategori Baru'),
        content: TextField(
          controller: categoryController,
          decoration: const InputDecoration(hintText: 'Nama Kategori'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (categoryController.text.isNotEmpty) {
                _addCategory(categoryController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // DIALOG KELOLA KATEGORI (EDIT / HAPUS)
  void _showManageCategoriesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kelola Kategori'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              return ListTile(
                title: Text(cat['name']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditCategoryDialog(cat['id'], cat['name']);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteCategory(cat['id']);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(int id, String currentName) {
    final editController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Kategori'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(hintText: 'Nama Kategori Baru'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (editController.text.isNotEmpty) {
                _updateCategory(id, editController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showManageCategoriesDialog,
          ),
          IconButton(
            icon: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            onPressed: _isSubmitting ? null : _submitPost,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // INPUT JUDUL POST
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Post',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Judul wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                // PILIH / ISIKAN KATEGORI
                Row(
                  children: [
                    Expanded(
                      child: _isLoadingCategories
                          ? const LinearProgressIndicator()
                          : DropdownButtonFormField<int>(
                              value: _selectedCategoryId,
                              hint: const Text('Pilih Kategori'),
                              items:
                                  _categories.map<DropdownMenuItem<int>>((cat) {
                                return DropdownMenuItem<int>(
                                  value: cat['id'],
                                  child: Text(cat['name']),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() => _selectedCategoryId = val);
                              },
                            ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline,
                          color: Colors.purple),
                      tooltip: 'Tambah Kategori',
                      onPressed: _showAddCategoryDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // KONTEN POST
                TextFormField(
                  controller: _contentController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Konten Post',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Konten wajib diisi' : null,
                ),
                const SizedBox(height: 24),

                // TOMBOL PUBLISH POST
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: _isSubmitting ? null : _submitPost,
                    child: Text(
                        _isSubmitting ? 'Submitting...' : 'Publish Post'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}