import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luluzinhakids/extensions/context_extensions.dart';

class InstallmentSelector extends StatefulWidget {
  final double total;

  const InstallmentSelector({super.key, required this.total});

  @override
  State<InstallmentSelector> createState() => _InstallmentSelectorState();
}

class _InstallmentSelectorState extends State<InstallmentSelector> {
  final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  int? selected;

  double calcularParcelaComJuros(
    double valorTotal,
    int parcelas,
    double taxaJuros,
  ) {
    double i = taxaJuros / 100;
    double parcela =
        valorTotal * (i * pow(1 + i, parcelas)) / (pow(1 + i, parcelas) - 1);
    return parcela;
  }

  List<Map<String, dynamic>> gerarOpcoesParcelas(double total) {
    const double juros = 2.99;
    const double parcelaMinima = 30.0;

    final opcoes = [
      {"parcelas": 1, "comJuros": false},
      {"parcelas": 2, "comJuros": false},
      {"parcelas": 3, "comJuros": false},
      {"parcelas": 4, "comJuros": true},
      {"parcelas": 5, "comJuros": true},
    ];

    List<Map<String, dynamic>> opcoesValidas = [];
    for (var opcao in opcoes) {
      int p = opcao["parcelas"] as int;
      bool cj = opcao["comJuros"] as bool;

      double valorParcela =
          cj ? calcularParcelaComJuros(total, p, juros) : total / p;

      if (valorParcela >= parcelaMinima) {
        opcoesValidas.add({
          "parcelas": p,
          "valorParcela": valorParcela,
          "comJuros": cj,
        });
      }
    }
    return opcoesValidas;
  }

  @override
  Widget build(BuildContext context) {
    final opcoes = gerarOpcoesParcelas(widget.total);

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              "Selecione o número de parcelas",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: opcoes.length,
                itemBuilder: (_, i) {
                  final item = opcoes[i];
                  final parcelas = item["parcelas"];
                  final valor = item["valorParcela"];
                  final comJuros = item["comJuros"];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${parcelas}x de ${currency.format(valor)}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                comJuros ? "Com juros" : "Sem juros",
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      comJuros ? Colors.black54 : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Radio<int>(
                          value: parcelas,
                          groupValue: selected,
                          activeColor: context.colors.secondary,
                          onChanged: (value) {
                            setState(() => selected = value);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    disabledBackgroundColor: context.colors.primary.withValues(
                      alpha: 0.2,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed:
                      selected == null
                          ? null
                          : () {
                            final selectedOption = opcoes.firstWhere(
                              (op) => op["parcelas"] == selected,
                            );
                            Navigator.pop(context, {
                              "parcelas": selected,
                              "valorParcela": selectedOption["valorParcela"],
                              "comJuros": selectedOption["comJuros"],
                            });
                          },
                  child: Text("Confirmar", style: context.texts.labelLarge),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
