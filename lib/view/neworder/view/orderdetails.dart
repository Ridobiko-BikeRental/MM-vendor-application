// // orderdetails.dart

// import 'package:flutter/material.dart';

// import '../model/ordermodel.dart';

// class OrderDetailScreen extends StatelessWidget {
//   final Order order;

//   const OrderDetailScreen({super.key, required this.order});

//   @override
//   Widget build(BuildContext context) {
//     final itemsText = order.items.map((item) {
//       final dishName = (item.subCategory != null && item.subCategory!.name.isNotEmpty)
//           ? item.subCategory!.name
//           : (item.category != null ? item.category!.name : 'Unknown');
//       return '• $dishName x${item.quantity}';
//     }).join('\n');

//     TextStyle headerStyle = const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange);
//     TextStyle labelStyle = const TextStyle(fontWeight: FontWeight.w600, fontSize: 16);
//     TextStyle valueStyle = const TextStyle(fontSize: 16, color: Colors.black87);
//     TextStyle itemStyle = const TextStyle(fontSize: 16, height: 1.4);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Order #${order.id} Details"),
//         backgroundColor: Colors.deepOrange,
//       ),
//       backgroundColor: Colors.grey.shade100,
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Card(
//           elevation: 6,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           shadowColor: Colors.deepOrange.withOpacity(0.15),
//           color: Colors.white,
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Center(child: Text("Order Details", style: headerStyle)),
//                 const SizedBox(height: 20),
//                 _buildInfoRow("Customer Name", order.customerName, labelStyle, valueStyle),
//                 const SizedBox(height: 12),
//                 _buildInfoRow("Customer Email", order.customerEmail, labelStyle, valueStyle),
//                 const SizedBox(height: 12),
//                 _buildInfoRow(
//                   "Status",
//                   order.status.capitalize(),
//                   labelStyle,
//                   TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _getStatusColor(order.status)),
//                 ),
//                 const SizedBox(height: 12),
//                 _buildInfoRow("Created At", _formatDate(order.createdAt), labelStyle, valueStyle),
//                 _buildInfoRow("Updated At", _formatDate(order.updatedAt), labelStyle, valueStyle),
//                 if (order.cancelReason != null) ...[
//                   const SizedBox(height: 12),
//                   _buildInfoRow("Cancel Reason", order.cancelReason!, labelStyle, const TextStyle(fontSize: 16, color: Colors.redAccent)),
//                 ],
//                 const Divider(height: 40, thickness: 1),
//                 Text("Order Items", style: headerStyle),
//                 const SizedBox(height: 12),
//                 Text(itemsText, style: itemStyle),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(String label, String value, TextStyle labelStyle, TextStyle valueStyle) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(child: Text("$label:", style: labelStyle)),
//         Expanded(flex: 2, child: Text(value, style: valueStyle)),
//       ],
//     );
//   }

//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case "pending":
//       case "preparing":
//         return Colors.orange;
//       case "cancelled":
//         return Colors.red;
//       case "completed":
//         return Colors.green;
//       default:
//         return Colors.black87;
//     }
//   }

//   String _formatDate(DateTime dt) {
//     return "${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
//   }
// }

// extension StringCap on String {
//   String capitalize() => isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : this;
// }
