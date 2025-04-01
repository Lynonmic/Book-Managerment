import 'dart:convert';
import 'package:frontend/model/order_detail_model..dart' as detailModel;
import 'package:http/http.dart' as http;
import 'package:frontend/model/order_model.dart';

class OrderController {
  String baseUrl = 'http://localhost:3000/api/orders';
  // Get all orders
  Future<List<Order>> getOrders() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  // Get a specific order
  Future<Order> getOrder(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return Order.fromJson(data);
      } else {
        throw Exception('Failed to load order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load order: $e');
    }
  }

  // Modified to fetch order with details in a single request
  Future<Order> getOrderWithDetails(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id?include_details=true'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return Order.fromJson(data);
      } else {
        throw Exception(
          'Failed to load order with details: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to load order with details: $e');
    }
  }

  // Create a new order
  Future<Order> createOrder(Order order) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(order.toJson()),
      );

      if (response.statusCode == 201) {
        Map<String, dynamic> data = json.decode(response.body);
        return Order.fromJson(data);
      } else {
        throw Exception('Failed to create order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // Update an existing order
  Future<Order> updateOrder(Order order) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${order.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(order.toJson()),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return Order.fromJson(data);
      } else {
        throw Exception('Failed to update order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  // Delete an order
  Future<bool> deleteOrder(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }

  // Update the status of an order
  Future<Order> updateOrderStatus(String id, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/$id/status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return Order.fromJson(data);
      } else {
        throw Exception(
          'Failed to update order status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // Get order details for a specific order
  Future<List<detailModel.OrderDetail>> getOrderDetails(String orderId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$orderId/details'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data
            .map((json) => detailModel.OrderDetail.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load order details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load order details: $e');
    }
  }

  // Add order detail and update the order
  Future<Order> addOrderDetail(String orderId, OrderDetail detail) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$orderId/details'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(detail.toJson()),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        // Return the updated order with the new detail
        return getOrderWithDetails(orderId);
      } else {
        throw Exception('Failed to add order detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add order detail: $e');
    }
  }
}
