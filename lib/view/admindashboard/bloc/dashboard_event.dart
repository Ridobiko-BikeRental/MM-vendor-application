sealed class DashboardEvent {}

final class FetchCategoriesEvent extends DashboardEvent {}

final class SelectCategoryEvent extends DashboardEvent {
  final int selectedIndex;
  SelectCategoryEvent(this.selectedIndex);
}
