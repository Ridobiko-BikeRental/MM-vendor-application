import 'package:flutter/material.dart';
import 'package:yumquick/addedproductlist/addedproductlist.dart';
import 'package:yumquick/view/addmealbox/view/mealbox.dart';
import 'package:yumquick/view/admindashboard/view/adminhomescreen.dart';
import 'package:yumquick/view/mealboxorder/view/newmealorderscreen.dart';
import 'package:yumquick/view/neworder/view/neworderscreen.dart';
import 'package:yumquick/view/widget/app_colors.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 12,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        color: AppColors.primary,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Home
          _navItem(
            context,
            icon: "assets/homepageicons/5.png",
            label: 'Home',
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => AdminHomescreen()),
                (route) => false,
              );
            },
          ),
          // Products List
          _navItem(
            context,
            icon: "assets/homepageicons/6.png",
            label: 'Products',
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => Addedproductlist()),
                (route) => false,
              );
            },
          ),
          // Meal Box
          _navItem(
            context,
            icon: "assets/homepageicons/7.png",
            label: 'Meal Box',
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => MealBoxScreen()),
                (route) => false,
              );
            },
          ),
          // Add Product
          // _navItem(
          //   context,
          //   icon: Icons.add_circle_outline,
          //   label: 'Add Product',
          //   onPressed: () {
          //     Navigator.of(
          //       context,
          //     ).push(MaterialPageRoute(builder: (_) => AddProductScreen()));
          //   },
          // ),
          // New Orders
          _navItem(
            context,
            icon: "assets/homepageicons/8.png",
            label: 'Orders',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NewOrdersScreen()),
              );
            },
          ),
          _navItem(
            context,
            icon: "assets/homepageicons/8.png",
            label: 'Meal Orders',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NewMealOrdersScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required String icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(icon, color: Colors.white, scale: 10),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
