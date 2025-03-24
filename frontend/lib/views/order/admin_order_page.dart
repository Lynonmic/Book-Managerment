// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'order_provider.dart';
// import 'order_item_widget.dart';

// class OrderListPage extends StatelessWidget {
//   const OrderListPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('ORDER LIST'),
//         elevation: 1,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search),
//             onPressed: () {
//               // Implement search functionality
//             },
//           ),
//         ],
//       ),
//       body: Consumer<OrderProvider>(
//         builder: (context, orderProvider, child) {
//           final orders = orderProvider.orders;

//           return ListView.builder(
//             itemCount: orders.length + 3, // Orders + placeholder rows
//             itemBuilder: (context, index) {
//               if (index < orders.length) {
//                 // Real orders with navigation
//                 return OrderItemWidget(order: orders[index]);
//               } else {
//                 // Placeholder rows
//                 return Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: const BoxDecoration(
//                     border: Border(
//                       bottom: BorderSide(color: Colors.grey, width: 0.5),
//                     ),
//                   ),
//                   child: const Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Row Header',
//                         style: TextStyle(fontWeight: FontWeight.w500),
//                       ),
//                       Text(
//                         'Body copy description',
//                         style: TextStyle(color: Colors.grey, fontSize: 14),
//                       ),
//                     ],
//                   ),
//                 );
//               }
//             },
//           );
//         },
//       ),
//       // Note: No floating action button or bottom navigation bar here since you have your own
//     );
//   }
// }
