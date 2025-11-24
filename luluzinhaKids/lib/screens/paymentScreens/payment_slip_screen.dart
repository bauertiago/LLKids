import 'package:flutter/material.dart';
import 'package:luluzinhakids/extensions/context_extensions.dart';

import '../../widgets/custom_header.dart';

class PaymentSlipScreen extends StatelessWidget {
  const PaymentSlipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const boletoCode = "34191.79001 01043.510047 91020.150008 9 99990000012345";

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomHeader(showBackButton: true, showLogo: true),

            Padding(
              padding: const EdgeInsets.only(left: 16, top: 16),
              child: Text(
                "Pagamento com Boleto",
                style: context.texts.titleLarge,
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Text(
                      "Use o código abaixo para realizar o pagamento do boleto:",
                      textAlign: TextAlign.center,
                      style: context.texts.bodyLarge,
                    ),

                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 80,
                            color: context.colors.secondary,
                          ),
                          const SizedBox(height: 16),
                          SelectableText(
                            boletoCode,
                            textAlign: TextAlign.center,
                            style: context.texts.bodyLarge,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Já paguei o boleto",
                          style: context.texts.labelLarge,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
