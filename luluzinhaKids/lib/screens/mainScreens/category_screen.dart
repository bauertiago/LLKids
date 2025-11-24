import 'package:flutter/material.dart';
import 'package:luluzinhakids/extensions/context_extensions.dart';
import 'package:luluzinhakids/screens/categoriesScreens/category_products_screen.dart';
import 'package:luluzinhakids/services/product_service.dart';
import 'package:luluzinhakids/widgets/custom_header.dart';

import '../../widgets/search_with_suggestions.dart';
import '../productsScreens/product_detail_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final Map<String, String> categoryImages = {
    "Conjuntos": "assets/images/categoria_conjuntos.jpeg",
    "Calças": "assets/images/categoria_calcas.jpg",
    "Camisetas": "assets/images/categoria_camisetas.jpg",
    "Shorts": "assets/images/categoria_shorts.jpg",
    "Vestidos": "assets/images/categoria_vestidos.jpg",
    "Praia": "assets/images/categoria_praia.jpg",
  };

  final _productService = ProductService();
  late List<String> allCategories;

  @override
  void initState() {
    super.initState();
    allCategories = _productService.getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text("Categorias", style: context.texts.titleLarge),
              ),
              const SizedBox(height: 24),
              _buildCategoryList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: allCategories.map((cat) => _buildCategoryCard(cat)).toList(),
      ),
    );
  }

  Widget _buildCategoryCard(String categoryName) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Color(0xFFFF7CCB), Color(0xFF88A0FF)],
          begin: Alignment.centerLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final products = _productService.getProductsByCategory(categoryName);
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => CategoryProductsScreen(
                    title: categoryName,
                    products: products,
                  ),
            ),
          );
          setState(() {});
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 4, top: 4, bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  categoryName,
                  style: context.texts.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  categoryImages[categoryName] ??
                      'assets/images/default_category.jpg',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
