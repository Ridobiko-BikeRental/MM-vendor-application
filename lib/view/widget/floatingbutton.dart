import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:yumquick/view/additems/view/additemsscreen.dart';
import 'package:yumquick/view/addmealbox/view/addmealboxScreen.dart';
import 'package:yumquick/view/addproductscreen/view/addproduct.dart';
import 'package:yumquick/view/widget/app_colors.dart';

class Floating {
  Widget floatingButton(BuildContext context) {
    return SpeedDial(
      backgroundColor: AppColors.primary,
      icon: Icons.add,
      iconTheme: IconThemeData(color: Colors.white, size: 35),
      activeIcon: Icons.close,
      children: [
        SpeedDialChild(
          backgroundColor: AppColors.primary,
          child: Icon(Icons.add_shopping_cart, color: AppColors.background),
          label: 'Add Product',
          labelStyle: TextStyle(color: AppColors.background),
          labelBackgroundColor: AppColors.primary,
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => AddProductScreen()));
          },
        ),
        SpeedDialChild(
          backgroundColor: AppColors.primary,
          child: Icon(Icons.fastfood, color: AppColors.background),
          label: 'Add Meal Box',
          labelStyle: TextStyle(color: Colors.white),
          labelBackgroundColor: AppColors.primary,
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => AddMealBoxScreen()));
          },
        ),
        SpeedDialChild(
          backgroundColor: AppColors.primary,
          child: Icon(Icons.food_bank, color: AppColors.background),
          label: 'Add Items',
          labelStyle: TextStyle(color: Colors.white),
          labelBackgroundColor: AppColors.primary,
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => AddItemsScreen()));
          },
        ),
      ],
    );
  }
}
