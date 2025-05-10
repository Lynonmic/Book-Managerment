// cart_bloc.dart
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/model/CartModel.dart';
import 'package:frontend/repositories/CartRepository.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository repository;

  CartBloc(this.repository) : super(CartInitial()) {
    on<LoadCart>((event, emit) async {
      emit(CartLoading());
      try {
        final cart = await repository.getCart(event.userId);
        emit(CartLoaded(cart));
      } catch (e) {
        emit(CartError("Không thể tải giỏ hàng: ${e.toString()}"));
      }
    });

    on<AddToCart>((event, emit) async {
      emit(CartLoading());
      try {
        final addedItem = await repository.addToCart(
          userId: event.userId,
          bookId: int.parse(event.bookId),
          quantity: event.quantity,
        );

        if (state is CartLoaded) {
          final currentCart = (state as CartLoaded).cartItems;
          final existingItemIndex = currentCart.indexWhere(
            (item) => item.book.id == int.parse(event.bookId),
          );

          if (existingItemIndex != -1) {
            final updatedCart = List<CartModel>.from(currentCart);
            updatedCart[existingItemIndex] = addedItem;
            emit(CartLoaded(updatedCart));
          } else {
            final updatedCart = List<CartModel>.from(currentCart)
              ..add(addedItem);
            emit(CartLoaded(updatedCart));
          }
        } else {
          emit(CartLoaded([addedItem]));
        }
      } catch (e) {
        emit(CartError("Không thể thêm vào giỏ hàng: ${e.toString()}"));
      }
    });

    on<UpdateCartItemQuantity>((event, emit) async {
      if (state is CartLoaded) {
        final currentState = state as CartLoaded;
        final currentCart = currentState.cartItems;
        final itemIndex = currentCart.indexWhere(
          (item) => item.id == event.cartId,
        );

        if (itemIndex != -1) {
          final item = currentCart[itemIndex];
          final newQuantity = item.quantity + event.quantity;

          if (newQuantity > 0) {
            try {
              final updatedCart = List<CartModel>.from(currentCart);
              updatedCart[itemIndex] = item.copyWith(quantity: newQuantity);
              emit(CartLoaded(updatedCart));

              final response = await repository.updateCartItem(
                cartId: event.cartId,
                quantity: newQuantity,
              );

              updatedCart[itemIndex] = response;
              emit(CartLoaded(updatedCart));
            } catch (e) {
              print('Error updating cart: $e');
              final updatedCart = List<CartModel>.from(currentCart);
              updatedCart[itemIndex] = item;
              emit(CartLoaded(updatedCart));
              emit(CartError("Không thể cập nhật số lượng: ${e.toString()}"));
            }
          } else {
            add(RemoveFromCart(event.cartId));
          }
        }
      }
    });

    on<RemoveFromCart>((event, emit) async {
      if (state is CartLoaded) {
        final currentState = state as CartLoaded;
        try {
          await repository.removeCartItem(event.cartId);
          final updatedCart =
              currentState.cartItems
                  .where((item) => item.id != event.cartId)
                  .toList();
          emit(CartLoaded(updatedCart));
        } catch (e) {
          emit(CartError("Không thể xóa sản phẩm: ${e.toString()}"));
        }
      }
    });

    on<ClearCart>((event, emit) async {
      emit(CartLoading());
      try {
        await repository.clearCart(event.userId);
        emit(CartLoaded([]));
      } catch (e) {
        emit(CartError("Không thể xóa giỏ hàng: ${e.toString()}"));
      }
    });
  }
}
