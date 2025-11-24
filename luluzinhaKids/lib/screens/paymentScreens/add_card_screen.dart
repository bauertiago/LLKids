import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:luluzinhakids/extensions/context_extensions.dart';
import 'package:luluzinhakids/utils/card_number_formatter.dart';
import 'package:luluzinhakids/utils/cvv_formatter.dart';

import '../../utils/expiry_date_formatter.dart';
import '../../widgets/custom_header.dart';
import '../../widgets/custom_input.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _nameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expController = TextEditingController();
  final _cvvController = TextEditingController();

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
    if (!RegExp(r'^\d{2}/\d{4}$').hasMatch(exp)) valid = false;
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
                    Text("Nome", style: context.texts.bodyLarge),
                    const SizedBox(height: 4),
                    CustomInput(
                      label: "Nome como está no cartão",
                      controller: _nameController,
                      hintText: "Digite seu Nome",
                      requiredField: true,
                      hasError: nameError,
                      prefixIcon: Icons.person,
                    ),

                    const SizedBox(height: 16),
                    Text("Número do Cartão", style: context.texts.bodyLarge),
                    const SizedBox(height: 4),
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
                              Text(
                                "Data de vencimento",
                                style: context.texts.bodyLarge,
                              ),
                              const SizedBox(height: 4),
                              CustomInput(
                                label: "Data de Vencimento",
                                requiredField: true,
                                hasError: expError,
                                controller: _expController,
                                hintText: "MM / AAAA",
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
                              Text("CVV", style: context.texts.bodyLarge),
                              const SizedBox(height: 4),
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

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isValid ? _validateFieldsOnSubmit : null,
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
                          "Adicionar Cartão",
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

  void _validateFieldsOnSubmit() {
    final name = _nameController.text.trim();
    final cardNumber = _cardNumberController.text.trim().replaceAll(" ", "");
    final exp = _expController.text.trim();
    final cvv = _cvvController.text.trim();

    setState(() {
      nameError = name.isEmpty;
      cardNumberError = cardNumber.length != 16;
      expError = !RegExp(r'^(0[1-9]|1[0-2])\/\d{4}$').hasMatch(exp);
      cvvError = cvv.length != 3;
    });

    if (nameError || cardNumberError || expError || cvvError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha todos os campos corretamente.")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Cartão adicionado com sucesso!")),
    );
  }
}
