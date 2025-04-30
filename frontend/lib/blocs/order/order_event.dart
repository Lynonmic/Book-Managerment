import 'package:equatable/equatable.dart';
import 'package:frontend/model/order_model.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class FetchOrders extends OrderEvent {}

class RefreshOrders extends OrderEvent {}

class FetchOrderById extends OrderEvent {
  final String orderId;

  const FetchOrderById(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class FetchOrderWithDetails extends OrderEvent {
  final String orderId;

  const FetchOrderWithDetails(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class CreateOrder extends OrderEvent {
  final Order order;

  const CreateOrder(this.order);

  @override
  List<Object?> get props => [order];
}

class UpdateOrder extends OrderEvent {
  final Order order;

  const UpdateOrder(this.order);

  @override
  List<Object?> get props => [order];
}

class UpdateOrderStatus extends OrderEvent {
  final String orderId;
  final String status;

  const UpdateOrderStatus(this.orderId, this.status);

  @override
  List<Object?> get props => [orderId, status];
}

class DeleteOrder extends OrderEvent {
  final String orderId;

  const DeleteOrder(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class FetchOrderDetails extends OrderEvent {
  final String orderId;

  const FetchOrderDetails(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class AddOrderDetail extends OrderEvent {
  final String orderId;
  final OrderDetail detail;

  const AddOrderDetail(this.orderId, this.detail);

  @override
  List<Object?> get props => [orderId, detail];
}
