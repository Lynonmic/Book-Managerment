import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/order/order_bloc.dart';
import 'package:frontend/blocs/order/order_event.dart';
import 'package:frontend/blocs/order/order_state.dart';
import 'package:frontend/model/order_model.dart';
import 'package:frontend/screens/widget/floating_button.dart';

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state.status == OrderStatus.loading) {
          return Center(child: CircularProgressIndicator());
        }

        if (state.status == OrderStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.errorMessage ?? 'An error occurred',
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<OrderBloc>().add(FetchOrders()),
                  child: Text('Try Again'),
                ),
              ],
            ),
          );
        }

        if (state.orders.isEmpty) {
          return Center(child: Text('No orders found'));
        }

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                context.read<OrderBloc>().add(RefreshOrders());
                return Future.delayed(Duration(milliseconds: 300));
              },
              child: ListView.builder(
                itemCount: state.orders.length,
                itemBuilder: (context, index) {
                  final order = state.orders[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        'Order #${order.id}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Text('Customer: ${order.customerName}'),
                          Text('Date: ${order.orderDate.toString().substring(0, 10)}'),
                          Text('Total: \$${order.totalAmount.toStringAsFixed(2)}'),
                          Container(
                            margin: EdgeInsets.only(top: 8),
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              order.status,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        // View order details
                        context.read<OrderBloc>().add(FetchOrderWithDetails(order.id!));
                        // Navigate to order details page
                        // TODO: Implement order details page
                      },
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'update') {
                            _showUpdateOrderStatusDialog(context, order);
                          } else if (value == 'delete') {
                            _showDeleteOrderConfirmationDialog(context, order);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(value: 'update', child: Text('Update Status')),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingButton(
                onPressed: () {
                  // Show create order dialog
                  _showCreateOrderDialog(context);
                },
                tooltip: 'Create Order',
                backgroundColor: Colors.purple,
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'chờ xử lý':
        return Colors.orange;
      case 'processing':
      case 'đang xử lý':
        return Colors.blue;
      case 'shipped':
      case 'đã giao hàng':
        return Colors.green;
      case 'cancelled':
      case 'đã hủy':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showUpdateOrderStatusDialog(BuildContext context, Order order) {
    final statuses = ['Chờ xử lý', 'Đang xử lý', 'Đã giao hàng', 'Đã hủy'];
    String selectedStatus = order.status;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Order Status'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: statuses.map((status) {
                  return RadioListTile<String>(
                    title: Text(status),
                    value: status,
                    groupValue: selectedStatus,
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<OrderBloc>().add(UpdateOrderStatus(order.id!, selectedStatus));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Order status updated')),
                );
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteOrderConfirmationDialog(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Order'),
          content: Text('Are you sure you want to delete Order #${order.id}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<OrderBloc>().add(DeleteOrder(order.id!));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Order deleted')),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Add new method to show create order dialog
  void _showCreateOrderDialog(BuildContext context) {
    final TextEditingController customerIdController = TextEditingController();
    final TextEditingController customerNameController = TextEditingController();
    final TextEditingController totalAmountController = TextEditingController();
    String selectedStatus = 'Chờ xử lý';
    final statuses = ['Chờ xử lý', 'Đang xử lý', 'Đã giao hàng', 'Đã hủy'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Order'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: customerIdController,
                      decoration: const InputDecoration(
                        labelText: 'Customer ID',
                        hintText: 'Enter customer ID',
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: customerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Customer Name',
                        hintText: 'Enter customer name',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: totalAmountController,
                      decoration: const InputDecoration(
                        labelText: 'Total Amount',
                        hintText: 'Enter total amount',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedStatus,
                      items: statuses.map((status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (customerIdController.text.isEmpty ||
                    customerNameController.text.isEmpty ||
                    totalAmountController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                final newOrder = Order(
                  customerId: customerIdController.text,
                  customerName: customerNameController.text,
                  totalAmount: double.tryParse(totalAmountController.text) ?? 0.0,
                  orderDate: DateTime.now(),
                  status: selectedStatus,
                );

                context.read<OrderBloc>().add(CreateOrder(newOrder));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order created successfully')),
                );
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
