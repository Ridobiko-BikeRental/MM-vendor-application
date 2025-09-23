import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class MealBoxEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ResetMealBoxEvent extends MealBoxEvent {}

class LoadCategoriesEvent extends MealBoxEvent {}

class TitleChanged extends MealBoxEvent {
  final String title;
  TitleChanged(this.title);
  @override
  List<Object?> get props => [title];
}

class DescriptionChanged extends MealBoxEvent {
  final String description;
  DescriptionChanged(this.description);
  @override
  List<Object?> get props => [description];
}

class MinQtyChanged extends MealBoxEvent {
  final String minQty;
  MinQtyChanged(this.minQty);
  @override
  List<Object?> get props => [minQty];
}

class PriceChanged extends MealBoxEvent {
  final String price;
  PriceChanged(this.price);
  @override
  List<Object?> get props => [price];
}

class DeliveryDateChanged extends MealBoxEvent {
  final String prepareOrderDays;
  DeliveryDateChanged(this.prepareOrderDays);
  @override
  List<Object?> get props => [prepareOrderDays];
}

class SampleAvailableChanged extends MealBoxEvent {
  final bool sampleAvailable;
  SampleAvailableChanged(this.sampleAvailable);
  @override
  List<Object?> get props => [sampleAvailable];
}

// Items passed as JSON string
class ItemsChanged extends MealBoxEvent {
  final String items;
  ItemsChanged(this.items);
  @override
  List<Object?> get props => [items];
}

class PackagingDetailsChanged extends MealBoxEvent {
  final String packagingDetails;
  PackagingDetailsChanged(this.packagingDetails);
  @override
  List<Object?> get props => [packagingDetails];
}

class PickBoxImageEvent extends MealBoxEvent {
  final ImageSource source;
  PickBoxImageEvent(this.source);
  @override
  List<Object?> get props => [source];
}

class PickActualImageEvent extends MealBoxEvent {
  final ImageSource source;
  PickActualImageEvent(this.source);
  @override
  List<Object?> get props => [source];
}

class UploadMealBoxEvent extends MealBoxEvent {}
// ...existing events

class UpdateMealBoxEvent extends MealBoxEvent {
  final String mealBoxId;
  UpdateMealBoxEvent(this.mealBoxId);

  @override
  List get props => [mealBoxId];
}

class PreloadBoxImageEvent extends MealBoxEvent {
  final String imageUrl;
  PreloadBoxImageEvent(this.imageUrl);
}

class PreloadActualImageEvent extends MealBoxEvent {
  final String imageUrl;
  PreloadActualImageEvent(this.imageUrl);
}
