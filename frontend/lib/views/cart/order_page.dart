import 'package:flutter/material.dart';


class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage>{
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trang order"),
        backgroundColor: Colors.purpleAccent,
      ),
      body: const Center(
        child: Text(
          "Chào mừng bạn đến với trang order!",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}