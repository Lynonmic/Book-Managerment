import 'package:equatable/equatable.dart';
import 'package:frontend/model/order_model.dart';

enum OrderStatus { initial, loading, loaded, error }

class OrderState extends Equatable {
  final List<Order> orders;
  final Order? selectedOrder;
  final List<OrderDetail> orderDetails;
  final OrderStatus status;
  final String? errorMessage;

  const OrderState({
    this.orders = const [],
    this.selectedOrder,
    this.orderDetails = const [],
    this.status = OrderStatus.initial,
    this.errorMessage,
  });

  OrderState copyWith({
    List<Order>? orders,
    Order? selectedOrder,
    List<OrderDetail>? orderDetails,
    OrderStatus? status,
    String? errorMessage,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      orderDetails: orderDetails ?? this.orderDetails,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [orders, selectedOrder, orderDetails, status, errorMessage];
}
