import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:luluzinhakids/extensions/context_extensions.dart';
import 'package:luluzinhakids/screens/product_detail_screen.dart';
import 'package:luluzinhakids/widgets/custom_header.dart';
import 'package:luluzinhakids/widgets/custom_input.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );
  final List<Map<String, dynamic>> _highlights = [
    {
      "title": "Conjunto Tricot",
      "price": 159.90,
      "image": "assets/images/conjunto_tricot.jpeg",
    },
    {
      "title": "Conjunto Moletom",
      "price": 179.90,
      "image": "assets/images/moletom_beje.jpeg",
    },
    {
      "title": "Blusa Canelada Listrada",
      "price": 79.90,
      "image": "assets/images/blusa_canelada_listras.jpeg",
    },
  ];
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
      "Bermudas",
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
      onTap: () {},
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

  Widget _buildProductCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: item)),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(item["image"], fit: BoxFit.cover),
            Container(
              alignment: Alignment.bottomLeft,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item["title"], style: context.texts.labelLarge),
                  Text(
                    currencyFormat.format(item["price"]),
                    style: context.texts.labelSmall,
                  ),
                  Text("COMPRAR >", style: context.texts.labelMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
