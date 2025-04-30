import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderDetailsPage extends StatefulWidget {
  final int orderId;
  final String customerName;

  const OrderDetailsPage({
    Key? key,
    required this.orderId,
    required this.customerName,
  }) : super(key: key);

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  bool _isLoading = true;
  String _error = '';
  Map<String, dynamic> _orderDetails = {};
  List<Map<String, dynamic>> _orderItems = [];

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Fetch order with details using the with-details endpoint
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:3000/api/orders/${widget.orderId}/with-details',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData is Map && responseData.containsKey('data')) {
          final data = responseData['data'];

          setState(() {
            _orderDetails = Map<String, dynamic>.from(data);

            // Check if orderDetails is available in the response
            if (data.containsKey('orderDetails') &&
                data['orderDetails'] is List) {
              _orderItems = List<Map<String, dynamic>>.from(
                data['orderDetails'],
              );
            } else {
              _orderItems = [];
            }

            _isLoading = false;
          });

          print('Order details fetched: $_orderDetails');
          print('Order items: $_orderItems');
        } else {
          setState(() {
            _error = 'Unexpected response format';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Failed to load order details: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error fetching order details: $e';
        _isLoading = false;
      });
      print('Error fetching order details: $e');
    }
  }

  // Format date string to a more readable format
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  // Get appropriate color for order status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'chờ xử lý':
        return Colors.orange;
      case 'đã xử lý':
        return Colors.green;
      case 'đã hủy':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${widget.orderId} Details'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _fetchOrderDetails),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _error.isNotEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_error, style: TextStyle(color: Colors.red)),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchOrderDetails,
                      child: Text('Try Again'),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Summary Card
                    Card(
                      margin: EdgeInsets.all(16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Order Summary',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                      _orderDetails['status'] ?? '',
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _orderDetails['status'] ?? 'Unknown',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Divider(height: 24),
                            _buildInfoRow(
                              icon: Icons.person_outline,
                              label: 'Customer',
                              value: widget.customerName,
                            ),
                            _buildInfoRow(
                              icon: Icons.calendar_today,
                              label: 'Order Date',
                              value: _formatDate(
                                _orderDetails['orderDate'] ?? '',
                              ),
                            ),

                            _buildInfoRow(
                              icon: Icons.payment,
                              label: 'Payment Method',
                              value:
                                  _orderDetails['paymentMethod'] ??
                                  'Not specified',
                            ),
                            Divider(height: 24),
                            _buildInfoRow(
                              icon: Icons.attach_money,
                              label: 'Total Amount',
                              value:
                                  '\$${(_orderDetails['totalAmount'] ?? 0).toStringAsFixed(2)}',
                              valueStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Order Items
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        'Ordered Items',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    _orderItems.isEmpty
                        ? Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'No items found for this order',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                        : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _orderItems.length,
                          itemBuilder: (context, index) {
                            final item = _orderItems[index];
                            return Card(
                              margin: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    // Book image from assets instead of URL
                                    Container(
                                      width: 60,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.asset(
                                          'assets/images/book_cover.jpg', // Default book cover
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Icon(
                                              Icons.book,
                                              color: Colors.grey[600],
                                              size: 30,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    // Book details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['bookTitle'] ?? 'Unknown Book',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '\$${(item['price'] ?? 0).toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue[800],
                                                ),
                                              ),
                                              Text(
                                                'Qty: ${item['quantity'] ?? 1}',
                                                style: TextStyle(
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                    // Actions Section
                    if (_orderDetails['status']?.toLowerCase() == 'chờ xử lý')
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.cancel_outlined),
                            label: Text('Cancel Order'),
                            onPressed: () {
                              // Implement cancel functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Cancel order functionality coming soon',
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style:
                      valueStyle ??
                      TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
