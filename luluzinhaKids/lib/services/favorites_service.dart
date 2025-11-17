import 'package:luluzinhakids/models/product.dart';

class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;

  FavoritesService._internal();

  final List<Product> _favorites = [];

  List<Product> getFavorites() => _favorites;

  bool isFavorite(Product product) {
    return _favorites.any((p) => p.id == product.id);
  }

  void toggleFavorite(Product product) {
    if (isFavorite(product)) {
      _favorites.removeWhere((p) => p.id == product.id);
    } else {
      _favorites.add(product);
    }
  }
}
