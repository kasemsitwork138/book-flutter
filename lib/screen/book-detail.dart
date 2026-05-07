import 'package:flutter/material.dart';

class BookDetail extends StatelessWidget {
  final Map<String, dynamic> book; // รับข้อมูลหนังสือมาจากหน้า book
  const BookDetail({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(book['title'])),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                book['cover_image'],
                height: 200,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.book, size: 100),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ชื่อ: ${book['title']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('ผู้แต่ง: ${book['author']}'),
            Text('หมวดหมู่: ${book['category']}'),
            Text('วันที่พิมพ์: ${book['published_date']}'),
          ],
        ),
      ),
    );
  }
}
