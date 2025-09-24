import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yumquick/view/admindashboard/view/adminhomescreen.dart';
import 'package:yumquick/view/mealboxorder/view/cancelresonscreem.dart';
import 'package:yumquick/view/widget/app_colors.dart';
import 'package:yumquick/view/widget/floatingbutton.dart';

import '../../widget/navbar.dart';
import '../bloc/newmealorder_bloc.dart';
import '../bloc/newmealorder_event.dart';
import '../bloc/newmealorder_state.dart';
import '../model/ordermealmodel.dart';
import 'cancelorder.dart';
import 'confirmmealdatetimescreen.dart';
import 'confirmscreen.dart';
import 'deliveredscreen.dart';

class NewMealOrdersScreen extends StatefulWidget {
  final int initialIndex;

  const NewMealOrdersScreen({super.key, this.initialIndex = 0});

  @override
  _NewMealOrdersScreenState createState() => _NewMealOrdersScreenState();
}

class _NewMealOrdersScreenState extends State<NewMealOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    context.read<MealBoxOrderBloc>().add(FetchAllMealOrders());

    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    context.read<MealBoxOrderBloc>().audioPlayer.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showNewOrderDialog(List<MealBoxOrder> newOrders) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Orders'),
        content: Text('You have ${newOrders.length} new orders'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _callCustomer(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    await launchUrl(uri);
  }

  Future<void> _showConfirmSplash() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => OrderconfirmScreen(),
      ),
    );
    context.read<MealBoxOrderBloc>().add(FetchAllMealOrders());
  }

  Future<void> _showCancelSplash() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => OrderCancelledScreen(),
      ),
    );
    context.read<MealBoxOrderBloc>().add(FetchAllMealOrders());
  }

  Future<void> _showDeliveredSplash() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => MealOrderDeliverdScreen(),
      ),
    );
    context.read<MealBoxOrderBloc>().add(FetchAllMealOrders());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MealBoxOrderBloc, NewMealorderState>(
      listener: (context, state) async {
        if (state is NewMealorderLoaded) {
          if (state.mealOrders.length >
              context.read<MealBoxOrderBloc>().lastOrderCount) {
            context.read<MealBoxOrderBloc>().lastOrderCount =
                state.mealOrders.length;
          }
        }

        if (state is ConfirmMealOrderSuccess) {
          await _showConfirmSplash();
        }
        if (state is CancelMealOrderSuccess) {
          await _showCancelSplash();
        }
        if (state is DeliveredConfirmMealOrderSuccess) {
          await _showDeliveredSplash();
        }
        if (state is ConfirmMealOrderError || state is CancelMealOrderError) {
          final error = state is ConfirmMealOrderError
              ? state.error
              : (state as CancelMealOrderError).error;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error)));
        }
      },
      child: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => AdminHomescreen()),
            (route) => false,
          );
          return false;
        },
        child: Scaffold(
          floatingActionButton: Floating().floatingButton(context),
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(
              'Orders',
              style: TextStyle(color: AppColors.background),
            ),
            bottom: TabBar(
              labelColor: AppColors.background,
              controller: _tabController,
              tabs: const [
                Tab(text: 'Pending'),
                Tab(text: 'Cancelled'),
                Tab(text: 'Preparing'),
                Tab(text: 'Delivered'),
                Tab(text: 'All'),
              ],
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.background,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            backgroundColor: AppColors.primary,
          ),

          body: StreamBuilder<List<MealBoxOrder>>(
            stream: context.read<MealBoxOrderBloc>().ordersStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No Orders Found'));
              }

              final orders = snapshot.data!;
              final List<List<MealBoxOrder>> tabOrders = [
                orders
                    .where((o) => o.status.toLowerCase() == 'pending')
                    .toList(),
                orders
                    .where((o) => o.status.toLowerCase() == 'cancelled')
                    .toList(),
                orders
                    .where((o) => o.status.toLowerCase() == 'confirmed')
                    .toList(),
                orders
                    .where((o) => o.status.toLowerCase() == 'delivered')
                    .toList(),
                orders,
              ];

              return TabBarView(
                controller: _tabController,
                children: tabOrders.map((orders) {
                  if (orders.isEmpty) {
                    return const Center(child: Text('No Orders Found'));
                  }
                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (_, i) => _buildOrderCard(orders[i]),
                  );
                }).toList(),
              );
            },
          ),
          bottomNavigationBar: const Navbar(),
        ),
      ),
    );
  }

  Widget _buildOrderCard(MealBoxOrder order) {
    final status = order.status.toLowerCase();
    final isPending = status == 'pending';
    final isCancelled = status == 'cancelled';
    final isConfirmed = status == 'confirmed';
    final isDelivered = status == 'delivered';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '#${order.id}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: MediaQuery.of(context).size.height * 0.022,
                      color: Colors.orange,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isPending
                        ? AppColors.primary.withOpacity(0.1)
                        : isConfirmed
                        ? Colors.green.withOpacity(0.1)
                        : isCancelled
                        ? Colors.red.withOpacity(0.09)
                        : isDelivered
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.status.capitalize(),
                    style: TextStyle(
                      color: isPending
                          ? AppColors.primary.withOpacity(0.1)
                          : isConfirmed
                          ? Colors.green[800]
                          : isCancelled
                          ? Colors.red
                          : isDelivered
                          ? Colors.blue
                          : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              "MealBox: ${order.title.toUpperCase()}",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15.5,
                color: Colors.grey[600],
              ),
            ),
            Text(
              "Quantity: ${order.quantity}",
              style: TextStyle(color: Colors.grey[500], fontSize: 12.5),
            ),
            const SizedBox(height: 6),
            Divider(thickness: 1.1, color: Colors.grey[200]),
            const SizedBox(height: 6),
            Text(
              '${DateFormat('yyyy-MM-dd').format(order.createdAt.toUtc().add(const Duration(hours: 5, minutes: 30)))}',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black.withOpacity(0.82),
                height: 1.33,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 19,
                  color: Colors.orange.withOpacity(0.58),
                ),
                const SizedBox(width: 6),
                Text(
                  "${DateFormat('hh:mm').format(order.createdAt.toUtc().add(const Duration(hours: 5, minutes: 30)))}",
                  style: TextStyle(
                    color: Colors.grey[800]?.withOpacity(0.92),
                    fontSize: 13.2,
                  ),
                ),
              ],
            ),
            if (isCancelled && (order.reason?.trim().isNotEmpty ?? false)) ...[
              const SizedBox(height: 7),
              Text(
                'Cancelled: ${order.reason}',
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 10),
            if (!isCancelled)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isPending)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ConfirmMealDateTime(
                              orderId: order.id,
                              order: order,
                              onSubmit: (date, time) {
                                context.read<MealBoxOrderBloc>().add(
                                  ConfirmMealOrderEvent(order.id, date, time),
                                );
                              },
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  if (isConfirmed)
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            context.read<MealBoxOrderBloc>().add(
                              DeliveredMealOrderEvent(order.id),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: Colors.orange,
                          ),
                          child: const Text('Mark Delivered'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.call, color: Colors.orange),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[50],
                            foregroundColor: Colors.green,
                          ),
                          label: const Text('Call'),
                          onPressed: () {
                            final phone = order.customerMobile ?? '';
                            if (phone.isNotEmpty) {
                              _callCustomer(phone);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('No phone number'),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  if (isPending) const SizedBox(width: 8),
                  if (isPending)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CancelReasonScreen(
                              orderId: order.id,
                              onSubmit: (reason) {
                                context.read<MealBoxOrderBloc>().add(
                                  CancelMealOrderEvent(order.id, reason),
                                );
                              },
                            ),
                          ),
                        );
                        // context.read<MealBoxOrderBloc>().initSocket();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.orange,
                      ),
                      child: const Text('Cancel'),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

extension StringCap on String {
  String capitalize() =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
}
