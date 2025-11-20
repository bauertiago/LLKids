import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luluzinhakids/extensions/context_extensions.dart';
import 'package:luluzinhakids/screens/main_screen.dart';
import 'package:luluzinhakids/screens/payment_screen.dart';
import 'package:luluzinhakids/widgets/custom_header.dart';

import '../models/productModels/product_model.dart';
import '../services/cart_service.dart';
import '../widgets/custom_input.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final cartService = CartService();

  bool isEditingAddress = false;

  final TextEditingController logradouroController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();
  final TextEditingController bairroController = TextEditingController();
  final TextEditingController estadoController = TextEditingController();
  final TextEditingController cidadeController = TextEditingController();
  final TextEditingController cepController = TextEditingController();

  final NumberFormat currency = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cart = cartService.getCart();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(showBackButton: true, showLogo: true),
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Carrinho", style: context.texts.titleLarge),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: cart.isEmpty ? _buildEmptyCart() : _buildCartList(cart),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          cart.isEmpty
              ? _buildBottomEmptyCartButton()
              : _buildBottomCartButtons(),
    );
  }

  Widget _buildEmptyCart() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.shopping_cart_outlined,
          size: 100,
          color: context.colors.secondary,
        ),
        const SizedBox(height: 16),
        Text("Seu carrinho está vazio.", style: context.texts.titleMedium),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Adicione produtos de sua preferência no seu carrinho.",
            style: context.texts.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildBottomEmptyCartButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const MainScreen(initialIndex: 0),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text("Encontrar produtos", style: context.texts.labelLarge),
        ),
      ),
    );
  }

  Widget _buildCartList(List<Product> cart) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ...cart.map((product) => _buildCartItem(product)).toList(),
          const SizedBox(height: 16),
          _buildTotal(),
          const SizedBox(height: 16),
          _buildAddressSection(),
        ],
      ),
    );
  }

  Widget _buildCartItem(Product product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  product.nameImage,
                  width: 150,
                  height: 170,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        cartService.removeFromCart(product);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.colors.secondary),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: context.colors.secondary,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        cartService.decreaseQuantity(product);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        border: Border.all(color: context.colors.secondary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.remove,
                        size: 20,
                        color: context.colors.secondary,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Text("${product.quantity}", style: context.texts.titleMedium),

                  const SizedBox(width: 12),

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        cartService.addQuantity(product);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.colors.secondary),
                      ),
                      child: Icon(
                        Icons.add,
                        size: 20,
                        color: context.colors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: context.texts.titleMedium),
                const SizedBox(height: 8),
                Text(
                  "Tamanho: ${product.selectedSize}",
                  style: context.texts.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  "Valor unitário: ${currency.format(product.salePrice)}",
                  style: context.texts.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotal() {
    final total = cartService.getTotal();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Total do Pedido: ${currency.format(total)}",
          style: context.texts.titleMedium,
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Endereço de entrega", style: context.texts.titleMedium),
          const SizedBox(height: 4),

          // Endereço atual fixo
          if (!isEditingAddress)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Rua Santa Rita, 105, Faxinal, Torres.",
                  style: context.texts.bodySmall,
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => isEditingAddress = true);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: context.colors.secondary,
                        width: 1,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Alterar Endereço de Entrega",
                      style: context.texts.titleMedium?.copyWith(
                        color: context.colors.secondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isEditingAddress ? _buildAddressForm() : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressForm() {
    return Column(
      key: const ValueKey("addressForm"),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

        CustomInput(
          controller: logradouroController,
          hintText: "Logradouro",
          prefixIcon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: CustomInput(
                controller: numeroController,
                hintText: "Número",
                prefixIcon: Icons.home_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomInput(
                controller: bairroController,
                hintText: "Bairro",
                prefixIcon: Icons.map_outlined,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: CustomInput(
                controller: estadoController,
                hintText: "Estado",
                prefixIcon: Icons.flag_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomInput(
                controller: cidadeController,
                hintText: "Cidade",
                prefixIcon: Icons.location_city_outlined,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        CustomInput(
          controller: cepController,
          hintText: "CEP",
          prefixIcon: Icons.local_post_office_outlined,
        ),

        const SizedBox(height: 16),

        ElevatedButton(
          onPressed: () {
            setState(() => isEditingAddress = false);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colors.primary,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text("Confirmar Alteração", style: context.texts.labelMedium),
        ),

        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildBottomCartButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PaymentScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Finalizar Compra",
                  style: context.texts.labelLarge,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MainScreen(initialIndex: 0),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: context.colors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Continuar Compra",
                  style: context.texts.labelLarge,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
