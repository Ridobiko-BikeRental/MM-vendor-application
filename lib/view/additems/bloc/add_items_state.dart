part of 'add_items_bloc.dart';

abstract class AddItemsState extends Equatable {
  const AddItemsState();

  @override
  List<Object?> get props => [];
}

class AddItemsInitial extends AddItemsState {}

class AddItemsLoading extends AddItemsState {}

class AddItemsLoadSuccess extends AddItemsState {
  final List<Item> items;
  const AddItemsLoadSuccess(this.items);

  @override
  List<Object?> get props => [items];
}

class AddItemsOperationFailure extends AddItemsState {
  final String error;
  const AddItemsOperationFailure(this.error);

  @override
  List<Object?> get props => [error];
}
