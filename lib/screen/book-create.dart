import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:myproject/screen/book.dart';
import 'package:myproject/screen/menu.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helper/apiservice.dart';

class bookCreate extends StatefulWidget {
  const bookCreate({super.key});

  @override
  State<bookCreate> createState() => _bookCreateState();
}

class _bookCreateState extends State<bookCreate> {
  List<Map<String, dynamic>> category = [];
  int? _selectedCategoryId;
  DateTime? _selectedDate;
  Uint8List? _imageBytes;
  String? _imageName;

  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _publishedDateController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _publishedDateController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final res = await ApiService.get('/category');
      print('status: ${res.statusCode}');
      print('body: ${res.body}');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        print(data);
        setState(() {
          category = data
              .map((item) => {'id': item['id'], 'name': item['name']})
              .toList();
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> createBook() async {
    try {
      final res = await ApiService.post('/books', {
        'title': _titleController.text,
        'author': _authorController.text,
        'published_date': _publishedDateController.text,
        'category_id': _selectedCategoryId.toString(),
      });

      if (res.statusCode == 201) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('สร้างหนังสือสำเร็จ')));
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => const book()),
          // );
          Navigator.pop(context);
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('สร้างหนังสือไม่สำเร็จ')));
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = image.name;
      });
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _publishedDateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(34.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('สร้างหนังสือ', style: TextStyle(fontSize: 28)),
              SizedBox(height: 20),

              // Text field สำหรับชื่อหนังสือ
              TextField(
                decoration: InputDecoration(labelText: 'ชื่อหนังสือ'),
                // สามารถเพิ่ม Controller เพื่อเก็บค่าได้
                controller: _titleController,
              ),
              SizedBox(height: 12),

              // Text field สำหรับผู้แต่ง
              TextField(
                decoration: InputDecoration(labelText: 'ผู้แต่ง'),
                controller: _authorController,
              ),
              SizedBox(height: 12),

              // Text field สำหรับหมวดหมู่
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'หมวดหมู่'),
                value: _selectedCategoryId,
                items: category.map((category) {
                  return DropdownMenuItem<int>(
                    value: category['id'],
                    child: Text(category['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'กรุณาเลือกหมวดหมู่' : null,
              ),
              SizedBox(height: 12),

              // Text field สำหรับวันที่พิมพ์
              TextField(
                controller: _publishedDateController,
                decoration: InputDecoration(
                  labelText: 'วันที่พิมพ์',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true, // ป้องกันพิมพ์เอง
                onTap: () => _pickDate(context), // กดแล้วเปิด DatePicker
              ),
              SizedBox(height: 20),

              // แสดงรูปที่เลือก หรือปุ่มเลือกรูป
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _imageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 50,
                              color: Colors.grey,
                            ),
                            Text(
                              'กดเพื่อเลือกรูปปก',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  // แสดง Loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    final prefs = await SharedPreferences.getInstance();
                    final token = prefs.getString('token');
                    var request = http.MultipartRequest(
                      'POST',
                      Uri.parse('http://localhost:8000/api/books'),
                    );

                    request.headers['Accept'] = 'application/json';
                    request.headers['X-Requested-With'] = 'XMLHttpRequest';
                    request.headers['Authorization'] = 'Bearer $token';

                    // ข้อมูลทั่วไป
                    request.fields['title'] = _titleController.text;
                    request.fields['author'] = _authorController.text;
                    request.fields['category_id'] = _selectedCategoryId
                        .toString();
                    request.fields['published_date'] =
                        _publishedDateController.text;

                    // รูปภาพ
                    if (_imageBytes != null) {
                      request.files.add(
                        http.MultipartFile.fromBytes(
                          'cover_image',
                          _imageBytes!,
                          filename: _imageName ?? 'cover.jpg',
                        ),
                      );
                    }

                    final streamedResponse = await request.send();
                    final response = await http.Response.fromStream(
                      streamedResponse,
                    );

                    if (context.mounted) Navigator.pop(context); // ปิด Loading

                    if (response.statusCode == 201) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('บันทึกสำเร็จ')),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const book()),
                        );
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('เกิดข้อผิดพลาด: ${response.body}'),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    print(e);
                    if (context.mounted) Navigator.pop(context);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('ไม่สามารถเชื่อมต่อได้: $e')),
                      );
                    }
                  }
                },
                child: const Text('บันทึก'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
