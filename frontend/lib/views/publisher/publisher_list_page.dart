import 'package:flutter/material.dart';


class PublisherListPage extends StatefulWidget {
  const PublisherListPage({super.key});

  @override
  _PublisherListPageState createState() => _PublisherListPageState();
}

class _PublisherListPageState extends State<PublisherListPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trang PublisherListPage"),
        backgroundColor: Colors.purpleAccent,
      ),
      body: const Center(
        child: Text(
          "Chào mừng bạn đến với trang PublisherListPage!",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}