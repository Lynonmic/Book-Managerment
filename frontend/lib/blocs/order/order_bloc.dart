import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/order/order_event.dart';
import 'package:frontend/blocs/order/order_state.dart';
import 'package:frontend/model/order_model.dart';
import 'package:frontend/repositories/order_repository.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository _orderRepository;

  OrderBloc({required OrderRepository orderRepository})
      : _orderRepository = orderRepository,
        super(const OrderState()) {
    on<FetchOrders>(_onFetchOrders);
    on<RefreshOrders>(_onRefreshOrders);
    on<FetchOrderById>(_onFetchOrderById);
    on<FetchOrderWithDetails>(_onFetchOrderWithDetails);
    on<CreateOrder>(_onCreateOrder);
    on<UpdateOrder>(_onUpdateOrder);
    on<UpdateOrderStatus>(_onUpdateOrderStatus);
    on<DeleteOrder>(_onDeleteOrder);
    on<FetchOrderDetails>(_onFetchOrderDetails);
    on<AddOrderDetail>(_onAddOrderDetail);
  }

  Future<void> _onFetchOrders(FetchOrders event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderStatus.loading));
    try {
      final orders = await _orderRepository.getOrders();
      emit(state.copyWith(orders: orders, status: OrderStatus.loaded));
    } catch (e) {
      emit(state.copyWith(
        status: OrderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshOrders(RefreshOrders event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderStatus.loading));
    try {
      final orders = await _orderRepository.refreshOrders();
      emit(state.copyWith(orders: orders, status: OrderStatus.loaded));
    } catch (e) {
      emit(state.copyWith(
        status: OrderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onFetchOrderById(FetchOrderById event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderStatus.loading));
    try {
      final order = await _orderRepository.getOrderById(event.orderId);
      emit(state.copyWith(selectedOrder: order, status: OrderStatus.loaded));
    } catch (e) {
      emit(state.copyWith(
        status: OrderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onFetchOrderWithDetails(
      FetchOrderWithDetails event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderStatus.loading));
    try {
      final order = await _orderRepository.getOrderWithDetails(event.orderId);
      emit(state.copyWith(selectedOrder: order, status: OrderStatus.loaded));
    } catch (e) {
      emit(state.copyWith(
        status: OrderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCreateOrder(CreateOrder event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderStatus.loading));
    try {
      final newOrder = await _orderRepository.createOrder(event.order);
      final updatedOrders = List<Order>.from(state.orders)..add(newOrder);
      emit(state.copyWith(
        orders: updatedOrders,
        status: OrderStatus.loaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OrderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateOrder(UpdateOrder event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderStatus.loading));
    try {
      final updatedOrder = await _orderRepository.updateOrder(event.order);
      final updatedOrders = state.orders.map((order) {
        return order.id == updatedOrder.id ? updatedOrder : order;
      }).toList();
      emit(state.copyWith(
        orders: updatedOrders,
        selectedOrder: updatedOrder,
        status: OrderStatus.loaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OrderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateOrderStatus(
      UpdateOrderStatus event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderStatus.loading));
    try {
      final success = await _orderRepository.updateOrderStatus(
          event.orderId, event.status);
      if (success) {
        // Refresh the order list to get updated status
        await _onRefreshOrders(RefreshOrders(), emit);
      } else {
        emit(state.copyWith(
          status: OrderStatus.error,
          errorMessage: 'Failed to update order status',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: OrderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteOrder(DeleteOrder event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderStatus.loading));
    try {
      final success = await _orderRepository.deleteOrder(event.orderId);
      if (success) {
        final updatedOrders = state.orders.where((order) => order.id != event.orderId).toList();
        emit(state.copyWith(
          orders: updatedOrders,
          status: OrderStatus.loaded,
        ));
      } else {
        emit(state.copyWith(
          status: OrderStatus.error,
          errorMessage: 'Failed to delete order',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: OrderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onFetchOrderDetails(
      FetchOrderDetails event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderStatus.loading));
    try {
      final details = await _orderRepository.getOrderDetails(event.orderId);
      emit(state.copyWith(
        orderDetails: details,
        status: OrderStatus.loaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OrderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAddOrderDetail(
      AddOrderDetail event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderStatus.loading));
    try {
      final success = await _orderRepository.addOrderDetail(
          event.orderId, event.detail);
      if (success) {
        // Refresh the order details
        await _onFetchOrderDetails(FetchOrderDetails(event.orderId), emit);
      } else {
        emit(state.copyWith(
          status: OrderStatus.error,
          errorMessage: 'Failed to add order detail',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: OrderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
