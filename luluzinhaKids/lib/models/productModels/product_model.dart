class Product {
  final int id;
  final String name;
  final double costPrice;
  final double salePrice;
  final String description;
  final String category;
  final String nameImage;
  int quantity;
  String? selectedSize;
  final List<String> availableSizes;

  Product({
    required this.id,
    required this.name,
    required this.costPrice,
    required this.salePrice,
    required this.description,
    required this.category,
    required this.nameImage,
    this.quantity = 1,
    this.selectedSize,
    this.availableSizes = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;

      if (value is num) {
        return value.toDouble();
      }

      if (value is String) {
        return double.tryParse(value.replaceAll(",", ".")) ?? 0.0;
      }

      return 0.0;
    }

    return Product(
      id: json["id"] ?? 0,
      name: json["name"] ?? "Nome não informado",
      costPrice: parseDouble(json["costPrice"]),
      salePrice: parseDouble(json["salePrice"]),
      description: json["description"] ?? "",
      category: json["category"] ?? "",
      nameImage: json["nameImage"] ?? "",
      availableSizes:
          json["availableSizes"] != null
              ? List<String>.from(json["availableSizes"])
              : [],
      selectedSize: json["selectedSize"],
    );
  }
}
