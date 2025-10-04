class SubCategoryModel {
  final int id;
  // final int vendorId;
  final int categoryId;
  final String name;
  final String description;
  final int pricePerUnit;
  final String priceType;
  final String? imageUrl;
  final int quantity;
  final int minDeliveryDays;
  final int maxDeliveryDays;
  final double deliveryPrice;
  final int deliveryPriceEnabled;
  // final DateTime createdAt;

  SubCategoryModel({
    required this.id,
    // required this.vendorId,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.pricePerUnit,
    required this.priceType,
    this.imageUrl,
    required this.quantity,
    required this.minDeliveryDays,
    required this.maxDeliveryDays,
    required this.deliveryPrice,
    required this.deliveryPriceEnabled,
    // required this.createdAt,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['id'] ?? 0,
      // vendorId: json['vendor_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      pricePerUnit: int.tryParse(json['pricePerUnit'].toString()) ?? 0,
      priceType: json['priceType'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image_url'],
      quantity: int.tryParse(json['quantity'].toString()) ?? 0,
      minDeliveryDays: int.tryParse(json['minDeliveryDays'].toString()) ?? 0,
      maxDeliveryDays: int.tryParse(json['maxDeliveryDays'].toString()) ?? 0,
      deliveryPrice: double.tryParse(json['deliveryPrice'].toString()) ?? 0.0,
      deliveryPriceEnabled:
          int.tryParse(json['deliveryPriceEnabled'].toString()) ?? 0,
      // createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class CategoryModel {
  final int id;
  final String name;
  final int vendorId;
  final List<SubCategoryModel> subcategories;

  CategoryModel({
    required this.id,
    required this.name,
    required this.vendorId,
    required this.subcategories,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    List<dynamic> subcatsJson = json['subcategories'] ?? [];
    List<SubCategoryModel> subcats = subcatsJson
        .map((item) => SubCategoryModel.fromJson(item))
        .toList();

    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      vendorId: json['vendor_id'] ?? 0,
      subcategories: subcats,
    );
  }
}

class CategoryModelforaddproduct {
  final int id;
  final String name;
  // final String shortDescription;
  final int quantity;
  // final String imageUrl;
  final List<SubCategoryModel> subCategories;

  CategoryModelforaddproduct({
    required this.id,
    required this.name,
    // required this.shortDescription,
    required this.quantity,
    // required this.imageUrl,
    required this.subCategories,
  });

  factory CategoryModelforaddproduct.fromJson(Map<String, dynamic> json) {
    return CategoryModelforaddproduct(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      // shortDescription: json['shortDescription'] ?? '',
      quantity: json['minQty'] ?? 0,
      // imageUrl: json['imageUrl'] ?? '',
      subCategories: (json['subCategories'] as List<dynamic>? ?? [])
          .map((sc) => SubCategoryModel.fromJson(sc as Map<String, dynamic>))
          .toList(),
    );
  }
}
