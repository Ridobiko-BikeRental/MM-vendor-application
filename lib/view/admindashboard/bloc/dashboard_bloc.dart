import 'dart:convert';
import 'dart:developer' show log;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/catogrymodel.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardInitial()) {
    on<FetchCategoriesEvent>(_onFetchCategories);
    on<SelectCategoryEvent>(_onSelectCategory);
  }

  Future<void> _onFetchCategories(
    FetchCategoriesEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    final url = Uri.parse(
      'https://mm-food-backend.onrender.com/api/categories/my-categories-with-subcategories',
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken') ?? '';
      log(token);
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );
      log("asdfghjkl${response.statusCode.toString()}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final categoriesJson = data['categories'] as List<dynamic>? ?? [];
        final categories = categoriesJson
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
        emit(
          DashboardLoaded(
            allCategories: categories,
            selectedCategoryIndex: categories.isNotEmpty ? 0 : -1,
          ),
        );
      } else {
        emit(DashboardError('Failed to load categories'));
      }
    } catch (e) {
      emit(DashboardError('Error fetching categories: $e'));
    }
  }

  void _onSelectCategory(
    SelectCategoryEvent event,
    Emitter<DashboardState> emit,
  ) {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      emit(currentState.copyWith(selectedCategoryIndex: event.selectedIndex));
    }
  }
}
