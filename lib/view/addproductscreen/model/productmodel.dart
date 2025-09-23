class ProductModel {
  final String name;
  final String shortDescription;
  final String pricePerUnit;
  final String imageUrl;
  final String? id;
  final String category;
  final String quantity;

  ProductModel({
    required this.name,
    required this.shortDescription,
    required this.pricePerUnit,
    required this.imageUrl,
    this.id,
    required this.category,
    required this.quantity,
  });

  ProductModel copyWith({
    String? name,
    String? shortDescription,
    String? pricePerUnit,
    String? imageUrl,
    String? id,
    String? category,
    String? quantity,
  }) {
    return ProductModel(
      name: name ?? this.name,
      shortDescription: shortDescription ?? this.shortDescription,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      imageUrl: imageUrl ?? this.imageUrl,
      id: id ?? this.id,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "description": shortDescription,
      "pricePerUnit": pricePerUnit,
      "imageUrl": imageUrl,
      "categoryId": category,
      "quantity": quantity,
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      shortDescription: json["description"] ?? "",
      pricePerUnit: json["pricePerUnit"]?.toString() ?? "",
      imageUrl: json["image"] ?? "",
      category: json["categoryId"] ?? "",
      quantity: json["quantity"]?.toString() ?? "",
    );
  }
}
