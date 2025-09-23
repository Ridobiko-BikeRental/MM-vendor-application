// ignore_for_file: use_build_context_synchronously

import 'dart:developer' show log;

// import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yumquick/addedproductlist/addedproductlist.dart';
import 'package:yumquick/addedproductlist/subcatscreen.dart';
import 'package:yumquick/view/admindashboard/bloc/dashboard_bloc.dart';
import 'package:yumquick/view/admindashboard/bloc/dashboard_event.dart';
import 'package:yumquick/view/admindashboard/bloc/dashboard_state.dart';
import 'package:yumquick/view/mealboxorder/bloc/newmealorder_bloc.dart';
import 'package:yumquick/view/mealboxorder/bloc/newmealorder_event.dart';
import 'package:yumquick/view/mealboxorder/bloc/newmealorder_state.dart';
import 'package:yumquick/view/mealboxorder/view/newmealorderscreen.dart';
import 'package:yumquick/view/neworder/bloc/neworder_bloc.dart';
import 'package:yumquick/view/neworder/bloc/neworder_event.dart';
import 'package:yumquick/view/neworder/bloc/neworder_state.dart';
import 'package:yumquick/view/neworder/view/neworderscreen.dart';
import 'package:yumquick/view/profile/bloc/userprofile_bloc.dart';
import 'package:yumquick/view/profile/bloc/userprofile_event.dart';
import 'package:yumquick/view/profile/bloc/userprofile_state.dart';
import 'package:yumquick/view/profile/model/vendormodel.dart';
import 'package:yumquick/view/profile/view/vendorprofile.dart';
import 'package:yumquick/view/widget/app_colors.dart';
import 'package:yumquick/view/widget/floatingbutton.dart';
import 'package:yumquick/view/widget/navbar.dart';

enum OrderFilter { today, yesterday, lastWeek, lastMonth, all }

String orderFilterLabel(OrderFilter filter) {
  switch (filter) {
    case OrderFilter.today:
      return "Today";
    case OrderFilter.yesterday:
      return "Yesterday";
    case OrderFilter.lastWeek:
      return "Last Week";
    case OrderFilter.lastMonth:
      return "Last Month";
    case OrderFilter.all:
      return "All";
  }
}

class AdminHomescreen extends StatefulWidget {
  const AdminHomescreen({super.key});

  @override
  State<AdminHomescreen> createState() => _AdminHomescreenState();
}

class _AdminHomescreenState extends State<AdminHomescreen> {
  // final SpeedDialController _controller = SpeedDialController();
  OrderFilter _selectedFilter = OrderFilter.today;
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  // @override
  // void dispose() {
  //   _controller.close(); // close overlay before disposing
  //   super.dispose();
  // }

  Future<void> _refresh() async {
    context.read<NeworderBloc>().add(FetchAllOrders());
    context.read<MealBoxOrderBloc>().add((FetchAllMealOrders()));
    context.read<DashboardBloc>().add(FetchCategoriesEvent());
    context.read<UserprofileBloc>().add(LoadUserProfile());

    // userDetails = context.read<UserprofileBloc>().userDetails!;
    // log("${userDetails.name}");
  }

