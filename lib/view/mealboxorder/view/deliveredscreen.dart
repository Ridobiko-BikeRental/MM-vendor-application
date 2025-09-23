import 'dart:async' show Timer;

import 'package:flutter/material.dart';
import 'package:yumquick/view/widget/app_colors.dart';

class MealOrderDeliverdScreen extends StatefulWidget {
  const MealOrderDeliverdScreen({super.key});

  @override
  State<MealOrderDeliverdScreen> createState() => _MealOrderDeliveredScreenState();
}

class _MealOrderDeliveredScreenState extends State<MealOrderDeliverdScreen> {
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
      backgroundColor: AppColors.background, // Background color from image
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
            Spacer(flex: 2),
            // Large circle with dot
            SizedBox(
              height: size.height * 0.25,
              child: Image.asset(
                "assets/homepageicons/tick.gif", // <-- your gif
                fit: BoxFit.contain,
                color: Colors.green,
              ),
            ),
            Spacer(),
            // Order Confirmed Text
            Text(
              "¡Order Delivered!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Your order has been Delivered \nsuccesfully",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.text),
            ),
            SizedBox(height: 16),

            Spacer(flex: 4),
            // Bottom text
            // Padding(
            //   padding: const EdgeInsets.only(bottom: 32, left: 16, right: 16),
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

// Custom painter for circle and dot
class _CircleDotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint circle = Paint()
      ..color = Colors.deepOrange
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    Paint dot = Paint()
      ..color = Colors.deepOrange
      ..style = PaintingStyle.fill;

    // Draw circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 - 8,
      circle,
    );
    // Draw dot (positioned as in image)
    canvas.drawCircle(Offset(size.width / 2 - 26, size.height / 2), 8, dot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
