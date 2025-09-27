import '../model/ordermealmodel.dart';

abstract class NewMealorderState {}

class NewMealorderInitial extends NewMealorderState {}

class NewMealorderLoading extends NewMealorderState {}

class NewMealorderLoaded extends NewMealorderState {
  final List<MealBoxOrder> mealOrders;

  NewMealorderLoaded(this.mealOrders);
}

class NewMealorderError extends NewMealorderState {
  final String error;

  NewMealorderError(this.error);
}

class ConfirmMealOrderLoading extends NewMealorderState {}

class ConfirmMealOrderSuccess extends NewMealorderState {}

class ConfirmMealOrderError extends NewMealorderState {
  final String error;

  ConfirmMealOrderError(this.error);
}

class DeliveredMealOrderLoading extends NewMealorderState {}

class DeliveredConfirmMealOrderSuccess extends NewMealorderState {}

class DeliveredConfirmMealOrderError extends NewMealorderState {
  final String error;

  DeliveredConfirmMealOrderError(this.error);
}

class CancelMealOrderLoading extends NewMealorderState {}

class CancelMealOrderSuccess extends NewMealorderState {}

class CancelMealOrderError extends NewMealorderState {
  final String error;

  CancelMealOrderError(this.error);
}


class NewMealBoxOrderReceived extends NewMealorderState {
  final MealBoxOrder mealOrders;
  NewMealBoxOrderReceived(this.mealOrders);
}