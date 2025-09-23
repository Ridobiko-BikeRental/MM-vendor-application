class Order {
  final String id;
  final String orderId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final List<OrderItem> items;
  final String vendorId; // vendor comes as string ID
  final String status;
  final String prize;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? cancelReason;

  Order({
    required this.prize,
    required this.orderId,
    required this.id,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.items,
    required this.vendorId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.cancelReason,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? '',
      orderId: json['orderId'] ?? '',
      prize:
          json['pricePerUnit']?.toString() ??
          '', // convert number or string to string safely
      customerName: json['customerName'] ?? '',
      customerEmail: json['customerEmail'] ?? '',
      customerPhone: json['customerMobile'] ?? '',
      vendorId: json['vendor'] is String
          ? json['vendor'] as String
          : (json['vendor']?['_id'] ?? '')
                as String, // handle nested vendor object
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      cancelReason: json['cancelReason'],
      items: (json['items'] as List? ?? [])
          .map((e) => OrderItem.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'orderId': orderId,
    'pricePerUnit': prize,
    'customerName': customerName,
    'customerEmail': customerEmail,
    'customerMobile': customerPhone,
    'vendor': vendorId,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'cancelReason': cancelReason,
    'items': items.map((e) => e.toJson()).toList(),
  };
}

class OrderItem {
  final Category? category;
  final SubCategory? subCategory;
  final int quantity;
  final String id;

  OrderItem({
    this.category,
    this.subCategory,
    required this.quantity,
    required this.id,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
      subCategory: json['subCategory'] != null
          ? SubCategory.fromJson(json['subCategory'])
          : null,
      quantity: json['quantity'] ?? 0,
      id: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'category': category?.toJson(),
    'subCategory': subCategory?.toJson(),
    'quantity': quantity,
    '_id': id,
  };
}

class Category {
  final String id;
  final String name;
  final String shortDescription;
  final int quantity;
  final String imageUrl;
  final String vendorId;

  Category({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.quantity,
    required this.imageUrl,
    required this.vendorId,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      shortDescription: json['shortDescription'] ?? '',
      quantity: json['quantity'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      vendorId: json['vendor'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'shortDescription': shortDescription,
    'quantity': quantity,
    'imageUrl': imageUrl,
    'vendor': vendorId,
  };
}

class SubCategory {
  final String id;
  final String name;
  final String description;
  final String categoryId;
  final double pricePerUnit;
  final String imageUrl;

  SubCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.pricePerUnit,
    required this.imageUrl,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      categoryId: json['category'] ?? '',
      pricePerUnit: (json['pricePerUnit'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'description': description,
    'category': categoryId,
    'pricePerUnit': pricePerUnit,
    'imageUrl': imageUrl,
  };
}
