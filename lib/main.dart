import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yumquick/view/additems/bloc/add_items_bloc.dart';
import 'package:yumquick/view/addmealbox/bloc/addmealbox_bloc.dart';
import 'package:yumquick/view/addproductscreen/bloc/addproduct_bloc.dart';
import 'package:yumquick/view/admindashboard/bloc/dashboard_bloc.dart';
import 'package:yumquick/view/admindashboard/bloc/dashboard_event.dart';
import 'package:yumquick/view/admindashboard/view/adminhomescreen.dart';
import 'package:yumquick/view/auth/bloc/auth_bloc.dart';
import 'package:yumquick/view/auth/view/loginscreen.dart';
import 'package:yumquick/view/mealboxorder/bloc/newmealorder_bloc.dart';
import 'package:yumquick/view/neworder/bloc/neworder_bloc.dart';
import 'package:yumquick/view/profile/bloc/userprofile_bloc.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => DashboardBloc()..add(FetchCategoriesEvent()),
        ),
        BlocProvider(create: (_) => ProductBloc()),
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => NeworderBloc()),
        BlocProvider(create: (_) => UserprofileBloc()),
        BlocProvider(create: (_) => MealBoxBloc()),
        BlocProvider(create: (_) => AddItemsBloc()),
        BlocProvider(create: (_) => MealBoxOrderBloc()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _checkIfLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('loggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: _checkIfLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final isLoggedIn = snapshot.data ?? false;

          if (isLoggedIn) {
            return const AdminHomescreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
