import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luluzinhakids/extensions/context_extensions.dart';
import 'package:luluzinhakids/screens/paymentScreens/payment_slip_screen.dart';
import 'package:luluzinhakids/screens/paymentScreens/pix_payment_screen.dart';
import 'package:luluzinhakids/services/cart_service.dart';
import 'package:luluzinhakids/widgets/custom_header.dart';

import '../../models/productModels/product_model.dart';
import '../../widgets/installment_selector.dart';
import 'add_card_screen.dart';
import '../mainScreens/main_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final cartService = CartService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Product>>(
      stream: cartService.watchCart(),
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final cart = snapshot.data!;
        final total = cartService.getTotal(cart);

        return Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomHeader(showBackButton: true, showLogo: true),
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 20),
                  child: Text(
                    "Formas de Pagamento",
                    style: context.texts.titleLarge,
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(child: _buildSections(total)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSections(double total) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _divider(),

        _buildPaymentOption(
          context,
          icon: Icons.pix,
          title: "PIX",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PIXPaymentScreen(total: total)),
            );
          },
        ),

        _divider(),

        _buildPaymentOption(
          context,
          icon: Icons.credit_card,
          title: "**************4321",
          trailing: IconButton(
            onPressed: () {},
            icon: Icon(Icons.delete, color: context.colors.secondary),
          ),
          onTap: () async {
            final result = await _showInstallmentSheet(total);
            if (result != null) {
              _showConfirmPaymentDialog(
                total,
                result["parcelas"],
                result["valorParcela"],
                result["comJuros"],
              );
            }
          },
        ),

        _divider(),

        _buildPaymentOption(
          context,
          icon: Icons.add_card,
          title: "Adicionar novo cartão",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddCardScreen()),
            );
          },
        ),

        _divider(),

        _buildPaymentOption(
          context,
          icon: Icons.receipt_long,
          title: "Boleto Bancário",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PaymentSlipScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPaymentOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, size: 32, color: context.colors.secondary),
        title: Text(title, style: context.texts.bodyLarge),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 0),
      child: Divider(),
    );
  }

  Future<Map<String, dynamic>?> _showInstallmentSheet(double totalAmount) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return FractionallySizedBox(
          heightFactor: 0.65,
          child: InstallmentSelector(total: totalAmount),
        );
      },
    );
  }

  void _showConfirmPaymentDialog(
    double total,
    int parcelas,
    double valorParcela,
    bool comJuros,
  ) {
    final currency = NumberFormat.currency(locale: "pt_BR", symbol: "R\$");
    final totalFinal = valorParcela * parcelas;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset("assets/images/Logo.png", height: 50),
                  const SizedBox(height: 16),

                  Text("Confirmar Pagamento", style: context.texts.titleMedium),
                  const SizedBox(height: 12),

                  Text(
                    "Confirmar compra no valor de ${currency.format(totalFinal)}\n"
                    "parcelada em $parcelas vezes de ${currency.format(valorParcela)}?"
                    "${comJuros ? " (com juros)" : " (sem juros)"}",
                    textAlign: TextAlign.center,
                    style: context.texts.bodyMedium,
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showSuccessDialog();
                        cartService.clearCart();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text("Confirmar", style: context.texts.labelLarge),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text("Cancelar", style: context.texts.labelLarge),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset("assets/images/Logo.png", height: 80),
                  const SizedBox(height: 16),

                  Text(
                    "Compra realizada com sucesso!",
                    style: context.texts.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  Text(
                    "Seu pagamento foi processado com sucesso.\n"
                    "Obrigado por comprar com a Luluzinha Kids!",
                    textAlign: TextAlign.center,
                    style: context.texts.bodyMedium,
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Voltar ao Início",
                        style: context.texts.labelLarge,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MainScreen(initialIndex: 0),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
