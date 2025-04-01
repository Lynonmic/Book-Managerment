import 'package:flutter/material.dart';

class OrderItem extends StatelessWidget {
  final String maDonHang;
  final String maKhachHang;
  final String ngayDat;
  final String tongTien;
  final String trangThai;
  final VoidCallback? onTap;

  const OrderItem({
    Key? key,
    required this.maDonHang,
    required this.maKhachHang,
    required this.ngayDat,
    required this.tongTien,
    required this.trangThai,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order ID and Customer ID
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Text(
                          'ID: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(maDonHang),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text(
                    'Customer: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  Text(maKhachHang, style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const Divider(height: 16),
              // Order details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Date',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(ngayDat),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tongTien,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(trangThai),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trangThai,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'hoàn thành':
        return Colors.green;
      case 'pending':
      case 'chờ xử lý':
        return Colors.orange;
      case 'cancelled':
      case 'đã hủy':
        return Colors.red;
      case 'processing':
      case 'đang xử lý':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

// Example of how to use the OrderItem widget in a ListView
class OrderListScreen extends StatelessWidget {
  const OrderListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample order data
    final orders = [
      {
        'maDonHang': 'DH001',
        'maKhachHang': 'KH123',
        'ngayDat': '01/04/2025',
        'tongTien': '1,250,000₫',
        'trangThai': 'Hoàn thành',
      },
      {
        'maDonHang': 'DH002',
        'maKhachHang': 'KH456',
        'ngayDat': '31/03/2025',
        'tongTien': '850,000₫',
        'trangThai': 'Chờ xử lý',
      },
      {
        'maDonHang': 'DH003',
        'maKhachHang': 'KH789',
        'ngayDat': '30/03/2025',
        'tongTien': '2,100,000₫',
        'trangThai': 'Đang xử lý',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return OrderItem(
            maDonHang: order['maDonHang']!,
            maKhachHang: order['maKhachHang']!,
            ngayDat: order['ngayDat']!,
            tongTien: order['tongTien']!,
            trangThai: order['trangThai']!,
            onTap: () {
              // Navigate to order details or perform action
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Order ${order['maDonHang']} selected'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
