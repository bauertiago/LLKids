class Customer {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;
  final String? imageUrl;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.imageUrl,
  });
}
