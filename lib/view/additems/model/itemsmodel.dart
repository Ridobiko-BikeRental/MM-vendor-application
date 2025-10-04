class Item {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String cost; // keep as string

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.cost,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'].toString(), // Use 'id' instead of '_id'
      name: json['name'],
      description: json['description'],
      imageUrl: json['image_url'] ?? "", // Use 'image_url' instead of 'image'
      cost: json['cost'].toString(), // Convert cost to string safely
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'description': description,
    'image': imageUrl,
    'cost': cost,
  };
}
