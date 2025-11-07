import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:luluzinhakids/extensions/context_extensions.dart';
import 'package:luluzinhakids/screens/product_detail_screen.dart';
import 'package:luluzinhakids/widgets/custom_input.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _highlights = [
    {
      "titulo": "Conjunto Tricot",
      "preco": "R\$ 159,90",
      "imagem": "assets/images/conjunto_tricot.jpeg",
    },
    {
      "titulo": "Conjunto Moletom",
      "preco": "R\$ 179,90",
      "imagem": "assets/images/moletom_beje.jpeg",
    },
    {
      "titulo": "Blusa Canelada Listrada",
      "preco": "R\$ 79,90",
      "imagem": "assets/images/blusa_canelada_listras.jpeg",
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
              _buildHeader(),
              _buildSearchBar(),
              const SizedBox(height: 8),
              _buildCategory(),
              _buildHighlight(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  //Bloco Header
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/images/Logo.png', width: 80),
          Icon(Icons.shopping_cart_outlined),
        ],
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
            Image.asset(item["imagem"], fit: BoxFit.cover),
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
                  Text(item["titulo"], style: context.texts.labelLarge),
                  Text(item["preco"], style: context.texts.labelSmall),
                  Text("COMPRAR >", style: context.texts.labelMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      selectedItemColor: context.colors.primary,
      unselectedItemColor: context.colors.secondary,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: "Início",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: "Favoritos",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category_outlined),
          label: "Categorias",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_outlined),
          label: "Carrinho",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: "Perfil",
        ),
      ],
    );
  }
}
