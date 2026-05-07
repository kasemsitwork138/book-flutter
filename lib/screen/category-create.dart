import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'menu.dart';
import 'book.dart';
import 'category.dart';

class categoryCreate extends StatefulWidget {
  const categoryCreate({super.key});

  @override
  State<categoryCreate> createState() => _categoryCreateState();
}

class _categoryCreateState extends State<categoryCreate> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
              Text('สร้างหมวดหมู่', style: TextStyle(fontSize: 28)),
              SizedBox(height: 20),

              // Text field สำหรับชื่อหนังสือ
              TextField(
                decoration: InputDecoration(labelText: 'ชื่อหมวดหมู่'),
                // สามารถเพิ่ม Controller เพื่อเก็บค่าได้
                controller: _nameController,
              ),
              SizedBox(height: 12),

              // Text field สำหรับผู้แต่ง
              // TextField(
              //   decoration: InputDecoration(labelText: 'ผู้แต่ง'),
              //   controller: _authorController,
              // ),
              // SizedBox(height: 12),

              // // Text field สำหรับหมวดหมู่
              // DropdownButtonFormField<int>(
              //   decoration: const InputDecoration(labelText: 'หมวดหมู่'),
              //   value: _selectedCategoryId,
              //   items: category.map((category) {
              //     return DropdownMenuItem<int>(
              //       value: category['id'],
              //       child: Text(category['name']),
              //     );
              //   }).toList(),
              //   onChanged: (value) {
              //     setState(() {
              //       _selectedCategoryId = value;
              //     });
              //   },
              //   validator: (value) =>
              //       value == null ? 'กรุณาเลือกหมวดหมู่' : null,
              // ),
              // SizedBox(height: 12),

              // // Text field สำหรับวันที่พิมพ์
              // TextField(
              //   controller: _publishedDateController,
              //   decoration: InputDecoration(
              //     labelText: 'วันที่พิมพ์',
              //     suffixIcon: Icon(Icons.calendar_today),
              //   ),
              //   readOnly: true, // ป้องกันพิมพ์เอง
              //   onTap: () => _pickDate(context), // กดแล้วเปิด DatePicker
              // ),
              // SizedBox(height: 20),

              // // แสดงรูปที่เลือก หรือปุ่มเลือกรูป
              // GestureDetector(
              //   onTap: _pickImage,
              //   child: Container(
              //     width: double.infinity,
              //     height: 150,
              //     decoration: BoxDecoration(
              //       border: Border.all(color: Colors.grey),
              //       borderRadius: BorderRadius.circular(8),
              //     ),
              //     child: _imageBytes != null
              //         ? ClipRRect(
              //             borderRadius: BorderRadius.circular(8),
              //             child: Image.memory(_imageBytes!, fit: BoxFit.cover),
              //           )
              //         : const Column(
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             children: [
              //               Icon(
              //                 Icons.add_photo_alternate,
              //                 size: 50,
              //                 color: Colors.grey,
              //               ),
              //               Text(
              //                 'กดเพื่อเลือกรูปปก',
              //                 style: TextStyle(color: Colors.grey),
              //               ),
              //             ],
              //           ),
              //   ),
              // ),
              // SizedBox(height: 20),
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
                    var request = http.MultipartRequest(
                      'POST',
                      Uri.parse('http://localhost:8000/api/category'),
                    );

                    request.headers['Accept'] = 'application/json';
                    request.headers['X-Requested-With'] = 'XMLHttpRequest';

                    // ข้อมูลทั่วไป
                    request.fields['name'] = _nameController.text;
                    // request.fields['title'] = _titleController.text;
                    // request.fields['author'] = _authorController.text;
                    // request.fields['category_id'] = _selectedCategoryId
                    //     .toString();
                    // request.fields['published_date'] =
                    //     _publishedDateController.text;

                    // // รูปภาพ
                    // if (_imageBytes != null) {
                    //   request.files.add(
                    //     http.MultipartFile.fromBytes(
                    //       'cover_image',
                    //       _imageBytes!,
                    //       filename: _imageName ?? 'cover.jpg',
                    //     ),
                    //   );
                    // }

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
                          MaterialPageRoute(builder: (_) => const category()),
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
    ;
  }
}
