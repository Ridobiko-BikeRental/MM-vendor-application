
import 'package:yumquick/view/neworder/model/ordermodel.dart';

abstract class NeworderEvent {}

class FetchAllOrders extends NeworderEvent {}

class ConfirmOrderEvent extends NeworderEvent {
  final String orderId;
  final String time;
  final String date;

  ConfirmOrderEvent(this.orderId, this.date, this.time);
}

class DeliveredOrderEvent extends NeworderEvent {
  final String orderId;

  DeliveredOrderEvent(this.orderId);
}

class CancelOrderEvent extends NeworderEvent {
  final String orderId;
  final String cancelReason;

  CancelOrderEvent(this.orderId, this.cancelReason);
}

class MarkDeliveringOrderEvent extends NeworderEvent {
  final String orderId;

  MarkDeliveringOrderEvent(this.orderId);
}

// Custom event for socket updates
class OrdersUpdatedFromSocket extends NeworderEvent {
  final List<Order> orders;
  OrdersUpdatedFromSocket(this.orders);
}