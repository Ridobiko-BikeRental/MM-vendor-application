part of 'add_items_bloc.dart';

abstract class AddItemsEvent extends Equatable {
  const AddItemsEvent();

  @override
  List<Object?> get props => [];
}

class AddItemRequested extends AddItemsEvent {
  final String name;
  final String description;
  final String image; // local file path
  final String cost; // local file path

  const AddItemRequested({
    required this.name,
    required this.description,
    required this.image,
    required this.cost,
  });

  @override
  List<Object?> get props => [name, description, image, cost];
}

class LoadItemsRequested extends AddItemsEvent {}

class DeleteItemRequested extends AddItemsEvent {
  final String id;
  const DeleteItemRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class EditItemRequested extends AddItemsEvent {
  final String id;
  final String name;
  final String description;
  final String image;
  final String cost;

  const EditItemRequested({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.cost,
  });

  @override
  List<Object?> get props => [id, name, description, image, cost];
}
