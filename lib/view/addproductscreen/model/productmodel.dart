class ProductModel {
  final String name;
  final String shortDescription;
  final String pricePerUnit;
  final String imageUrl;
  final bool deliveryPriceEnabled;
  final String deliveryPrice;
  final String priceType;
  final String minDeliveryDays;
  final String maxDeliveryDays;
  final String? id;
  final String category;
  final String minQty;

  ProductModel({
    required this.name,
    required this.shortDescription,
    required this.pricePerUnit,
    required this.deliveryPriceEnabled,
    required this.deliveryPrice,
    required this.minDeliveryDays,
    required this.maxDeliveryDays,
    required this.imageUrl,
    required this.priceType,
    this.id,
    required this.category,
    required this.minQty,
  });

  ProductModel copyWith({
    String? name,
    String? shortDescription,
    String? pricePerUnit,
    bool? deliveryPriceEnabled,
    String? deliveryPrice,
    String? priceType,
    String? minDeliveryDays,
    String? maxDeliveryDays,
    String? imageUrl,
    String? id,
    String? category,
    String? minQty,
  }) {
    return ProductModel(
      name: name ?? this.name,
      shortDescription: shortDescription ?? this.shortDescription,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      priceType: priceType ?? this.priceType,
      deliveryPrice: deliveryPrice ?? this.deliveryPrice,
      deliveryPriceEnabled: deliveryPriceEnabled ?? this.deliveryPriceEnabled,
      minDeliveryDays: minDeliveryDays ?? this.minDeliveryDays,
      maxDeliveryDays: maxDeliveryDays ?? this.maxDeliveryDays,
      imageUrl: imageUrl ?? this.imageUrl,
      id: id ?? this.id,
      category: category ?? this.category,
      minQty: minQty ?? this.minQty,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "description": shortDescription,
      "pricePerUnit": pricePerUnit,
      "priceType": priceType,
      "deliveryPrice": deliveryPrice,
      "deliveryPriceEnabled": deliveryPriceEnabled,
      "maxDeliveryDays": maxDeliveryDays,
      "minDeliveryDays": minDeliveryDays,
      "imageUrl": imageUrl,
      "categoryId": category,
      "minQty": minQty,
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      shortDescription: json["description"] ?? "",
      pricePerUnit: json["pricePerUnit"]?.toString() ?? "",
      priceType: json["priceType"]?? "",
      deliveryPrice: json["deliveryPrice"]?? "",
      maxDeliveryDays: json["maxDeliveryDays"]?? "",
      deliveryPriceEnabled: json["deliveryPriceEnabled"]?? "",
      minDeliveryDays: json["minDeliveryDays"]?? "",
      imageUrl: json["image"] ?? "",
      category: json["categoryId"] ?? "",
      minQty: json["minQty"]?.toString() ?? "",
    );
  }
}
