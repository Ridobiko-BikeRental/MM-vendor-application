import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yumquick/view/mealboxorder/view/cancelorder.dart';
import 'package:yumquick/view/mealboxorder/view/confirmscreen.dart';
import 'package:yumquick/view/neworder/bloc/neworder_bloc.dart';
import 'package:yumquick/view/neworder/bloc/neworder_event.dart';
import 'package:yumquick/view/neworder/bloc/neworder_state.dart';
import 'package:yumquick/view/neworder/model/ordermodel.dart';
import 'package:yumquick/view/neworder/view/cancelresonscreem.dart';
import 'package:yumquick/view/neworder/view/deliveredscreen.dart';
import 'package:yumquick/view/neworder/view/orderconfimdatetimescreen.dart';
import 'package:yumquick/view/widget/app_colors.dart';
import 'package:yumquick/view/widget/floatingbutton.dart';
import 'package:yumquick/view/widget/navbar.dart';

class NewOrdersScreen extends StatefulWidget {
  final int initialIndex;
  const NewOrdersScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<NewOrdersScreen> createState() => _NewOrdersScreenState();
}

class _NewOrdersScreenState extends State<NewOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    context.read<NeworderBloc>().add(FetchAllOrders());
    tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
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
    context.read<NeworderBloc>().add(FetchAllOrders());
  }

  Future<void> _showCancelSplash() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => OrderCancelledScreen(),
      ),
    );
    context.read<NeworderBloc>().add(FetchAllOrders());
  }

  Future<void> _showDeliveredSplash() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => OrderDeliverdScreen(),
      ),
    );
    context.read<NeworderBloc>().add(FetchAllOrders());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NeworderBloc, NeworderState>(
      listener: (context, state) async {
        if (state is NeworderLoaded && state.orders.isNotEmpty) {
          // if (context.read<NeworderBloc>().lastOrderCount <
          //     state.orders.length) {
          //   // await context.read<NeworderBloc>()._playNotificationSound();
          //   context.read<NeworderBloc>().lastOrderCount = state.orders.length;
          //   // _showNewOrderDialog(
          //   //   state.orders,
          //   //   context.read<NeworderBloc>().lastOrderCount,
          //   //   state.orders.length,
          //   // );
          // }
        }

        if (state is ConfirmOrderSuccess) await _showConfirmSplash();
        if (state is CancelOrderSuccess) await _showCancelSplash();
        if (state is DeliveredOrderSuccess) await _showDeliveredSplash();

        if (state is ConfirmOrderError ||
            state is CancelOrderError ||
            state is DeliveredOrderError) {
          final error = state is ConfirmOrderError
              ? state.error
              : state is CancelOrderError
              ? state.error
              : (state as DeliveredOrderError).error;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error)));
        }
      },
      child: Scaffold(
        floatingActionButton: Floating().floatingButton(context),
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text(
            'Orders',
            style: TextStyle(color: AppColors.background),
          ),
          bottom: TabBar(
            controller: tabController,
            labelColor: AppColors.background,
            tabs: const [
              Tab(text: 'Pending'),
              Tab(text: 'Preparing'),
              // Tab(text: 'Delivering'),
              // Tab(text: 'Delivered'),
              Tab(text: 'All'),
              Tab(text: 'Cancelled'),
            ],
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.background,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocBuilder<NeworderBloc, NeworderState>(
          builder: (context, state) {
            if (state is NeworderLoading ||
                state is ConfirmOrderLoading ||
                state is CancelOrderLoading ||
                state is DeliveredOrderLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is NeworderLoaded) {
              final List<List<Order>> tabOrders = [
                state.orders
                    .where((o) => o.status.toLowerCase() == 'pending')
                    .toList(),

                state.orders
                    .where((o) => o.status.toLowerCase() == 'confirmed')
                    .toList(),
                // state.orders
                //     .where((o) => o.status.toLowerCase() == 'delivering')
                //     .toList(),
                // state.orders
                //     .where((o) => o.status.toLowerCase() == 'delivered')
                //     .toList(),
                state.orders,
                state.orders
                    .where((o) => o.status.toLowerCase() == 'cancelled')
                    .toList(),
              ];

              return TabBarView(
                controller: tabController,
                children: tabOrders.map((orders) {
                  if (orders.isEmpty) {
                    return const Center(
                      child: Text(
                        'No Orders Found',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (_, i) => _buildOrderCard(orders[i]),
                  );
                }).toList(),
              );
            }

            if (state is NeworderError) {
              return Center(child: Text(state.error));
            }

            return const SizedBox.shrink();
          },
        ),
        bottomNavigationBar: const Navbar(),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final itemsText = order.items
        .map(
          (item) =>
              '${item.subCategory?.name ?? item.category?.name ?? 'Unknown'} x${item.quantity}',
        )
        .join(', ');

    final double totalPrice = order.items
        .map((item) => (item.subCategory?.pricePerUnit ?? 0) * item.quantity)
        .fold(0.0, (a, b) => a + b);

    final String status = order.status.toLowerCase();
    final bool isPending = status == 'pending';
    final bool isCancelled = status == 'cancelled';
    final bool isConfirmed = status == 'confirmed';
    final bool isDelivered = status == 'delivered';

    const Color primary = Color.fromRGBO(233, 106, 65, 1);
    const Color textColor = Color.fromARGB(255, 142, 120, 120);
    const Color background = Color.fromRGBO(245, 245, 245, 1);

    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 12, right: 12, top: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.12),
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
            // Header with Order ID and Status badge
            Row(
              children: [
                Text(
                  'Order ID: ${order.orderId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    color: primary,
                    letterSpacing: 0.7,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isPending
                        ? primary.withOpacity(0.1)
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
                          ? primary
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
            // Customer details
            Text(
              order.customerName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15.5,
                color: textColor,
              ),
            ),
            Text(
              order.customerEmail,
              style: TextStyle(
                color: textColor.withOpacity(0.55),
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 6),
            const Divider(thickness: 1.1, color: background),
            const SizedBox(height: 6),
            Text(
              'Order Details: $itemsText',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black.withOpacity(0.82),
                height: 1.33,
              ),
            ),
            const SizedBox(height: 10),
            // Total and time row
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 19,
                  color: primary.withOpacity(0.58),
                ),
                const SizedBox(width: 6),
                Text(
                  "${DateFormat('hh:mm').format(order.createdAt.toUtc().add(const Duration(hours: 5, minutes: 30)))}",
                  style: TextStyle(
                    color: textColor.withOpacity(0.92),
                    fontSize: 13.2,
                  ),
                ),
                const Spacer(),
                Text(
                  '₹${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.7,
                  ),
                ),
              ],
            ),
            if (isCancelled &&
                (order.cancelReason?.trim().isNotEmpty ?? false)) ...[
              const SizedBox(height: 7),
              Text(
                'Cancelled: ${order.cancelReason}',
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
            ],
            // Action buttons
            if (!isCancelled)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isPending)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ConfirmDateTime(
                              orderId: order.orderId,
                              onSubmit: (date, time) {
                                context.read<NeworderBloc>().add(
                                  ConfirmOrderEvent(order.id, date, time),
                                );
                              },
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: background,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(color: primary),
                      ),
                    ),
                  if (isConfirmed) ...[
                    ElevatedButton(
                      onPressed: () {
                        context.read<NeworderBloc>().add(
                          DeliveredOrderEvent(order.id),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: background,
                        foregroundColor: primary,
                      ),
                      child: const Text('Mark Delivered'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.call, color: primary),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[50],
                        foregroundColor: Colors.green,
                      ),
                      label: const Text(
                        'Call',
                        style: TextStyle(color: primary),
                      ),
                      onPressed: () {
                        final phone = order.customerPhone ?? '';
                        if (phone.isNotEmpty) {
                          _callCustomer(phone);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No phone number')),
                          );
                        }
                      },
                    ),
                  ],
                  if (isPending) ...[
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CancelReasonScreen(
                              orderId: order.id,
                              onSubmit: (reason) {
                                context.read<NeworderBloc>().add(
                                  CancelOrderEvent(order.id, reason),
                                );
                              },
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: background,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: primary),
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  // String formatTime(DateTime dt) {
  //   final hour = dt.hour > 12
  //       ? dt.hour - 12
  //       : dt.hour == 0
  //       ? 12
  //       : dt.hour;
  //   final period = dt.hour >= 12 ? 'PM' : 'AM';
  //   final minute = dt.minute.toString().padLeft(2, '0');
  //   return '$hour:$minute $period';
  // }
}

extension StringCap on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
