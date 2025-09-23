import 'dart:async' show Timer;

import 'package:flutter/material.dart';
import 'package:yumquick/view/widget/app_colors.dart';

class OrderCancelledScreen extends StatefulWidget {
  const OrderCancelledScreen({super.key});

  @override
  State<OrderCancelledScreen> createState() => _OrderCancelledScreenState();
}

class _OrderCancelledScreenState extends State<OrderCancelledScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background, // Background color
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Back arrow
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Text(""),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),

            const Spacer(flex: 2),

            /// ✅ Tick GIF instead of CustomPaint
            SizedBox(
              height: size.height * 0.25,
              child: Image.asset(
                "assets/homepageicons/Cancel.gif", // <-- your gif
                fit: BoxFit.contain,
                color: AppColors.primary,
              ),
            ),

            const Spacer(),

            // Cancelled message
            Text(
              "¡Order Cancelled!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Your order has been\ncancelled successfully",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.text),
            ),

            const SizedBox(height: 16),

            const Spacer(flex: 4),

            // Bottom message
            // const Padding(
            //   padding: EdgeInsets.only(bottom: 32, left: 16, right: 16),
            //   child: Text(
            //     "If you have any questions, please reach out\ndirectly to our customer support",
            //     textAlign: TextAlign.center,
            //     style: TextStyle(fontSize: 14, color: Colors.black87),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
