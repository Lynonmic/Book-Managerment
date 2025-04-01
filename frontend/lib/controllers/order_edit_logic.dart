// order_detail_form.dart
import 'package:flutter/material.dart';
import 'package:frontend/model/book_model.dart';
import 'package:frontend/model/order_detail_model..dart' as orderDetailModel;
import 'package:frontend/model/order_model.dart';
import 'package:frontend/views/order/admin_order_edit_page.dart'; // Added import for Order

class OrderDetailForm extends StatefulWidget {
  final Function(orderDetailModel.OrderDetail) onSave;
  final List<Book> availableBooks;
  final Order order; // Added Order parameter to access customerId

  const OrderDetailForm({
    Key? key,
    required this.onSave,
    required this.availableBooks,
    required this.order, // Added required parameter
  }) : super(key: key);

  @override
  _OrderDetailFormState createState() => _OrderDetailFormState();
}

class _OrderDetailFormState extends State<OrderDetailForm> {
  // Controllers matching the exact attribute names
  final TextEditingController _maOrderController = TextEditingController();
  final TextEditingController _maSachController = TextEditingController();
  final TextEditingController _soLuongController = TextEditingController(
    text: '1',
  );
  final TextEditingController _giaController = TextEditingController();

  Book? _selectedBook;

  @override
  void initState() {
    super.initState();
    // Use the order ID from the parent order
    _maOrderController.text = widget.order.id!;
  }

  void _handleBookSelection(Book? book) {
    setState(() {
      _selectedBook = book;
    });
  }

  void _saveOrderDetail() {
    if (_selectedBook == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn sách')));
      return;
    }

    final orderDetail = orderDetailModel.OrderDetail(
      id:
          DateTime.now().millisecondsSinceEpoch
              .toString(), // Generate unique detail ID
      orderId: widget.order.id!, // Use the orderId from the parent Order
      bookId: _selectedBook!.id.toString(), // Use selected book's ID
      quantity: int.tryParse(_soLuongController.text) ?? 0,
      price: double.tryParse(_giaController.text) ?? 0,
    );

    widget.onSave(orderDetail);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _maOrderController.dispose();
    _maSachController.dispose();
    _soLuongController.dispose();
    _giaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
