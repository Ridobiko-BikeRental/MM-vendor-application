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

class UploadProductEvent extends ProductEvent {
  final String categoryId;
  UploadProductEvent({required this.categoryId});
}

class ResetProductEvent extends ProductEvent {}
