import 'package:frontend/model/CartModel.dart';
import 'package:frontend/service/api_service.dart';

class CartRepository {
  Future<List<CartModel>> getCart(int userId) async {
    try {
      final data = await ApiService.getUserCart(userId);
      return data;
    } catch (e) {
      throw Exception('Failed to get cart: $e');
    }
  }

  Future<CartModel> addToCart({
    required int userId,
    required int bookId,
    required int quantity,
  }) async {
    try {
      final data = await ApiService.addToCart(
        userId: userId,
        bookId: bookId,
        quantity: quantity,
      );
      return data;
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
  }

  Future<CartModel> updateCartItem({
    required int cartId,
    required int quantity,
  }) async {
    try {
      final data = await ApiService.updateCartItem(
        cartId: cartId,
        quantity: quantity,
      );
      return data;
    } catch (e) {
      throw Exception('Failed to update cart: $e');
    }
  }

  Future<void> removeCartItem(int cartId) async {
    try {
      await ApiService.removeFromCart(cartId);
    } catch (e) {
      throw Exception('Failed to remove cart item: $e');
    }
  }

  Future<void> clearCart(int userId) async {
    try {
      await ApiService.clearCart(userId);
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }
}