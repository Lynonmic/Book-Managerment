import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/model/book_model.dart';
import 'package:frontend/blocs/cart/cart_bloc.dart'; // Thêm import cho CartBloc
import 'package:frontend/blocs/cart/cart_event.dart'; // Import CartEvent

class UserBookPage extends StatefulWidget {
  final Map<String, dynamic> userData; // User data
  final Book book; // Book data

  const UserBookPage({Key? key, required this.book, required this.userData})
    : super(key: key);

  @override
  _UserBookPageState createState() => _UserBookPageState();
}

class _UserBookPageState extends State<UserBookPage> {
  int quantity = 1; // Declare quantity state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.book.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.book.imageUrl ??
                      'https://res.cloudinary.com/dyxy8asve/image/upload/v1746379643/harryposter_wmvvpx.jpg',
                  width: 160,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.broken_image,
                      size: 100,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.book.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (widget.book.author != null && widget.book.author!.isNotEmpty)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.book.author!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            if (widget.book.price != null)
              Row(
                children: [
                  const Icon(
                    Icons.attach_money,
                    color: Color.fromARGB(255, 99, 20, 202),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.book.price!.toStringAsFixed(0)}₫',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 99, 20, 202),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            if (widget.book.description != null &&
                widget.book.description!.isNotEmpty)
              Text(
                widget.book.description!,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            const SizedBox(height: 16),
            const Text(
              'Review',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber),
                Icon(Icons.star, color: Colors.amber),
                Icon(Icons.star, color: Colors.amber),
                Icon(Icons.star, color: Colors.amber),
                Icon(Icons.star, color: Colors.black),
                SizedBox(width: 8),
                Text(
                  '(4.0)',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: ElevatedButton.icon(
          onPressed: () => _showAddToCartDialog(context),
          icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
          label: const Text(
            'Thêm vào giỏ hàng',
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 99, 20, 202),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddToCartDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.35,
          minChildSize: 0.25,
          maxChildSize: 0.5,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setState) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Chọn số lượng',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF331D6F),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            iconSize: 36,
                            icon: const Icon(Icons.remove_circle),
                            color: Colors.deepPurple,
                            onPressed: () {
                              if (quantity > 1) {
                                setState(() => quantity--);
                              }
                            },
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$quantity',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            iconSize: 36,
                            icon: const Icon(Icons.add_circle),
                            color: Colors.deepPurple,
                            onPressed: () => setState(() => quantity++),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          // Trong _showAddToCartDialog, sửa phần onPressed của nút Xác nhận:
                          onPressed: () {
                            // Thêm vào giỏ hàng thông qua CartBloc
                            context.read<CartBloc>().add(
                              AddToCart(
                                userId: widget.userData['id'],
                                bookId: widget.book.id?.toString() ?? '0',
                                quantity: quantity,
                              ),
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Đã thêm $quantity cuốn "${widget.book.title}" vào giỏ hàng',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: const Text(
                            'Xác nhận',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              99,
                              20,
                              202,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
