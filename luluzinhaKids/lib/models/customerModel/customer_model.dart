class Customer {
  final String id;
  final String name;
  final String email;
  final String? imageUrl;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    this.imageUrl,
  });

  factory Customer.fromMap(Map<String, dynamic> data, String id) {
    return Customer(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {"name": name, "email": email, "imageUrl": imageUrl};
  }

  Customer copyWith({String? name, String? email, String? imageUrl}) {
    return Customer(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
