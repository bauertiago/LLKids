import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:luluzinhakids/extensions/context_extensions.dart';
import 'package:luluzinhakids/screens/paymentScreens/payment_screen.dart';
import 'package:luluzinhakids/services/card_service.dart';
import 'package:luluzinhakids/utils/card_number_formatter.dart';
import 'package:luluzinhakids/utils/cvv_formatter.dart';

import '../../utils/expiry_date_formatter.dart';
import '../../widgets/custom_header.dart';
import '../../widgets/custom_input.dart';

class AddCardScreen extends StatefulWidget {
  final bool saveOption;

  const AddCardScreen({super.key, this.saveOption = true});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _nameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expController = TextEditingController();
  final _cvvController = TextEditingController();
  final cardService = CardService();

  bool saveCard = false;
  bool isValid = false;

  bool nameError = false;
  bool cardNumberError = false;
  bool expError = false;
  bool cvvError = false;

  @override
  void initState() {
    super.initState();

    _nameController.addListener(_validateForm);
    _cardNumberController.addListener(_validateForm);
    _expController.addListener(_validateForm);
    _cvvController.addListener(_validateForm);
  }

  void _validateForm() {
    final name = _nameController.text.trim();
    final cardNumber = _cardNumberController.text.trim().replaceAll(" ", "");
    final exp = _expController.text.trim();
    final cvv = _cvvController.text.trim();

    bool valid = true;

    if (name.isEmpty) valid = false;
    if (cardNumber.length != 16) valid = false;
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(exp)) valid = false;
    if (cvv.length != 3) valid = false;

    setState(() {
      isValid = valid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomHeader(showBackButton: true, showLogo: true),

            Padding(
              padding: const EdgeInsets.only(left: 16, top: 16),
              child: Text("Pagamento", style: context.texts.titleLarge),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomInput(
                      label: "Nome como está no cartão",
                      controller: _nameController,
                      hintText: "Digite seu Nome",
                      requiredField: true,
                      hasError: nameError,
                      prefixIcon: Icons.person,
                    ),

                    const SizedBox(height: 16),
                    CustomInput(
                      label: "Número do Cartão",
                      requiredField: true,
                      hasError: cardNumberError,
                      controller: _cardNumberController,
                      hintText: "0000 0000 0000 0000",
                      prefixIcon: Icons.credit_card,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CardNumberFormatter(),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomInput(
                                label: "Data de Vencimento",
                                requiredField: true,
                                hasError: expError,
                                controller: _expController,
                                hintText: "MM/AA",
                                prefixIcon: Icons.date_range,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  ExpiryDateFormatter(),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 110,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomInput(
                                label: "CVV",
                                requiredField: true,
                                hasError: cvvError,
                                controller: _cvvController,
                                hintText: "XXX",
                                prefixIcon: Icons.lock,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  CVVFormatter(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    if (widget.saveOption)
                      CheckboxListTile(
                        value: saveCard,
                        title: Text(
                          "Salvar cartão para compras futuras?",
                          style: context.texts.bodyMedium,
                        ),
                        onChanged: (v) => setState(() => saveCard = v!),
                      ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isValid ? _finishProcess : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.primary,
                          disabledBackgroundColor: context.colors.primary
                              .withValues(alpha: 0.2),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        child: Text(
                          "Continuar",
                          style: context.texts.labelLarge,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finishProcess() async {
    final name = _nameController.text.trim();
    final cardNumber = _cardNumberController.text.replaceAll(" ", "");

    if (saveCard) {
      await cardService.saveCard(number: cardNumber, holder: name);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: context.colors.secondary,
          content: Text("Cartão salvo com sucesso!"),
        ),
      );
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PaymentScreen()),
    );
  }
}