  List<dynamic> filterOrders(List<dynamic> orderList, OrderFilter filter) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    switch (filter) {
      case OrderFilter.today:
        return orderList
            .where(
              (o) =>
                  o.createdAt.year == today.year &&
                  o.createdAt.month == today.month &&
                  o.createdAt.day == today.day,
            )
            .toList();
      case OrderFilter.yesterday:
        DateTime yesterday = today.subtract(const Duration(days: 1));
        return orderList
            .where(
              (o) =>
                  o.createdAt.year == yesterday.year &&
                  o.createdAt.month == yesterday.month &&
                  o.createdAt.day == yesterday.day,
            )
            .toList();
      case OrderFilter.lastWeek:
        DateTime lastWeek = today.subtract(const Duration(days: 7));
        return orderList
            .where(
              (o) => o.createdAt.isAfter(
                lastWeek.subtract(const Duration(days: 1)),
              ),
            )
            .toList();
      case OrderFilter.lastMonth:
        DateTime lastMonth = DateTime(today.year, today.month - 1, today.day);
        return orderList
            .where(
              (o) => o.createdAt.isAfter(
                lastMonth.subtract(const Duration(days: 1)),
              ),
            )
            .toList();
      case OrderFilter.all:
      default:
        return orderList;
    }
  }

  // late UserModel userDetails;

  Widget dashboardCard(
    String title,
    String value,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(MediaQuery.of(context).size.height / 140),
        decoration: BoxDecoration(
          color: Colors.orangeAccent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
            ),
            // const SizedBox(height: 4),
            // const Text(
            //   "+15% this week",
            //   style: TextStyle(
            //     fontSize: 12,
            //     fontWeight: FontWeight.w500,
            //     color: Colors.green,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nowDate = DateTime.now().toIso8601String().substring(0, 10);
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Exit Application',
              style: TextStyle(color: AppColors.text),
            ),
            content: Text(
              'Are you sure you want to Exit Application?',
              style: TextStyle(color: AppColors.text),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.text),
                ),
              ),
              TextButton(
                onPressed: () => SystemNavigator.pop(),
                child: const Text(
                  'Exit',
                  style: TextStyle(color: AppColors.text),
                ),
              ),
            ],
          ),
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            slivers: [
              // Top AppBar Section
              BlocBuilder<UserprofileBloc, UserprofileState>(
                builder: (context, state) {
                  if (state is UserProfileLoaded) {
                    final UserModel user = state.user;

                    return SliverToBoxAdapter(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(30),
                          ),
                        ),
                        padding: EdgeInsets.fromLTRB(
                          20,
                          size.height * 0.06,
                          20,
                          size.height * 0.04,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: Column(
                                children: [
                                  Container(
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const MyprofileScreen(),
                                          ),
                                        );
                                      },
                                      child: user.image.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Image.network(
                                                user.image,
                                                height:
                                                    48, // or size.height * 0.06 for responsiveness
                                                width: 48,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : const Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Icon(
                                                Icons.person_outline,
                                                color: AppColors.primary,
                                                size: 28,
                                              ),
                                            ),
                                    ),
                                  ),
                                  // Text(
                                  //   user.name.toUpperCase(),
                                  //   style: TextStyle(
                                  //     color: Colors.white,
                                  //     fontSize: size.height / 95,
                                  //     fontWeight: FontWeight.bold,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              "Good Morning",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: AppColors.background,
                              ),
                            ),
                            // Text(
                            //   user.name,
                            //   style: TextStyle(
                            //     fontSize: size.height / 70,
                            //     fontWeight: FontWeight.bold,
                            //     color: Colors.white,
                            //   ),
                            // ),
                            const SizedBox(height: 6),
                            const Text(
                              "Rise And Shine! It's Breakfast Time",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.background,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return SliverToBoxAdapter(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(30),
                          ),
                        ),
                        padding: EdgeInsets.fromLTRB(
                          20,
                          size.height * 0.06,
                          20,
                          size.height * 0.04,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                // height: MediaQuery.of(context).size.height / 10,
                                // width: MediaQuery.of(context).size.width / 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.person_outline,
                                    color: AppColors.primary,
                                    size: 28,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const MyprofileScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              "Good Morning",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: AppColors.background,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Rise And Shine! It's Breakfast Time",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.background,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    // vertical: 4,
                  ),

                  child: Row(
                    children: [
                      const Text(
                        "Orders Overview",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      const Spacer(),
                      DropdownButton<OrderFilter>(
                        value: _selectedFilter,
                        items: OrderFilter.values.map((filter) {
                          return DropdownMenuItem<OrderFilter>(
                            value: filter,
                            child: Text(orderFilterLabel(filter)),
                          );
                        }).toList(),
                        onChanged: (filter) {
                          if (filter != null) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          }
                        },
                        underline: SizedBox(),
                        style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w500,
                        ),
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // --- Dashboard Cards Section ---
              SliverToBoxAdapter(
                child: CarouselSlider(
                  items: [
                    Builder(
                      builder: (BuildContext context) {
                        return BlocBuilder<NeworderBloc, NeworderState>(
                          builder: (context, dashState) {
                            if (dashState is NeworderLoading) {
                              return Padding(
                                padding: const EdgeInsets.all(8),

                                child: GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 1.2,
                                  children: List.generate(
                                    4,
                                    (index) => const SkeletonBox(
                                      height: 120,
                                      width: double.infinity,
                                    ),
                                  ),
                                ),
                              );
                            } else if (dashState is NeworderLoaded) {
                              return BlocBuilder<NeworderBloc, NeworderState>(
                                builder: (context, orderState) {
                                  if (orderState is NeworderLoading) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),

                                      child: GridView.count(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 12,
                                        crossAxisSpacing: 12,
                                        childAspectRatio: 1.2,
                                        children: List.generate(
                                          4,
                                          (index) => const SkeletonBox(
                                            height: 120,
                                            width: double.infinity,
                                          ),
                                        ),
                                      ),
                                    );
                                  } else if (orderState is NeworderLoaded) {
                                    final filteredOrders = filterOrders(
                                      orderState.orders,
                                      _selectedFilter,
                                    );

                                    final pending = filteredOrders
                                        .where(
                                          (o) =>
                                              o.status.toLowerCase() ==
                                              "pending",
                                        )
                                        .toList();
                                    final cancelled = filteredOrders
                                        .where(
                                          (o) =>
                                              o.status.toLowerCase() ==
                                              "cancelled",
                                        )
                                        .toList();
                                    final preparing = filteredOrders
                                        .where(
                                          (o) =>
                                              o.status.toLowerCase() ==
                                              "confirmed",
                                        )
                                        .toList();

                                    return Padding(
                                      padding: const EdgeInsets.all(1.0),
                                      child: Column(
                                        children: [
                                          GridView.count(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            crossAxisCount: 2,
                                            mainAxisSpacing: 12,
                                            crossAxisSpacing: 12,
                                            childAspectRatio: 1.2,
                                            children: [
                                              dashboardCard(
                                                "Total Orders",
                                                "${filteredOrders.length}",
                                                Icons.all_out,
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          const NewOrdersScreen(
                                                            initialIndex: 4,
                                                          ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              dashboardCard(
                                                "Pending Orders",
                                                "${pending.length}",
                                                Icons.pending,
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          const NewOrdersScreen(
                                                            initialIndex: 0,
                                                          ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              dashboardCard(
                                                "Cancelled Orders",
                                                "${cancelled.length}",
                                                Icons.cancel_outlined,
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          const NewOrdersScreen(
                                                            initialIndex: 1,
                                                          ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              dashboardCard(
                                                "Preparing Orders",
                                                "${preparing.length}",
                                                Icons.kitchen,
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          const NewOrdersScreen(
                                                            initialIndex: 2,
                                                          ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        );
                      },
                    ),
                    Builder(
                      builder: (context) {
                        return BlocBuilder<MealBoxOrderBloc, NewMealorderState>(
                          builder: (context, dashState) {
                            if (dashState is NewMealorderLoading) {
                              return Padding(
                                padding: const EdgeInsets.all(8),

                                child: GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 1.2,
                                  children: List.generate(
                                    4,
                                    (index) => const SkeletonBox(
                                      height: 120,
                                      width: double.infinity,
                                    ),
                                  ),
                                ),
                              );
                            } else if (dashState is NewMealorderLoaded) {
                              return BlocBuilder<
                                MealBoxOrderBloc,
                                NewMealorderState
                              >(
                                builder: (context, orderState) {
                                  if (orderState is NewMealorderLoading) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),

                                      child: GridView.count(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 12,
                                        crossAxisSpacing: 12,
                                        childAspectRatio: 1.2,
                                        children: List.generate(
                                          4,
                                          (index) => const SkeletonBox(
                                            height: 120,
                                            width: double.infinity,
                                          ),
                                        ),
                                      ),
                                    );
                                  } else if (orderState is NewMealorderLoaded) {
                                    log("${orderState.mealOrders.length}");
                                    final filteredOrders = filterOrders(
                                      orderState.mealOrders,
                                      _selectedFilter,
                                    );

                                    final pending = filteredOrders
                                        .where(
                                          (o) =>
                                              o.status.toLowerCase() ==
                                              "pending",
                                        )
                                        .toList();
                                    final cancelled = filteredOrders
                                        .where(
                                          (o) =>
                                              o.status.toLowerCase() ==
                                              "cancelled",
                                        )
                                        .toList();
                                    final preparing = filteredOrders
                                        .where(
                                          (o) =>
                                              o.status.toLowerCase() ==
                                              "confirmed",
                                        )
                                        .toList();

                                    return Padding(
                                      padding: EdgeInsets.all(
                                        MediaQuery.of(context).size.height / 50,
                                      ),
                                      child: Column(
                                        children: [
                                          GridView.count(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            crossAxisCount: 2,
                                            mainAxisSpacing: 12,
                                            crossAxisSpacing: 12,
                                            childAspectRatio: 1.2,
                                            children: [
                                              dashboardCard(
                                                "Total MealBox Orders",
                                                "${filteredOrders.length}",
                                                Icons.all_out,
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          const NewMealOrdersScreen(
                                                            initialIndex: 4,
                                                          ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              dashboardCard(
                                                "Pending MealBox Orders",
                                                "${pending.length}",
                                                Icons.pending,
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          const NewMealOrdersScreen(
                                                            initialIndex: 0,
                                                          ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              dashboardCard(
                                                "Cancelled MealBox Orders",
                                                "${cancelled.length}",
                                                Icons.cancel_outlined,
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          const NewMealOrdersScreen(
                                                            initialIndex: 1,
                                                          ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              dashboardCard(
                                                "Preparing MealBox Orders",
                                                "${preparing.length}",
                                                Icons.kitchen,
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          const NewMealOrdersScreen(
                                                            initialIndex: 2,
                                                          ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        );
                      },
                    ),
                  ],
                  options: CarouselOptions(
                    height: MediaQuery.of(context).size.height / 2.2,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: false,
                    viewportFraction: 0.95,
                  ),
                ),
              ),

              // Product Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width / 50,
                    vertical: MediaQuery.of(context).size.height / 50,
                  ),
                  child: Row(
                    children: [
                      const Text(
                        "Your Added Products",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Addedproductlist(),
                            ),
                          );
                        },
                        child: const Text(
                          "View More >",
                          style: TextStyle(color: AppColors.text),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Categories List
              BlocBuilder<DashboardBloc, DashboardState>(
                builder: (context, dashState) {
                  if (dashState is DashboardLoaded &&
                      dashState.allCategories.isNotEmpty) {
                    final categories = dashState.allCategories;
                    return SliverToBoxAdapter(
                      child: SizedBox(
                        height: size.height * 0.21, // smaller height
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          itemBuilder: (context, idx) {
                            final cat = categories[idx];
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => SubCategoryScreen(
                                      subCategories: cat.subCategories,
                                      categoryName: cat.name,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: size.width * 0.5, // smaller width
                                margin: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.shade300,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    if (cat.imageUrl.isNotEmpty)
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(14),
                                            ),
                                        child: Image.network(
                                          cat.imageUrl,
                                          height:
                                              size.height *
                                              0.13, // smaller image
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    else
                                      const Icon(
                                        Icons.fastfood,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              cat.name.toUpperCase(),
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.brown,
                                              ),
                                            ),
                                          ),
                                          // Row(
                                          //   children: [
                                          //     IconButton(
                                          //       padding: EdgeInsets.zero,
                                          //       constraints:
                                          //           const BoxConstraints(),
                                          //       iconSize: 18,
                                          //       onPressed: () {
                                          //         Navigator.push(
                                          //           context,
                                          //           MaterialPageRoute(
                                          //             builder: (_) =>
                                          //                 CategoryUpdateScreen(
                                          //                   categoryId: cat.id,
                                          //                   currentName: cat.name,
                                          //                 ),
                                          //           ),
                                          //         );
                                          //       },
                                          //       icon: const Icon(
                                          //         Icons.edit,
                                          //         color: Colors.orange,
                                          //       ),
                                          //     ),
                                          //     IconButton(
                                          //       padding: EdgeInsets.zero,
                                          //       constraints:
                                          //           const BoxConstraints(),
                                          //       iconSize: 18,
                                          //       onPressed: () async {
                                          //         final shouldDelete =
                                          //             await showDialog<bool>(
                                          //               context: context,
                                          //               builder: (context) => AlertDialog(
                                          //                 title: const Text(
                                          //                   'Delete Category',
                                          //                 ),
                                          //                 content: const Text(
                                          //                   'Are you sure you want to delete this category?',
                                          //                 ),
                                          //                 actions: [
                                          //                   TextButton(
                                          //                     onPressed: () =>
                                          //                         Navigator.of(
                                          //                           context,
                                          //                         ).pop(false),
                                          //                     child: const Text(
                                          //                       'Cancel',
                                          //                     ),
                                          //                   ),
                                          //                   TextButton(
                                          //                     onPressed: () =>
                                          //                         Navigator.of(
                                          //                           context,
                                          //                         ).pop(true),
                                          //                     child: const Text(
                                          //                       'Delete',
                                          //                       style: TextStyle(
                                          //                         color:
                                          //                             Colors.red,
                                          //                       ),
                                          //                     ),
                                          //                   ),
                                          //                 ],
                                          //               ),
                                          //             );

                                          //         if (shouldDelete == true) {
                                          //           final url =
                                          //               'https://mm-food-backend.onrender.com/api/categories/delete/${cat.id}';
                                          //           final res = await http.delete(
                                          //             Uri.parse(url),
                                          //           );
                                          //           if (!mounted) return;
                                          //           if (res.statusCode == 200) {
                                          //             ScaffoldMessenger.of(
                                          //               context,
                                          //             ).showSnackBar(
                                          //               const SnackBar(
                                          //                 content: Text(
                                          //                   "Deleted successfully",
                                          //                 ),
                                          //               ),
                                          //             );
                                          //             context
                                          //                 .read<DashboardBloc>()
                                          //                 .add(
                                          //                   FetchCategoriesEvent(),
                                          //                 );
                                          //           } else {
                                          //             ScaffoldMessenger.of(
                                          //               context,
                                          //             ).showSnackBar(
                                          //               const SnackBar(
                                          //                 content: Text(
                                          //                   "Failed to delete",
                                          //                 ),
                                          //               ),
                                          //             );
                                          //           }
                                          //         }
                                          //       },
                                          //       icon: const Icon(
                                          //         Icons.delete,
                                          //         color: Colors.red,
                                          //       ),
                                          //     ),
                                          //   ],
                                          // ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  } else if (dashState is DashboardLoading) {
                    // Skeleton while categories load
                    return SliverToBoxAdapter(
                      child: SizedBox(
                        height: size.height * 0.21,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 3,
                          itemBuilder: (context, index) => Container(
                            width: size.width * 0.55,
                            margin: const EdgeInsets.all(12),
                            child: const SkeletonBox(height: 180),
                          ),
                        ),
                      ),
                    );
                  }
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Text(
                        "No categories found!",
                        style: TextStyle(color: AppColors.text),
                      ),
                    ),
                  );
                },
              ),

              // Pending Orders Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Text(
                        "Today's Pending Orders",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const NewOrdersScreen(initialIndex: 0),
                            ),
                          );
                        },
                        child: const Text(
                          "View More >",
                          style: TextStyle(color: AppColors.text),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              BlocBuilder<NeworderBloc, NeworderState>(
                builder: (context, orderState) {
                  if (orderState is NeworderLoaded) {
                    final nowDate = DateTime.now().toIso8601String().substring(
                      0,
                      10,
                    );
                    final pending = orderState.orders
                        .where(
                          (o) =>
                              o.status.toLowerCase() == "pending" &&
                              o.createdAt.toIso8601String().substring(0, 10) ==
                                  nowDate,
                        )
                        .toList();
                    if (pending.length != 0) {
                      return SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final order = pending[index];
                          return Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: Colors.orange.shade100,
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.orange,
                                ),
                              ),
                              title: Text(
                                order.customerName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Status: ${order.status}",
                                    style: TextStyle(
                                      color:
                                          order.status.toLowerCase() ==
                                              "pending"
                                          ? Colors.orange
                                          : Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    order.createdAt.toLocal().toString().split(
                                      ' ',
                                    )[0],
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }, childCount: pending.length),
                      );
                    } else {
                      return SliverToBoxAdapter(
                        child: Card(
                          child: ListTile(
                            title: Text(
                              'No Pending Orders Today!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    }
                  } else if (orderState is NeworderLoading) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: const [
                            SkeletonBox(height: 70),
                            SizedBox(height: 12),
                            SkeletonBox(height: 70),
                            SizedBox(height: 12),
                            SkeletonBox(height: 70),
                          ],
                        ),
                      ),
                    );
                  }
                  return SliverToBoxAdapter(
                    child: Card(
                      child: ListTile(
                        title: Text(
                          'No Pending Orders Today!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // Inside Scaffold
        floatingActionButton: Floating().floatingButton(context),
        // floatingActionButton: CircularMenu(
        //   toggleButtonAnimatedIconData: AnimatedIcons.add_event,

        //   alignment: Alignment.bottomRight, // FAB position
        //   radius: 70, // Distance buttons spread
        //   toggleButtonSize: 30, // Size of main FAB
        //   toggleButtonColor: Colors.orangeAccent,
        //   toggleButtonIconColor: Colors.white,
        //   items: [
        //     CircularMenuItem(
        //       icon: Icons.add_shopping_cart,
        //       color: Colors.orange,
        //       onTap: () {
        //         Navigator.of(
        //           context,
        //         ).push(MaterialPageRoute(builder: (_) => AddProductScreen()));
        //       },
        //     ),
        //     CircularMenuItem(
        //       badgeLabel: "Add Meal",
        //       icon: Icons.fastfood,
        //       color: Colors.orange,
        //       onTap: () {
        //         Navigator.of(context).pushAndRemoveUntil(
        //           MaterialPageRoute(builder: (_) => AddMealBoxScreen()),
        //           (route) => false,
        //         );
        //       },
        //     ),
        //   ],
        //   // backgroundWidget: /* Your main content widget here */,
        // ),
        bottomNavigationBar: const Navbar(),
      ),
    );
  }
}

class SkeletonBox extends StatelessWidget {
  final double height;
  final double width;
  const SkeletonBox({
    super.key,
    required this.height,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
