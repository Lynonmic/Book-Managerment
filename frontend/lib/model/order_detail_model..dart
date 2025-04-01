class OrderDetail {
  final String id; // ma_chi_tiet
  final String orderId; // ma_don_hang
  final String bookId; // ma_sach
  final int quantity; // so_luong
  final double price; // gia

  OrderDetail({
    required this.id,
    required this.orderId,
    required this.bookId,
    required this.quantity,
    required this.price,
  });

  // Create an OrderDetail from a Map
  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      bookId: json['bookId'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
    );
  }

  // Convert OrderDetail to a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'bookId': bookId,
      'quantity': quantity,
      'price': price,
    };
  }
}
