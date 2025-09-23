import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yumquick/view/additems/model/itemsmodel.dart';

part 'add_items_event.dart';
part 'add_items_state.dart';

class AddItemsBloc extends Bloc<AddItemsEvent, AddItemsState> {
  static const String baseUrl = 'https://mm-food-backend.onrender.com/api/item';

  AddItemsBloc() : super(AddItemsInitial()) {
    on<LoadItemsRequested>(_onLoadItems);
    on<AddItemRequested>(_onAddItem);
    on<DeleteItemRequested>(_onDeleteItem);
    on<EditItemRequested>(_onEditItem);
  }

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<void> _onLoadItems(
    LoadItemsRequested event,
    Emitter<AddItemsState> emit,
  ) async {
    emit(AddItemsLoading());
    try {
      final token = await _getAuthToken();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final itemsJson = data['items'] as List;
        final items = itemsJson.map((e) => Item.fromJson(e)).toList();
        emit(AddItemsLoadSuccess(items));
      } else {
        emit(AddItemsOperationFailure('Failed to load items'));
      }
    } catch (e) {
      emit(AddItemsOperationFailure(e.toString()));
    }
  }

  Future<void> _onAddItem(
    AddItemRequested event,
    Emitter<AddItemsState> emit,
  ) async {
    emit(AddItemsLoading());
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse(baseUrl);
      final request = http.MultipartRequest('POST', uri);

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields['name'] = event.name;
      request.fields['cost'] = event.cost.toString();
      request.fields['description'] = event.description;

      if (event.image.isNotEmpty && File(event.image).existsSync()) {
        request.files.add(
          await http.MultipartFile.fromPath('image', event.image),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (streamedResponse.statusCode == 200 ||
          streamedResponse.statusCode == 201) {
        add(LoadItemsRequested());
      } else {
        emit(AddItemsOperationFailure('Failed to add item: ${response.body}'));
      }
    } catch (e) {
      emit(AddItemsOperationFailure(e.toString()));
    }
  }

  Future<void> _onDeleteItem(
    DeleteItemRequested event,
    Emitter<AddItemsState> emit,
  ) async {
    emit(AddItemsLoading());
    try {
      final token = await _getAuthToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/${event.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        add(LoadItemsRequested());
      } else {
        emit(AddItemsOperationFailure('Failed to delete item'));
      }
    } catch (e) {
      emit(AddItemsOperationFailure(e.toString()));
    }
  }

  Future<void> _onEditItem(
    EditItemRequested event,
    Emitter<AddItemsState> emit,
  ) async {
    emit(AddItemsLoading());
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse('$baseUrl/${event.id}');
      final request = http.MultipartRequest('PUT', uri);

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields['name'] = event.name;
      request.fields['cost'] = event.cost.toString();
      request.fields['description'] = event.description;

      if (event.image.isNotEmpty && File(event.image).existsSync()) {
        request.files.add(
          await http.MultipartFile.fromPath('image', event.image),
        );
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (streamedResponse.statusCode == 200) {
        add(LoadItemsRequested());
      } else {
        emit(AddItemsOperationFailure('Failed to edit item: ${response.body}'));
      }
    } catch (e) {
      emit(AddItemsOperationFailure(e.toString()));
    }
  }
}
