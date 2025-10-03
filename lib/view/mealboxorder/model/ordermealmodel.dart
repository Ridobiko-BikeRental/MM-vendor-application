class MealBoxOrder {
  final String id;
  final String title;
  final String description;
  final String customerName;
  final String customerEmail;
  final String customerMobile;
  final bool isSampleOrder;
  final int quantity;
  final double price;
  final String packagingDetails;
  final String minPrepareOrderDays;
  final String maxPrepareOrderDays;
  final List<String> items;
  final String boxImage;
  final String actualImage;
  final String status;
  final String reason;
  final DateTime createdAt; // Add this field

  MealBoxOrder({
    required this.id,
    required this.title,
    required this.description,
    required this.customerName,
    required this.customerEmail,
    required this.customerMobile,
    required this.isSampleOrder,
    required this.quantity,
    required this.price,
    required this.packagingDetails,
    required this.minPrepareOrderDays,
    required this.maxPrepareOrderDays,
    required this.items,
    required this.boxImage,
    required this.actualImage,
    required this.status,
    required this.reason,
    required this.createdAt, // Initialize createdAt
  });

  factory MealBoxOrder.fromJson(Map<String, dynamic> json) {
    final mealBox = json['mealBox'] ?? {};

    return MealBoxOrder(
      id: json['_id'] ?? '',
      title: mealBox['title'] ?? '', // from nested mealBox
      description: mealBox['description'] ?? '',
      customerName: json['vendor']?['name'] ?? '',
      isSampleOrder: json['isSampleOrder'] ?? false,

      customerEmail: json['vendor']?['email'] ?? '',
      customerMobile: json['vendor']?['mobile'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (mealBox['price'] ?? 0).toDouble(),
      packagingDetails: mealBox['packagingDetails'] ?? '',
      minPrepareOrderDays: mealBox['minPrepareOrderDays'] ?? '',
      maxPrepareOrderDays: mealBox['maxPrepareOrderDays'] ?? '',
      items:
          (mealBox['items'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      boxImage: mealBox['boxImage'] ?? '',
      actualImage: mealBox['actualImage'] ?? '',
      status: json['status'] ?? '',
      reason: json['reason'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'title': title,
    'description': description,
    'customerName': customerName,
    'customerEmail': customerEmail,
    'customerMobile': customerMobile,
    'isSampleOrder': isSampleOrder,
    'quantity': quantity,
    'price': price,
    'packagingDetails': packagingDetails,
    'minPrepareOrderDays': minPrepareOrderDays,
    'maxPrepareOrderDays': maxPrepareOrderDays,
    'items': items,
    'boxImage': boxImage,
    'actualImage': actualImage,
    'status': status,
    'reason': reason,
    'createdAt': createdAt.toIso8601String(), // Serialize createdAt
  };
}
