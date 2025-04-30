import 'package:frontend/model/order_model.dart';
import 'package:frontend/service/api_service.dart';

class OrderRepository {
  List<Order> _orders = [];
  
  List<Order> get orders => _orders;

  // Get all orders
  Future<List<Order>> getOrders() async {
    try {
      _orders = await ApiService.getAllOrders();
      return _orders;
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  // Refresh orders
  Future<List<Order>> refreshOrders() async {
    return getOrders();
  }

  // Get order by ID
  Future<Order> getOrderById(String id) async {
    try {
      return await ApiService.getOrderById(id);
    } catch (e) {
      throw Exception('Failed to fetch order: $e');
    }
  }

  // Get order with details
  Future<Order> getOrderWithDetails(String id) async {
    try {
      return await ApiService.getOrderWithDetails(id);
    } catch (e) {
      throw Exception('Failed to fetch order with details: $e');
    }
  }

  // Create a new order
  Future<Order> createOrder(Order order) async {
    try {
      final response = await ApiService.createOrder(order);
      if (response['success']) {
        // Refresh orders to get the newly created one
        await getOrders();
        // Find the new order by ID if available
        if (response['orderId'] != null) {
          return await getOrderById(response['orderId']);
        } else {
          // Return the last order as a fallback
          return _orders.last;
        }
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // Update an existing order
  Future<Order> updateOrder(Order order) async {
    try {
      final response = await ApiService.updateOrder(order.id!, order);
      if (response['success']) {
        // Get the updated order from the server
        final updatedOrder = await getOrderById(order.id!);
        // Update the local cache
        final index = _orders.indexWhere((o) => o.id == order.id);
        if (index != -1) {
          _orders[index] = updatedOrder;
        }
        return updatedOrder;
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  // Update order status
  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await ApiService.updateOrderStatus(orderId, status);
      if (response['success']) {
        // Update the local cache
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _orders[index] = _orders[index].copyWith(status: status);
        }
        return true;
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // Delete an order
  Future<bool> deleteOrder(String orderId) async {
    try {
      final response = await ApiService.deleteOrder(orderId);
      if (response['success']) {
        _orders.removeWhere((order) => order.id == orderId);
        return true;
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }

  // Get order details
  Future<List<OrderDetail>> getOrderDetails(String orderId) async {
    try {
      return await ApiService.getOrderDetails(orderId);
    } catch (e) {
      throw Exception('Failed to fetch order details: $e');
    }
  }

  // Add order detail
  Future<bool> addOrderDetail(String orderId, OrderDetail detail) async {
    try {
      final response = await ApiService.addOrderDetail(orderId, detail);
      return response['success'];
    } catch (e) {
      throw Exception('Failed to add order detail: $e');
    }
  }
}
