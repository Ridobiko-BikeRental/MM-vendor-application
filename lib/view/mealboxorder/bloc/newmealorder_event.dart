import 'package:yumquick/view/mealboxorder/model/ordermealmodel.dart';

abstract class NewMealorderEvent {}

class FetchAllMealOrders extends NewMealorderEvent {}

class ConfirmMealOrderEvent extends NewMealorderEvent {
  final String orderId;
  final String date;
  final String time;

  ConfirmMealOrderEvent(this.orderId, this.date, this.time);
}

class DeliveredMealOrderEvent extends NewMealorderEvent {
  final String orderId;

  DeliveredMealOrderEvent(this.orderId);
}

class CancelMealOrderEvent extends NewMealorderEvent {
  final String orderId;
  final String cancelReason;

  CancelMealOrderEvent(this.orderId, this.cancelReason);
}

class NewMealBoxOrderEvent extends NewMealorderEvent {
  final MealBoxOrder order;
  NewMealBoxOrderEvent(this.order);
}