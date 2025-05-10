// cart_event.dart
abstract class CartEvent {}

class LoadCart extends CartEvent {
  final int userId;
  LoadCart(this.userId);
}

class AddToCart extends CartEvent {
  final int userId;
  final String bookId;
  final int quantity;

  AddToCart({
    required this.userId,
    required this.bookId,
    required this.quantity,
  });
}

class RemoveFromCart extends CartEvent {
  final int cartId;
  RemoveFromCart(this.cartId);
}

class ClearCart extends CartEvent {
  final int userId;
  ClearCart(this.userId);
}

class UpdateCartItemQuantity extends CartEvent {
  final int cartId;
  final int quantity;
  UpdateCartItemQuantity(this.cartId, this.quantity);
}