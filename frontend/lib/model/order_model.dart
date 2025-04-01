// Import the OrderDetail model

class Order {
  final String? id; // ma_don_hang
  final String customerId; // ma_khach_hang
  final DateTime orderDate; // ngay_dat
  final double totalAmount; // tong_tien - not null
  final String status; // trang_thai - default "chờ xử lý"
  final String customerName; // For display purposes
  final List<OrderDetail>? orderDetails; // Added order details list

  Order({
    this.id,
    required this.customerId,
    required this.orderDate,
    required this.totalAmount,
    this.status = "chờ xử lý", // Default value
    required this.customerName,
    this.orderDetails, // Added parameter for order details
  });

  // Create a copy of this Order with modified fields
  Order copyWith({
    String? id,
    String? customerId,
    DateTime? orderDate,
    double? totalAmount,
    String? status,
    String? customerName,
    List<OrderDetail>? orderDetails,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      orderDate: orderDate ?? this.orderDate,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      customerName: customerName ?? this.customerName,
      orderDetails: orderDetails ?? this.orderDetails,
    );
  }

  // Create an Order from a Map
  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderDetail>? details;
    if (json['orderDetails'] != null) {
      details = List<OrderDetail>.from(
        (json['orderDetails'] as List).map(
          (detail) => OrderDetail.fromJson(detail),
        ),
      );
    }

    return Order(
      id: json['id'] as String?,
      customerId: json['customerId'] as String,
      orderDate: DateTime.parse(json['orderDate'] as String),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'] as String? ?? "chờ xử lý",
      customerName: json['customerName'] as String,
      orderDetails: details,
    );
  }

  // Convert Order to a Map
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'customerId': customerId,
      'orderDate': orderDate.toIso8601String(),
      'totalAmount': totalAmount,
      'status': status,
      'customerName': customerName,
    };

    if (orderDetails != null) {
      data['orderDetails'] =
          orderDetails!.map((detail) => detail.toJson()).toList();
    }

    return data;
  }
}

// Define the OrderDetail class inline if needed
class OrderDetail {
  final String id; // ma_chi_tiet
  final String orderId; // ma_don_hang
  final String bookId; // ma_sach
  final int quantity; // so_luong
  final double price; // gia
  final String? bookTitle; // Optional book title for display

  OrderDetail({
    required this.id,
    required this.orderId,
    required this.bookId,
    required this.quantity,
    required this.price,
    this.bookTitle,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'].toString(),
      orderId: json['orderId'].toString(),
      bookId: json['bookId'].toString(),
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      bookTitle: json['bookTitle'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'bookId': bookId,
      'quantity': quantity,
      'price': price,
      'bookTitle': bookTitle,
    };
  }
}
