import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luluzinhakids/extensions/context_extensions.dart';
import 'package:luluzinhakids/models/productModel/product_model.dart';
import 'package:luluzinhakids/services/favorites_service.dart';

import '../../services/product_service.dart';
import '../../widgets/custom_header.dart';
import '../../widgets/search_with_suggestions.dart';
import '../productsScreens/product_detail_screen.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String title;

  const CategoryProductsScreen({super.key, required this.title});

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  final _favoritesService = FavoritesService();
  final _productService = ProductService();

  Future<List<Product>>? productsFuture;

  @override
  void initState() {
    super.initState();
    productsFuture = _productService.getProductsByCategory(widget.title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomHeader(showBackButton: true, showLogo: true),
            SearchWithSuggestions(
              onProductSelected: (product) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(product: product),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(widget.title, style: context.texts.titleLarge),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: productsFuture,
                builder: (_, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final products = snapshot.data!;
                  if (products.isEmpty) {
                    return Center(
                      child: Text(
                        "Nenhum produto nessa categoria",
                        style: context.texts.bodyMedium,
                      ),
                    );
                  }

                  return _buildGrid(products);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(List<Product> products) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (_, index) {
          final item = products[index];
          return _buildProductCard(item);
        },
      ),
    );
  }

  Widget _buildProductCard(Product item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Image.network(
            item.imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey.shade200,
              alignment: Alignment.center,
              child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
            ),
          ),

          Positioned(
            top: 8,
            right: 8,
            child: FutureBuilder<bool>(
              future: _favoritesService.isFavorite(item.id),
              builder: (_, snap) {
                final fav = snap.data ?? false;
                return GestureDetector(
                  onTap: () async {
                    await _favoritesService.toggleFavorite(item);
                    setState(() {});
                  },
                  child: Icon(
                    fav ? Icons.favorite : Icons.favorite_border,
                    color: fav ? Colors.red : context.colors.secondary,
                    size: 26,
                  ),
                );
              },
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.name,
                    textAlign: TextAlign.center,
                    style: context.texts.labelLarge,
                  ),
                  Text(
                    textAlign: TextAlign.center,
                    currencyFormat.format(item.salePrice),
                    style: context.texts.labelSmall,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: item),
                        ),
                      );
                    },
                    child: Text(
                      "COMPRAR >",
                      textAlign: TextAlign.center,
                      style: context.texts.labelMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
