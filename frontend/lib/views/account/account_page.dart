import 'package:flutter/material.dart';


class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trang account"),
        backgroundColor: Colors.purpleAccent,
      ),
      body: const Center(
        child: Text(
          "Chào mừng bạn đến với trang Account!",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}