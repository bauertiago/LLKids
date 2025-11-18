import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:luluzinhakids/extensions/context_extensions.dart';
import 'package:luluzinhakids/models/productModels/product_model.dart';
import 'package:luluzinhakids/models/productModels/product_mock.dart';
import 'package:luluzinhakids/screens/product_detail_screen.dart';
import 'package:luluzinhakids/widgets/custom_header.dart';
import 'package:luluzinhakids/widgets/custom_input.dart';
import 'package:intl/intl.dart';

import '../services/product_service.dart';
import 'categoriesScreens/category_products_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _productService = ProductService();
  late List<Product> _highlights;

  @override
  void initState() {
    super.initState();
    _highlights = _productService.getHighlights();
  }

  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomHeader(showBackButton: false, showLogo: true),
              _buildSearchBar(),
              const SizedBox(height: 8),
              _buildCategory(),
              _buildHighlight(),
            ],
          ),
        ),
      ),
    );
  }

  //Bloco Pesquizar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CustomInput(
        hintText: "Buscar Produtos...",
        prefixIcon: Icons.search,
      ),
    );
  }

  Widget _buildCategory() {
    final categorys = [
      "Conjuntos",
      "Calças",
      "Camisetas",
      "Shorts",
      "Vestidos",
      "Praia",
    ];

    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: categorys.map((c) => _buildCategoryCard(c)).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String texto) {
    return InkResponse(
      containedInkWell: true,
      borderRadius: BorderRadius.circular(50),
      onTap: () {
        final categoryName = texto;
        if (mockProduct.containsKey(categoryName)) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => CategoryProductsScreen(
                    title: categoryName,
                    products: mockProduct[categoryName]!,
                  ),
            ),
          );
        }
      },
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFFF7CCB), Color(0xFF88A0FF)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(texto, style: context.texts.labelLarge),
      ),
    );
  }

  Widget _buildHighlight() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text("Destaques", style: context.texts.titleLarge),
        ),
        CarouselSlider(
          options: CarouselOptions(
            height: 350,
            enlargeCenterPage: true,
            autoPlay: true,
            viewportFraction: 0.9,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: _highlights.map((item) => _buildProductCard(item)).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _highlights.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    _currentIndex == index
                        ? const Color(0xFFFF2BA9)
                        : Colors.grey.shade400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(Product item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(item.nameImage, fit: BoxFit.cover),
          Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(item.name, style: context.texts.labelLarge),
                Text(
                  currencyFormat.format(item.salePrice),
                  style: context.texts.labelSmall,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(product: item),
                      ),
                    );
                  },

                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("COMPRAR", style: context.texts.labelMedium),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
