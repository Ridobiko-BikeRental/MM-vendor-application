import 'package:flutter/material.dart';
import 'package:yumquick/view/mealboxorder/model/ordermealmodel.dart';
import 'package:yumquick/view/mealboxorder/view/newmealorderscreen.dart';
import 'package:yumquick/view/neworder/model/ordermodel.dart';
import 'package:yumquick/view/neworder/view/neworderscreen.dart';
import 'package:yumquick/view/widget/app_colors.dart';

class OrderAlertDialog extends StatelessWidget {
  final Order? order;
  final MealBoxOrder? orderMeal;

  const OrderAlertDialog({Key? key, this.order, this.orderMeal})
    : assert(
        order != null || orderMeal != null,
        'Either order or orderMeal must be provided.',
      ),
      super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isMealBoxOrder = orderMeal != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(20),
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 15,
              spreadRadius: 2,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_bag, color: AppColors.primary, size: 50),
                const SizedBox(height: 12),
                Text(
                  "New ${isMealBoxOrder ? 'Meal Box' : ''} Order Received!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Divider(color: Colors.grey.shade300),
                SizedBox(height: 8),

                // Text(
                //   "Order #${isMealBoxOrder ? orderMeal!.id ?? '' : order!.orderId ?? ''}",
                //   style: const TextStyle(fontSize: 16, color: Colors.black54),
                // ),
                // const SizedBox(height: 12),
                if (isMealBoxOrder)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${orderMeal!.id} × ${orderMeal!.title.isNotEmpty ? orderMeal!.title : 'Meal Box'}",
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (orderMeal!.items.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          "Includes: ${orderMeal!.items.join(", ")}",
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),

                if (!isMealBoxOrder && order!.items.isNotEmpty)
                  Column(
                    children: order!.items
                        .map(
                          (item) => Text(
                            "${item.quantity} × ${item.subCategory!.name}",
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        if (isMealBoxOrder) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) =>
                                  NewMealOrdersScreen(initialIndex: 0),
                            ),
                          );
                        } else {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) =>
                                  NewOrdersScreen(initialIndex: 0),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.visibility, size: 18),
                      label: Text(
                        "View Order",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              right: 0,
              top: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black54),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
