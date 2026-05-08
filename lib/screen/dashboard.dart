import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'menu.dart';
import '../helper/apiservice.dart';

class dashboard extends StatefulWidget {
  const dashboard({super.key});

  @override
  State<dashboard> createState() => _dashboardState();
}

class _dashboardState extends State<dashboard> {
  int totalBooks = 0;
  int borrowedBooks = 0;
  int totalUsers = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    try {
      final response = await ApiService.get('/books/showinfo');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          totalBooks = data['books_total'];
          borrowedBooks = data['books_lend'];
          totalUsers = data['user_total'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      //print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 4,
                child: ListTile(
                  leading: const Icon(Icons.book, color: Colors.blue, size: 40),
                  title: const Text('จำนวนหนังสือทั้งหมด'),
                  subtitle: Text(
                    '$totalBooks เล่ม',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 4,
                child: ListTile(
                  leading: const Icon(
                    Icons.bookmark,
                    color: Colors.orange,
                    size: 40,
                  ),
                  title: const Text('จำนวนหนังสือที่ถูกยืมอยู่'),
                  subtitle: Text(
                    '$borrowedBooks เล่ม',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 4,
                child: ListTile(
                  leading: const Icon(
                    Icons.people,
                    color: Colors.green,
                    size: 40,
                  ),
                  title: const Text('จำนวนผู้ใช้งานทั้งหมด'),
                  subtitle: Text(
                    '$totalUsers คน',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: Container(
      //   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      //   height: 50,
      //   child: ElevatedButton(
      //     onPressed: () {
      //       Navigator.pushReplacement(
      //         context,
      //         MaterialPageRoute(builder: (context) => const Menu()),
      //       );
      //     },
      //     style: ElevatedButton.styleFrom(
      //       backgroundColor: Colors.blue,
      //       foregroundColor: Colors.white,
      //     ),
      //     child: const Text('ย้อนกลับ'),
      //   ),
      // ),
    );
  }
}
