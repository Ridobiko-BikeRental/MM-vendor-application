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
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      cost: json['cost'].toString(), // convert whatever to string safely
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'description': description,
    'imageUrl': imageUrl,
    'cost': cost,
  };
}
