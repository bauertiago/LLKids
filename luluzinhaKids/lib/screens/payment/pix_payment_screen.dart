import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:luluzinhakids/extensions/context_extensions.dart';

import '../../widgets/custom_header.dart';

class PIXPaymentScreen extends StatelessWidget {
  final double total;
  final String pixCode =
      "00020126580014BR.GOV.BCB.PIX0136chavepixdemonstracao@teste.com5204000053039865406100.005802BR5920Luluzinha Kids Ltda6009SAO PAULO62070503***6304ABCD";

  const PIXPaymentScreen({super.key, required this.total});

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
              child: Text("Pagamento via PIX", style: context.texts.titleLarge),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Escaneie o QR Code abaixo para realizar o pagamento",
                      textAlign: TextAlign.center,
                      style: context.texts.bodyLarge,
                    ),

                    const SizedBox(height: 24),

                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text("QR CODE", style: context.texts.titleMedium),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      "Total a pagar: R\$ ${total.toStringAsFixed(2)}",
                      style: context.texts.titleMedium,
                    ),

                    const SizedBox(height: 24),

                    Text(
                      "Ou utilize o código abaixo:",
                      style: context.texts.bodyLarge,
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.all(12),
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
                      child: SelectableText(
                        pixCode,
                        textAlign: TextAlign.center,
                        style: context.texts.bodySmall,
                      ),
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Copiar Código PIX",
                          style: context.texts.labelLarge,
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: pixCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: context.colors.secondary,
                              content: Text("Código PIX copiado"),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.all(14),
                            ),
                          );
                        },
                      ),
                    ),
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
