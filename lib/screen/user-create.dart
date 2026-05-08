import 'package:flutter/material.dart';
import 'package:myproject/screen/user.dart' show user;
import '../helper/apiservice.dart';
import 'package:shared_preferences/shared_preferences.dart';

class userCreate extends StatefulWidget {
  const userCreate({super.key});

  @override
  State<userCreate> createState() => _userCreateState();
}

class _userCreateState extends State<userCreate> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _password_confirmationController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _password_confirmationController.dispose();
    super.dispose();
  }

  Future<void> createUser() async {
    try {
      final res = await ApiService.post('/users', {
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'password_confirmation': _password_confirmationController.text,
      });
      print(res.body);
      if (res.statusCode == 201) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('สร้างผู้ใช้สำเร็จ')));
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (_) => const user()),
          // );
          Navigator.pop(context);
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เกิดข้อผิดพลาด: ${res.body}')),
          );
        }
      }
    } catch (e) {
      print(e);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('ไม่สามารถเชื่อมต่อได้: $e')));
      }
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
              Text('สร้างผู้ใช้', style: TextStyle(fontSize: 28)),
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
                decoration: InputDecoration(labelText: 'อีเมล'),
                controller: _emailController,
              ),
              SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: 'รหัสผ่าน',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                controller: _passwordController,
                obscureText: _obscurePassword, // ซ่อน/แสดง
              ),
              SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: 'ยืนยันรหัสผ่าน',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _obscureConfirm = !_obscureConfirm);
                    },
                  ),
                ),
                controller: _password_confirmationController,
                obscureText: _obscureConfirm,
              ),
              SizedBox(height: 24),

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

              // แสดงรูปที่เลือก หรือปุ่มเลือกรูป
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
                onPressed: () {
                  createUser();
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
