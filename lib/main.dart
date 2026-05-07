import 'package:flutter/material.dart';
import 'screen/menu.dart';
import 'screen/login.dart';

void main() {
  // const app = MaterialApp(
  //   title : 'My title',
  //   home: Scaffold(
  //     appBar: AppBar(
  //       title: Text('My title'),
  //     ),
  //     body: Center(
  //       child: Text('Hello world'),
  //     ),
  //   ),

  // );
  runApp(
    MaterialApp(
      title: 'My title',
      home: const Login(),
    ),
  );
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      child: const Center(child: Text('Hello world')),
    );
  }
}
