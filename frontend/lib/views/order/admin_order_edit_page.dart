// order_detail_ui.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/model/book_model.dart';

class OrderDetailUI extends StatelessWidget {
  final TextEditingController maOrderController;
  final TextEditingController maKhachHangController;
  final TextEditingController maSachController;
  final TextEditingController soLuongController;
  final TextEditingController giaController;

  final List<Book> danhSachSach;
  final Function(Book?) onBookSelected;
  final VoidCallback onSave;

  const OrderDetailUI({
    Key? key,
    required this.maOrderController,
    required this.maKhachHangController,
    required this.maSachController,
    required this.soLuongController,
    required this.giaController,
    required this.danhSachSach,
    required this.onBookSelected,
    required this.onSave,
    required String orderId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi Tiết Đơn Hàng'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mã Đơn Hàng (Order ID)
            TextField(
              controller: maOrderController,
              decoration: const InputDecoration(
                labelText: 'Mã Đơn Hàng',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 16),

            // Mã Khách Hàng (Customer ID)
            TextField(
              controller: maKhachHangController,
              decoration: const InputDecoration(
                labelText: 'Mã Khách Hàng',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Mã Sách (Book Selection)
            DropdownButtonFormField<Book>(
              decoration: const InputDecoration(
                labelText: 'Chọn Sách',
                border: OutlineInputBorder(),
              ),
              items: danhSachSach.map((book) {
                return DropdownMenuItem<Book>(
                  value: book,
                  child: Text(book.title ?? 'Không có tên'),
                );
              }).toList(),
              onChanged: (selectedBook) {
                if (selectedBook != null) {
                  // Set Mã Sách
                  maSachController.text = selectedBook.id.toString();

                  // Automatically set price
                  giaController.text = selectedBook.price?.toString() ?? '';
                }
                onBookSelected(selectedBook);
              },
            ),
            const SizedBox(height: 16),

            // Số Lượng (Quantity)
            TextField(
              controller: soLuongController,
              decoration: const InputDecoration(
                labelText: 'Số Lượng',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),

            // Giá (Price)
            TextField(
              controller: giaController,
              decoration: const InputDecoration(
                labelText: 'Giá',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Nút Lưu (Save Button)
            ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }
}
