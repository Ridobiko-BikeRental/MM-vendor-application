import 'package:image_picker/image_picker.dart';

sealed class ProductEvent {}

class PickImageEvent extends ProductEvent {
  final ImageSource source;
  PickImageEvent(this.source);
}

class NameChanged extends ProductEvent {
  final String name;
  NameChanged(this.name);
}

class DescriptionChanged extends ProductEvent {
  final String description;
  DescriptionChanged(this.description);
}

class QuantityChanged extends ProductEvent {
  final String quantity;
  QuantityChanged(this.quantity);
}

class PriceChanged extends ProductEvent {
  final String price;
  PriceChanged(this.price);
}
class DeliveryPriceEnabledChanged extends ProductEvent {
  final bool deliveryPriceEnabled;
  DeliveryPriceEnabledChanged(this.deliveryPriceEnabled);
}
class DeliveryPriceChanged extends ProductEvent {
  final String deliveryPrice;
  DeliveryPriceChanged(this.deliveryPrice);
}
class PriceTypeChanged extends ProductEvent {
  final String type;
  PriceTypeChanged(this.type);
}
class MaxDeliveryDaysChanged extends ProductEvent {
  final String maxDeliveryDays;
  MaxDeliveryDaysChanged(this.maxDeliveryDays);
}
class MinDeliveryDaysChanged extends ProductEvent {
  final String minDeliveryDays;
  MinDeliveryDaysChanged(this.minDeliveryDays);
}

class UploadProductEvent extends ProductEvent {
  final String categoryId;
  UploadProductEvent({required this.categoryId});
}

class ResetProductEvent extends ProductEvent {}
