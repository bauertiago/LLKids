import 'package:luluzinhakids/models/product.dart';
import 'package:luluzinhakids/models/product_mock.dart';

class ProductService {
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
}
