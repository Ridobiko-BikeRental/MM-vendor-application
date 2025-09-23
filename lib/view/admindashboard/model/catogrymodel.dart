class SubCategoryModel {
  final String id;
  final String name;
  final String description;
  final int pricePerUnit;
  final String imageUrl;
  final int qunatity;
  final int discount;
  final String catId;
  final bool available;

  SubCategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerUnit,
    required this.imageUrl,
    required this.available,
    required this.qunatity,
    required this.catId,
    required this.discount,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      pricePerUnit: json['pricePerUnit'] ?? 0,
      discount: json['discount'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      qunatity: json['quantity'] ?? '',
      catId: json['category'] ?? '',
      available: json['available'] ?? false,
    );
  }
}

class CategoryModel {
  final String id;
  final String name;
  final String shortDescription;
  final int quantity;
  final String imageUrl;
  final List<SubCategoryModel> subCategories;

  CategoryModel({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.quantity,
    required this.imageUrl,
    required this.subCategories,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      shortDescription: json['shortDescription'] ?? '',
      quantity: json['quantity'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      subCategories: (json['subCategories'] as List<dynamic>? ?? [])
          .map((sc) => SubCategoryModel.fromJson(sc as Map<String, dynamic>))
          .toList(),
    );
  }
}
