import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'menu.dart';
import 'book.dart';
import 'category.dart';
import 'lending-create.dart';
import '../helper/apiservice.dart';

class lending extends StatefulWidget {
  const lending({super.key});

  @override
  State<lending> createState() => _lendingState();
}

class _lendingState extends State<lending> {
  List<Map<String, dynamic>> lendingBooks = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLedingBookApi();
  }

  Future<void> fetchLedingBookApi() async {
    try {
      final res = await ApiService.get('/lendingbooks');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        setState(() {
          lendingBooks = data
              .map(
                (items) => {
                  'id': items['id'],
                  'user_id': items['user_id'], // เพิ่ม
                  'book_id': items['book_id'], // เพิ่ม
                  'start_date': items['start_date'],
                  'end_date': items['end_date'],
                  'status': items['status'],
                  'title': items['book']['title'],
                  'user_name': items['user']['name'],
                },
              )
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteLendingBookApi(
    BuildContext context,
    int lending_id,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('คุณต้องการลบการยืมนี้หรือไม่?'),
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
      final res = await ApiService.delete('/lendingbooks/$lending_id');
      if (res.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('ลบการยืมสำเร็จ')));
        }
        fetchLedingBookApi();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('ลบการยืมไม่สำเร็จ')));
      }
    }
  }

  Future<void> changeToReturned(
    BuildContext context,
    Map<String, dynamic> items,
  ) async {
    final lending_id = items['id'];
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการคืน'),
        content: const Text('คุณต้องการคืนหนังสือเล่มนี้หรือไม่?'),
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
      final res = await ApiService.put('/lendingbooks/$lending_id', {
        'user_id': items['user_id'],
        'book_id': items['book_id'],
        'start_date': items['start_date'],
        'end_date': items['end_date'],
        'status': 'returned',
      });
      if (res.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('คืนหนังสือสำเร็จ')));
        }
        fetchLedingBookApi();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('คืนหนังสือไม่สำเร็จ')));
      }
    }
  }
  // Future<void> fetchCategoryApi() async {
  //   try {
  //     final res = await http.get(
  //       Uri.parse('http://localhost:8000/api/category'),
  //     );
  //     if (res.statusCode == 200) {
  //       final data = jsonDecode(res.body) as List;
  //       setState(() {
  //         category = data
  //             .map((items) => {'id': items['id'], 'name': items['name']})
  //             .toList();
  //       });
  //     }
  //     isLoading = false;
  //   } catch (e) {
  //     print(e);
  //   }
  // }

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
                    'รายการยืมหนังสือ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 25, bottom: 65),
                    itemCount: lendingBooks.length,
                    itemBuilder: (context, index) {
                      final items = lendingBooks[index];
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
                                          'ชื่อหนังสือ: ${items['title']}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'ชื่อผู้ยืม: ${items['user_name']}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'วันที่ยืม: ${items['start_date']}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'วันที่คืน: ${items['end_date']}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'สถานะ: ${items['status']}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        // Text(
                                        //   'จำนวน: ${items['total_books']}',
                                        //   style: const TextStyle(
                                        //     fontWeight: FontWeight.bold,
                                        //   ),
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
                                      onPressed: () => changeToReturned(
                                        context,
                                        items,
                                      ), // เรียกตรงๆ
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('คืนหนังสือ'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => deleteLendingBookApi(
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
                  MaterialPageRoute(builder: (context) => CreateLendingBook()),
                ).then((_) => fetchLedingBookApi());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(150, 50),
              ),
              child: const Text('ยืมหนังสือ'),
            ),
          ],
        ),
      ),
    );
  }
}
