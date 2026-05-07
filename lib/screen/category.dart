import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'category-edit.dart';
import 'category-create.dart';

class category extends StatefulWidget {
  const category({super.key});

  @override
  State<category> createState() => _categoryState();
}

class _categoryState extends State<category> {
  List<Map<String, dynamic>> category = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategoryApi();
  }

  Future<void> fetchCategoryApi() async {
    try {
      final res = await http.get(
        Uri.parse('http://localhost:8000/api/category'),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        setState(() {
          category = data
              .map((items) => {'id': items['id'], 'name': items['name']})
              .toList();
        });
      }
      isLoading = false;
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteCategoryApi(BuildContext context, int category_id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('คุณต้องการลบหมวดหมู่นี้หรือไม่?'),
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
        Uri.parse('http://localhost:8000/api/category/$category_id'),
      );
      if (res.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('ลบหมวดหมู่สำเร็จ')));
        }
        fetchCategoryApi();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('ลบหมวดหมู่ไม่สำเร็จ')));
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
                    'รายการหมวดหมู่',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 25, bottom: 65),
                    itemCount: category.length,
                    itemBuilder: (context, index) {
                      final items = category[index];
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
                                  // Image.network(
                                  //   book['cover_image'],
                                  //   width: 60,
                                  //   height: 90,
                                  //   fit: BoxFit.cover,
                                  //   errorBuilder:
                                  //       (context, error, stackTrace) =>
                                  //           const Icon(Icons.book, size: 60),
                                  // ),
                                  // const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          items['name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        // Text('ผู้แต่ง: ${book['author']}'),
                                        // Text('หมวดหมู่: ${book['category']}'),
                                        // Text(
                                        //   'วันที่พิมพ์: ${book['published_date']}',
                                        // ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // แถวล่าง: ปุ่ม
                              Align(
                                alignment: Alignment.centerRight,
                                child: Wrap(
                                  spacing: 8,
                                  children: [
                                    // ElevatedButton(
                                    //   onPressed: () {
                                    //     Navigator.push(
                                    //       context,
                                    //       MaterialPageRoute(
                                    //         builder: (_) =>
                                    //             BookDetail(book: book),
                                    //       ),
                                    //     );
                                    //   },
                                    //   child: const Text('ดูรายละเอียด'),
                                    // ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => categoryEdit(),
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
                                      onPressed: () => deleteCategoryApi(
                                        context,
                                        items['id'],
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('ลบ'),
                                    ),
                                  ],
                                ),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const categoryCreate(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(150, 50),
              ),
              child: const Text('สร้างหมวดหมู่'),
            ),
          ],
        ),
      ),
    );
  }
}
