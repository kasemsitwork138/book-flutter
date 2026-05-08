import 'package:flutter/material.dart';
import '../helper/apiservice.dart';

class userEdit extends StatefulWidget {
  final Map<String, dynamic> user;
  const userEdit({super.key, required this.user});

  @override
  State<userEdit> createState() => _userEditState();
}

class _userEditState extends State<userEdit> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user['name'] ?? '';
    _passwordController.text = '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> editUser() async {
    try {
      // สร้าง body เฉพาะที่จำเป็น
      final Map<String, String> body = {'name': _nameController.text};

      // เพิ่ม password เฉพาะเมื่อกรอก
      if (_passwordController.text.isNotEmpty) {
        body['password'] = _passwordController.text;
        body['password_confirmation'] = _passwordController.text;
      }

      final res = await ApiService.put('/users/${widget.user['id']}', body);

      if (res.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('แก้ไขผู้ใช้งานสำเร็จ')));
          Navigator.pop(context);
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('แก้ไขผู้ใช้งานไม่สำเร็จ: ${res.body}')),
          );
        }
      }
    } catch (e) {
      print(e);
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
              Text('แก้ไขผู้ใช้งาน', style: TextStyle(fontSize: 28)),
              SizedBox(height: 20),

              // Text field สำหรับชื่อหนังสือ
              TextField(
                decoration: InputDecoration(labelText: 'ชื่อ'),
                // สามารถเพิ่ม Controller เพื่อเก็บค่าได้
                controller: _nameController,
              ),
              SizedBox(height: 12),

              // Text field สำหรับผู้แต่ง
              TextField(
                decoration: InputDecoration(labelText: 'รหัสผ่าน'),
                controller: _passwordController,
              ),
              SizedBox(height: 12),

              // Text field สำหรับหมวดหมู่
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

              // Text field สำหรับวันที่พิมพ์
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
                onPressed: () => {editUser()},
                child: const Text('บันทึก'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
