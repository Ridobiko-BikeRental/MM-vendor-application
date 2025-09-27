import '../model/ordermodel.dart';

abstract class NeworderState {}

class NeworderInitial extends NeworderState {}

class NeworderLoading extends NeworderState {}

class NeworderLoaded extends NeworderState {
  final List<Order> orders;

  NeworderLoaded(this.orders);
}

class NeworderError extends NeworderState {
  final String error;

  NeworderError(this.error);
}

class ConfirmOrderLoading extends NeworderState {}


class ConfirmOrderSuccess extends NeworderState {}

class ConfirmOrderError extends NeworderState {
  final String error;

  ConfirmOrderError(this.error);
}
class DeliveredOrderLoading extends NeworderState {}
class DeliveredOrderSuccess extends NeworderState {}


class DeliveredOrderError extends NeworderState {
  final String error;

  DeliveredOrderError(this.error);
}

class CancelOrderLoading extends NeworderState {}

class CancelOrderSuccess extends NeworderState {}

class CancelOrderError extends NeworderState {
  final String error;

  CancelOrderError(this.error);
}
