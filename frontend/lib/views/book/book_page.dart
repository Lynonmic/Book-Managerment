import 'package:flutter/material.dart';

class BookPage extends StatelessWidget {
  const BookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trang chủ"),
        backgroundColor: Colors.purpleAccent,
      ),
      body: const Center(
        child: Text(
          "Chào mừng bạn đến với trang chủ!",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
