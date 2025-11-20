import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luluzinhakids/extensions/context_extensions.dart';
import 'package:luluzinhakids/models/productModels/product_model.dart';
import 'package:luluzinhakids/screens/product_detail_screen.dart';
import 'package:luluzinhakids/services/favorites_service.dart';
import 'package:luluzinhakids/widgets/custom_header.dart';
import 'package:luluzinhakids/widgets/custom_search_bar.dart';

class FavoritesScreen extends StatefulWidget {
  static VoidCallback? refresh;

  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final favoritesService = FavoritesService();

  @override
  void initState() {
    super.initState();
    FavoritesScreen.refresh = () {
      if (mounted) setState(() {});
    };
  }

  @override
  void dispose() {
    FavoritesScreen.refresh = null;
    super.dispose();
  }

  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  @override
  Widget build(BuildContext context) {
    final favorites = favoritesService.getFavorites();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomHeader(showBackButton: true, showLogo: true),
            CustomSearchBar(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Text("Favoritos", style: context.texts.titleLarge),
            ),
            Expanded(
              child:
                  favorites.isEmpty
                      ? _buildEmptyState()
                      : _buildFavoritesGrid(favorites),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text("Nenhum favorito ainda...", style: context.texts.bodyMedium),
    );
  }

  Widget _buildFavoritesGrid(List<Product> favorites) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        itemCount: favorites.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (_, index) {
          final item = favorites[index];
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
                  favoritesService.toggleFavorite(item);
                });
              },
              child: Icon(
                favoritesService.isFavorite(item)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color:
                    favoritesService.isFavorite(item)
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
