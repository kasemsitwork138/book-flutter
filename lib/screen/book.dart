import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'menu.dart';
import 'book-detail.dart';
import 'book-create.dart';
import 'book-edit.dart';

class book extends StatefulWidget {
  const book({super.key});

  @override
  State<book> createState() => _bookState();
}

class _bookState extends State<book> {
  List<Map<String, dynamic>> books = [];
  bool isLoading = true;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchBookApi();
  }

  Future<void> fetchBookApi() async {
    try {
      final res = await http.get(Uri.parse('http://localhost:8000/api/books'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List; // รับเป็น List
        setState(() {
          books = data
              .map(
                (item) => {
                  'id': item['id'],
                  'cover_image': item['cover_image'],
                  'title': item['title'],
                  'published_date': item['published_date'],
                  'author': item['author'],
                  'category': item['category']['name'],
                  'category_id': item['category']['id'],
                },
              )
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      //print(e);
      setState(() => isLoading = false);
    }
  }

  Future<void> searchBooks({String? search, int? categoryId}) async {
    final uri = Uri.http('localhost:8000', '/api/books/search', {
      if (search != null && search.isNotEmpty) 'search': search,
      if (categoryId != null) 'category': categoryId.toString(),
    });

    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      setState(() {
        books = data
            .map(
              (item) => {
                'id': item['id'],
                'cover_image': item['cover_image'],
                'title': item['title'],
                'published_date': item['published_date'],
                'author': item['author'],
                'category': item['category']['name'],
                'category_id': item['category']['id'],
              },
            )
            .toList();
      });
    }
  }

  Future<void> deleteBookApi(BuildContext context, int BookId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('คุณต้องการลบหนังสือนี้หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ยืนยัน'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final res = await http.delete(
        Uri.parse('http://localhost:8000/api/books/$BookId'),
      );
      if (res.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('ลบหนังสือสำเร็จ')));
        }
        fetchBookApi();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('ลบหนังสือไม่สำเร็จ')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 20, left: 16, right: 16),
                  child: Text(
                    'รายการหนังสือ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'ค้นหาหนังสือ',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          fetchBookApi(); // โหลดทั้งหมดใหม่
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (value.isEmpty) {
                        fetchBookApi(); // ถ้าลบข้อความออกโหลดทั้งหมด
                      } else {
                        searchBooks(search: value); // ค้นหาตาม keyword
                      }
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 25, bottom: 65),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // แถวบน: รูป + ข้อมูล
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.network(
                                    book['cover_image'],
                                    width: 60,
                                    height: 90,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.book, size: 60),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          book['title'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text('ผู้แต่ง: ${book['author']}'),
                                        Text('หมวดหมู่: ${book['category']}'),
                                        Text(
                                          'วันที่พิมพ์: ${book['published_date']}',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // แถวล่าง: ปุ่ม
                              Wrap(
                                spacing: 8,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              BookDetail(book: book),
                                        ),
                                      );
                                    },
                                    child: const Text('ดูรายละเอียด'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => bookEdit(book: book),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('แก้ไข'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        deleteBookApi(context, book['id']),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('ลบ'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.pushReplacement(
            //       context,
            //       MaterialPageRoute(builder: (context) => const Menu()),
            //     );
            //   },
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.blue,
            //     foregroundColor: Colors.white,
            //     minimumSize: const Size(150, 50),
            //   ),
            //   child: const Text('ย้อนกลับ'),
            // ),
            // SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const bookCreate()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(150, 50),
              ),
              child: const Text('สร้างหนังสือ'),
            ),
          ],
        ),
      ),
    );
  }
}
