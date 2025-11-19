import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luluzinhakids/extensions/context_extensions.dart';
import 'package:luluzinhakids/models/productModels/product_model.dart';
import 'package:luluzinhakids/screens/main_screen.dart';
import 'package:luluzinhakids/services/cart_service.dart';
import 'package:luluzinhakids/widgets/custom_header.dart';
import 'package:luluzinhakids/widgets/custom_input.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final int currentIndex;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.currentIndex = 0,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  String? selectedSize;

  double calcularParcelaComJuros(
    double valorTotal,
    int parcelas,
    double juros,
  ) {
    double i = juros / 100;
    double parcela =
        valorTotal * (i * pow(1 + i, parcelas)) / (pow(1 + i, parcelas) - 1);
    return parcela;
  }

  String generateInstallmentText(double valorTotal) {
    const double juros = 2.99;
    const double parcelaMinima = 30.0;

    // Lista das opções, da maior para a menor
    final opcoes = [
      {"parcelas": 5, "comJuros": true},
      {"parcelas": 4, "comJuros": true},
      {"parcelas": 3, "comJuros": false},
      {"parcelas": 2, "comJuros": false},
    ];

    for (var opcao in opcoes) {
      final parcelas = opcao["parcelas"] as int;
      final comJuros = opcao["comJuros"] as bool;

      double valorParcela =
          comJuros
              ? calcularParcelaComJuros(valorTotal, parcelas, juros)
              : valorTotal / parcelas;

      if (valorParcela >= parcelaMinima) {
        double total = comJuros ? valorParcela * parcelas : valorTotal;
        String tipo = comJuros ? "com juros" : "sem juros";
        return "${currencyFormat.format(total)} em até $parcelas x $tipo";
      }
    }

    // Se nenhuma opção for válida:
    return "${currencyFormat.format(valorTotal)} à vista";
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
              _buildSearchBar(),
              const SizedBox(height: 8),
              _buildImage(),
              const SizedBox(height: 8),
              _buildInfo(),
              const SizedBox(height: 12),
              _buildSizes(widget.product),
              const SizedBox(height: 12),
              _buildDescription(),
              const SizedBox(height: 16),
              _buildAddToCartButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CustomInput(
        hintText: "Buscar Produtos...",
        prefixIcon: Icons.search,
      ),
    );
  }

  Widget _buildImage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          widget.product.nameImage,
          height: 350,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildInfo() {
    final double price = widget.product.salePrice;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.product.name, style: context.texts.titleLarge),
          const SizedBox(height: 4),
          Text(
            "À vista ${currencyFormat.format(price)}",
            style: context.texts.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(generateInstallmentText(price), style: context.texts.bodySmall),
        ],
      ),
    );
  }

  Widget _buildSizes(Product product) {
    final List<String> allSizes = [
      "02",
      "03",
      "04",
      "05",
      "06",
      "07",
      "08",
      "09",
      "10",
      "11",
      "12",
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Tamanhos", style: context.texts.titleMedium),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2,
            ),
            itemCount: allSizes.length,
            itemBuilder: (_, i) {
              final size = allSizes[i];
              final bool isAvailable = product.availableSizes.contains(size);
              final bool isSelected = selectedSize == size;

              Color bgColor;
              Color textColor;

              if (isSelected) {
                bgColor = context.colors.secondary;
                textColor = Colors.white;
              } else if (isAvailable) {
                bgColor = const Color(0xFFDDE1F6);
                textColor = Colors.black87;
              } else {
                bgColor = Colors.grey.shade300;
                textColor = Colors.grey;
              }

              return GestureDetector(
                onTap:
                    isAvailable
                        ? () {
                          setState(() => selectedSize = size);
                        }
                        : null,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          isSelected
                              ? context.colors.secondary
                              : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    size,
                    style: context.texts.bodyMedium?.copyWith(color: textColor),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.product.description, style: context.texts.bodySmall),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colors.primary,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          if (selectedSize == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Por favor, selecione um tamanho antes de adicionar ao carrinho.",
                  style: context.texts.bodyMedium,
                ),
              ),
            );
            return;
          }

          final productToCart = Product(
            id: widget.product.id,
            name: widget.product.name,
            costPrice: widget.product.costPrice,
            salePrice: widget.product.salePrice,
            description: widget.product.description,
            category: widget.product.category,
            nameImage: widget.product.nameImage,
            availableSizes: widget.product.availableSizes,
            selectedSize: selectedSize,
            quantity: 1,
          );

          CartService().addToCart(productToCart);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MainScreen(initialIndex: 3),
            ),
          );
        },
        child: Text("Adicionar ao Carrinho", style: context.texts.labelLarge),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: widget.currentIndex,
      selectedItemColor: context.colors.primary,
      unselectedItemColor: context.colors.secondary,
      onTap: _onNavItemTapped,
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

  void _onNavItemTapped(int index) {
    if (index == widget.currentIndex) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) {
          return MainScreen(initialIndex: index);
        },
      ),
    );
  }
}
