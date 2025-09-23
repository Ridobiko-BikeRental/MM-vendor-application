

import 'package:yumquick/view/admindashboard/model/catogrymodel.dart';

sealed class DashboardState {}

final class DashboardInitial extends DashboardState {}

final class DashboardLoading extends DashboardState {}

final class DashboardLoaded extends DashboardState {
  final List<CategoryModel> allCategories;
  final int selectedCategoryIndex;

  DashboardLoaded({
    required this.allCategories,
    required this.selectedCategoryIndex,
  });

  List<CategoryModel> get filteredCategories =>
      selectedCategoryIndex >= 0 && selectedCategoryIndex < allCategories.length
          ? [allCategories[selectedCategoryIndex]]
          : [];

  DashboardLoaded copyWith({
    List<CategoryModel>? allCategories,
    int? selectedCategoryIndex,
  }) {
    return DashboardLoaded(
      allCategories: allCategories ?? this.allCategories,
      selectedCategoryIndex: selectedCategoryIndex ?? this.selectedCategoryIndex,
    );
  }
}

final class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}
