import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luluzinhakids/extensions/context_extensions.dart';
import 'package:luluzinhakids/models/productModels/product_model.dart';
import 'package:luluzinhakids/screens/productsScreens/product_detail_screen.dart';
import 'package:luluzinhakids/services/favorites_service.dart';
import 'package:luluzinhakids/widgets/custom_header.dart';

import '../../widgets/search_with_suggestions.dart';

class FavoritesScreen extends StatefulWidget {
  static VoidCallback? refresh;

  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final favoritesService = FavoritesService();

  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomHeader(showBackButton: true, showLogo: true),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SearchWithSuggestions(
                onProductSelected: (product) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: product),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Text("Favoritos", style: context.texts.titleLarge),
            ),
            Expanded(
              child: StreamBuilder<List<Product>>(
                stream: favoritesService.watchFavorites(),
                builder: (_, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final favs = snapshot.data!;

                  if (favs.isEmpty) {
                    return _buildEmpty();
                  }
                  return _buildFavoritesGrid(favs);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Text(
        "Nenhum produto favorito ainda...",
        style: context.texts.bodyMedium,
      ),
    );
  }

  Widget _buildFavoritesGrid(List<Product> listFavorites) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        itemCount: listFavorites.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (_, index) {
          return _buildProductCard(listFavorites[index]);
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
            child: Image.network(
              item.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder:
                  (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image, size: 40),
                  ),
            ),
          ),

          Positioned(
            top: 8,
            right: 8,
            child: FutureBuilder<bool>(
              future: favoritesService.isFavorite(item.id),
              builder: (_, snap) {
                final fav = snap.data ?? false;

                return GestureDetector(
                  onTap: () async {
                    await favoritesService.toggleFavorite(item);
                    setState(() {}); // ← atualiza tela corretamente
                  },
                  child: Icon(
                    fav ? Icons.favorite : Icons.favorite_border,
                    color: fav ? Colors.red : Colors.white,
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
