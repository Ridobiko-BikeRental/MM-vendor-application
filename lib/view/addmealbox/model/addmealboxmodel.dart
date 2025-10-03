class MealBox {
  final String? id;
  final String title;
  final String description;
  final int minQty;
  final double price;
  final String minPrepareOrderDays;
  final String maxPrepareOrderDays;
  final bool sampleAvailable;
  final List<Map<String, dynamic>> items;
  final List<String> subCategories;
  final String packagingDetails;
  final String categoryId;
  final String? boxImageUrl;
  final String? actualImageUrl;

  MealBox({
    this.id,
    required this.title,
    required this.description,
    required this.minQty,
    required this.price,
    required this.minPrepareOrderDays,
    required this.maxPrepareOrderDays,
    required this.sampleAvailable,
    required this.subCategories,
    required this.items,
    required this.packagingDetails,
    required this.categoryId,
    this.boxImageUrl,
    this.actualImageUrl,
  });

  factory MealBox.fromJson(Map<String, dynamic> json) {
    return MealBox(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      minQty: json['minQty'],
      price: (json['price'] as num).toDouble(),
      minPrepareOrderDays: json['minPrepareOrderDays'],
      maxPrepareOrderDays: json['maxPrepareOrderDays'],
      sampleAvailable: json['sampleAvailable'],
      items: (json['items'] as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      subCategories: json['subCategories'],
      packagingDetails: json['packagingDetails'],
      categoryId: json['category'],
      boxImageUrl: json['boxImage'],
      actualImageUrl: json['actualImage'],
    );
  }
}
