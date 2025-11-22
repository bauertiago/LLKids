import 'package:luluzinhakids/models/productModels/product_model.dart';
import 'package:luluzinhakids/models/productModels/product_mock.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  List<Product> getHighlights() {
    final allProducts = mockProduct.values.expand((p) => p).toList();

    allProducts.sort((a, b) => a.salePrice.compareTo(b.salePrice));

    return allProducts.take(3).toList();
  }

  List<Product> getProductsByCategory(String categoryName) {
    return mockProduct[categoryName] ?? [];
  }

  List<String> getCategories() {
    return mockProduct.keys.toList();
  }

  List<Product> searchProducts(String query) {
    final results =
        mockProduct.values
            .expand((list) => list)
            .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
    return results;
  }
}
