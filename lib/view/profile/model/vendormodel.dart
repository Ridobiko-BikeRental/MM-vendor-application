class UserModel {
  final String name;
  final String vendId;
  final String email;
  final String mobile;
  final String image;
  final String city;
  final String state;
  final String address;

  UserModel({
    required this.name,
    required this.vendId,
    required this.email,
    required this.mobile,
    required this.image,
    required this.city,
    required this.state,
    required this.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name']?.replaceAll('"', '') ?? "",
      email: json['email'] ?? "",
      vendId: json['id'] ?? "",
      mobile: json['mobile']?.replaceAll('"', '') ?? "",
      image: json['image'] ?? "",
      city: json['city']?.replaceAll('"', '') ?? "",
      state: json['state']?.replaceAll('"', '') ?? "",
      address: json['address']?.replaceAll('"', '') ?? "",
    );
  }

  UserModel copyWith({
    String? name,
    String? vendId,
    String? email,
    String? mobile,
    String? image,
    String? city,
    String? state,
    String? address,
  }) {
    return UserModel(
      vendId: vendId??this.vendId,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      image: image ?? this.image,
      city: city ?? this.city,
      state: state ?? this.state,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "id": vendId,
      "email": email,
      "mobile": mobile,
      "image": image,
      "city": city,
      "state": state,
      "address": address,
    };
  }
}
