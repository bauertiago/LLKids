import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luluzinhakids/extensions/context_extensions.dart';
import 'package:luluzinhakids/models/productModels/product_model.dart';
import 'package:luluzinhakids/services/favorites_service.dart';

import '../../widgets/custom_header.dart';
import '../../widgets/search_with_suggestions.dart';
import '../product_detail_screen.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String title;
  final List<Product> products;

  const CategoryProductsScreen({
    super.key,
    required this.title,
    required this.products,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  final _favoritesService = FavoritesService();

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
            Expanded(child: _buildGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        itemCount: widget.products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (_, index) {
          final item = widget.products[index];
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
          GestureDetector(
            onTap: () {},
            child: Image.asset(
              item.nameImage,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _favoritesService.toggleFavorite(item);
                });
              },
              child: Icon(
                _favoritesService.isFavorite(item)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color:
                    _favoritesService.isFavorite(item)
                        ? Colors.red
                        : Colors.white,
                size: 26,
              ),
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
