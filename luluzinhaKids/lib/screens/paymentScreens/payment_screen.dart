import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luluzinhakids/extensions/context_extensions.dart';
import 'package:luluzinhakids/screens/paymentScreens/payment_slip_screen.dart';
import 'package:luluzinhakids/screens/paymentScreens/pix_payment_screen.dart';
import 'package:luluzinhakids/services/cart_service.dart';
import 'package:luluzinhakids/services/payment_service.dart';
import 'package:luluzinhakids/widgets/custom_header.dart';

import '../../services/card_service.dart';
import '../../widgets/installment_selector.dart';
import '../mainScreens/main_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final cartService = CartService();
  final cardService = CardService();
  final paymentService = PaymentService();
  final _auth = FirebaseAuth.instance;

  Map<String, dynamic>? _savedCardData;
  bool _isLoadingCard = true;

  bool _saveCard = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCard();
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: context.colors.secondary),
    );
  }

  Future<void> _loadSavedCard() async {
    try {
      final cardData = await cardService.getSavedCard();
      setState(() {
        _savedCardData = cardData;
        _isLoadingCard = false;
      });
    } catch (e) {
      setState(() => _isLoadingCard = false);
    }
  }

  Future<void> _processPaymentWithSavedCard(double totalFinal) async {
    if (_savedCardData == null || _isLoadingCard) return;

    _showLoading("Processando pagamento com cartão salvo...");

    try {
      final rawPaymentMethodId = _savedCardData!['paymentMethodId'];
      if (rawPaymentMethodId == null || rawPaymentMethodId is! String) {
        throw Exception(
          "Dados do cartão salvo inválidos. Por favor, remova e salve o cartão novamente.",
        );
      }
      final paymentMethodId = rawPaymentMethodId;

      await paymentService.createAndConfirmWithSavedCard(
        paymentMethodId: paymentMethodId,
        total: totalFinal,
      );

      await cartService.clearCart();
      Navigator.pop(context);
      _showSuccessDialog();
    } catch (e) {
      Navigator.pop(context);
      _showMessage(
        "Falha no pagamento com cartão salvo. Tente novamente ou use um novo cartão. Detalhe: ${e.toString().split(':')[0]}",
      );
      print("Erro no pagamento com cartão salvo: $e");
    }
  }

  Future<void> _processNewCardPayment(
    double total,
    Map<String, dynamic> installment,
  ) async {
    final currency = NumberFormat.currency(locale: "pt_BR", symbol: "R\$");
    final parcelas = installment['parcelas'];
    final valorParcela = installment['valorParcela'];
    final comJuros = installment['comJuros'];
    final totalFinal = valorParcela * parcelas;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(
          "Confirmar Pagamento",
          style: context.texts.titleMedium,
          textAlign: TextAlign.center,
        ),
        content: Text(
          "Confirmar pagamento de ${currency.format(totalFinal)}\n"
          "em $parcelas x ${currency.format(valorParcela)}"
          "${comJuros ? " (com juros)" : " (sem juros)"}",
          textAlign: TextAlign.center,
          style: context.texts.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "Confirmar",
              style: TextStyle(color: context.colors.primary),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    _showLoading("Processando pagamento...");

    try {
      final intent = await paymentService.createPaymentIntent();
      final clientSecret = intent["clientSecret"];
      final paymentIntentId = intent["paymentIntentId"];
      final items = intent["items"];

      final userName =
          _auth.currentUser?.displayName ?? "Cliente Luluzinha Kids";

      await paymentService.presentPaymentSheet(
        clientSecret: clientSecret,
        customerName: userName,
      );

      final orderId = await paymentService.createOrder(
        items: items,
        total: totalFinal,
        paymentIntentId: paymentIntentId,
      );

      await paymentService.confirmOrderPayment(
        orderId: orderId,
        paymentMethod: "card",
        amount: totalFinal,
        transactionId: paymentIntentId,
        saveCard: _saveCard,
      );

      Navigator.pop(context);
      if (_saveCard) {
        await _loadSavedCard();
      }
      _showSuccessDialog();
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: context.colors.secondary,
          content: Text(
            "Erro ao processar pagamento: ${e.toString()}",
            style: context.texts.labelLarge,
          ),
        ),
      );
      print("Erro no pagamento: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
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
    if (_isLoadingCard) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _divider(),

        _buildPaymentOption(
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

        if (_savedCardData != null)
          ..._buildSavedCardOptions(total)
        else
          _buildNewCardOption(total),

        _divider(),

        _buildPaymentOption(
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

  List<Widget> _buildSavedCardOptions(double total) {
    final savedCard = _savedCardData!;

    return [
      _buildPaymentOption(
        icon: Icons.credit_card,
        title: "Pagar com Cartão Salvo (**** ${savedCard["last4"]})",
        onTap: () async {
          final installment = await _showInstallments(total);
          if (installment != null) {
            final totalFinal =
                installment['valorParcela'] * installment['parcelas'];
            _processPaymentWithSavedCard(totalFinal);
          }
        },
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () async {
            _showLoading("Removendo cartão...");
            await cardService.removeCard();
            await _loadSavedCard();
            Navigator.pop(context);
          },
        ),
      ),
      _divider(),

      _buildNewCardOption(total),
    ];
  }

  Widget _buildNewCardOption(double total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPaymentOption(
          icon: Icons.credit_card,
          title: "Pagar com Cartão (novo)",
          onTap: () async {
            final installment = await _showInstallments(total);
            if (installment != null) {
              _processNewCardPayment(total, installment);
            }
          },
        ),

        GestureDetector(
          onTap: () {
            setState(() => _saveCard = !_saveCard);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: _saveCard,
                  onChanged: (v) {
                    setState(() => _saveCard = v!);
                  },
                  checkColor: Colors.white,
                  activeColor: context.colors.primary,
                  side: WidgetStateBorderSide.resolveWith((
                    Set<WidgetState> states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return null;
                    }
                    return BorderSide(
                      color: context.colors.secondary,
                      width: 2,
                    );
                  }),
                ),
                Flexible(
                  child: Text(
                    "Salvar este cartão para futuras compras",
                    style: context.texts.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
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

  Future<Map<String, dynamic>?> _showInstallments(double total) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return FractionallySizedBox(
          heightFactor: 0.65,
          child: InstallmentSelector(total: total),
        );
      },
    );
  }

  void _showLoading(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: context.colors.primary),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
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
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                "Seu pagamento foi processado com sucesso.\nObrigado por comprar com a Luluzinha Kids!",
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
                      (_) => false,
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
