import 'package:frontend/model/UserModels.dart';
import 'package:frontend/model/book_model.dart';

class CartModel {
  final int id;
  final int user_id; // Thay đổi từ UserModels sang int
  final Book book;
  final int quantity;
  final DateTime dateAdded;

  CartModel({
    required this.id,
    required this.user_id, // Thay đổi từ user sang user_id
    required this.book,
    required this.quantity,
    required this.dateAdded,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'] ?? 0,
      user_id:
          json['user_id'] is String
              ? int.parse(json['user_id'])
              : json['user_id'] ?? 0,
      book: Book.fromJson({
        'id': json['book_id'],
        'title': json['book_title'],
        'author': json['book_author'],
        'price': json['book_price'],
        'image_url': json['image_url'],
        'description': json['book_description'],
      }),
      quantity:
          json['quantity'] is String
              ? int.parse(json['quantity'])
              : json['quantity'] ?? 0,
      dateAdded:
          json['date_added'] != null
              ? DateTime.parse(json['date_added'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': user_id,
      'book_id': book.id,
      'quantity': quantity,
      'date_added': dateAdded.toIso8601String(),
    };
  }

  // Tạo bản sao với các thay đổi
  CartModel copyWith({
    int? id,
    int? user_id, // Thay đổi từ UserModels? user
    Book? book,
    int? quantity,
    DateTime? dateAdded,
  }) {
    return CartModel(
      id: id ?? this.id,
      user_id: user_id ?? this.user_id, // Thay đổi từ user
      book: book ?? this.book,
      quantity: quantity ?? this.quantity,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }

  // Tính tổng tiền cho một item trong giỏ hàng
  double get totalPrice => (book.price ?? 0) * quantity;

  @override
  String toString() {
    return 'CartModel(id: $id, user_id: $user_id, book: $book, quantity: $quantity, dateAdded: $dateAdded)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartModel &&
        other.id == id &&
        other.user_id == user_id &&
        other.book == book &&
        other.quantity == quantity &&
        other.dateAdded == dateAdded;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        user_id.hashCode ^
        book.hashCode ^
        quantity.hashCode ^
        dateAdded.hashCode;
  }
}

// Extension để tính tổng tiền cho nhiều items
extension CartListExtension on List<CartModel> {
  double get totalPrice => fold(0, (sum, item) => sum + item.totalPrice);

  int get totalItems => fold(0, (sum, item) => sum + item.quantity);
}
