import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'lending.dart';
import '../helper/apiservice.dart';

class CreateLendingBook extends StatefulWidget {
  const CreateLendingBook({super.key});
  @override
  State<CreateLendingBook> createState() => _CreateLendingBookState();
}

class _CreateLendingBookState extends State<CreateLendingBook> {
  List<Map<String, dynamic>> books = [];
  List<Map<String, dynamic>> users = [];
  int? _selectedBookId;
  int? _selectedUserId;
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.wait([getBooks(), getUsers()]);
  }

  Future<void> getBooks() async {
    try {
      final response = await ApiService.get('/books');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          books = data
              .map((item) => {'id': item['id'], 'title': item['title']})
              .toList();
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> getUsers() async {
    try {
      final response = await ApiService.get('/users');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          users = data
              .map((item) => {'id': item['id'], 'name': item['name']})
              .toList();
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _pickDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ยืมหนังสือ')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Dropdown เลือกหนังสือ
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'หนังสือ'),
              value: _selectedBookId,
              items: books.map((book) {
                return DropdownMenuItem<int>(
                  value: book['id'],
                  child: Text(book['title']),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedBookId = value),
            ),
            const SizedBox(height: 12),
            // Dropdown เลือกผู้ยืม
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'ผู้ยืม'),
              value: _selectedUserId,
              items: users.map((user) {
                return DropdownMenuItem<int>(
                  value: user['id'],
                  child: Text(user['name']),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedUserId = value),
            ),
            const SizedBox(height: 12),
            // วันที่ยืม
            TextField(
              controller: _startDateController,
              decoration: const InputDecoration(
                labelText: 'วันที่ยืม',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () => _pickDate(context, _startDateController),
            ),
            const SizedBox(height: 12),
            // วันที่คืน
            TextField(
              controller: _endDateController,
              decoration: const InputDecoration(
                labelText: 'วันที่คืน',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () => _pickDate(context, _endDateController),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                // validate
                if (_selectedBookId == null ||
                    _selectedUserId == null ||
                    _startDateController.text.isEmpty ||
                    _endDateController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบ')),
                  );
                  return;
                }

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      const Center(child: CircularProgressIndicator()),
                );

                try {
                  // final res = await http.post(
                  //   Uri.parse('http://localhost:8000/api/lendingbooks'),
                  //   headers: {
                  //     'Content-Type': 'application/json',
                  //     'Accept': 'application/json',
                  //   },
                  //   body: jsonEncode({
                  //     'book_id': _selectedBookId,
                  //     'user_id': _selectedUserId,
                  //     'start_date': _startDateController.text,
                  //     'end_date': _endDateController.text,
                  //   }),
                  // );

                  final res = await ApiService.post('/lendingbooks', {
                    'book_id': _selectedBookId,
                    'user_id': _selectedUserId,
                    'start_date': _startDateController.text,
                    'end_date': _endDateController.text,
                  });

                  if (context.mounted) Navigator.pop(context);

                  if (res.statusCode == 201 || res.statusCode == 200) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ยืมหนังสือสำเร็จ')),
                      );
                      // Navigator.pushReplacement(
                      //   context,
                      //   MaterialPageRoute(builder: (_) => const lending()),
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
                  if (context.mounted) Navigator.pop(context);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('เชื่อมต่อไม่ได้: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('บันทึก'),
            ),
          ],
        ),
      ),
    );
  }
}
