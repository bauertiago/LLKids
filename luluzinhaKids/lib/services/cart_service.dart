import '../models/productModels/product_model.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;

  CartService._internal();

  final List<Product> _cart = [];

  List<Product> getCart() => _cart;

  void addToCart(Product product) {
    final index = _cart.indexWhere(
      (p) => p.id == product.id && p.selectedSize == product.selectedSize,
    );

    if (index != -1) {
      _cart[index].quantity++;
    } else {
      _cart.add(product);
    }
  }

  void removeFromCart(Product product) {
    _cart.removeWhere(
      (p) => p.id == product.id && p.selectedSize == product.selectedSize,
    );
  }

  void addQuantity(Product product) {
    final index = _cart.indexWhere(
      (p) => p.id == product.id && p.selectedSize == product.selectedSize,
    );

    if (index != -1) {
      _cart[index].quantity++;
    }
  }

  void decreaseQuantity(Product product) {
    final index = _cart.indexWhere(
      (p) => p.id == product.id && p.selectedSize == product.selectedSize,
    );

    if (index != -1) {
      if (_cart[index].quantity > 1) {
        _cart[index].quantity--;
      } else {
        // se quantidade chegar a zero, remove o item
        _cart.removeAt(index);
      }
    }
  }

  double getTotal() {
    return _cart.fold(
      0.0,
      (sum, item) => sum + (item.salePrice * item.quantity),
    );
  }

  void clearCart() {
    _cart.clear();
  }
}
