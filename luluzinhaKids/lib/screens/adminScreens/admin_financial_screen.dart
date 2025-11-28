import 'package:flutter/material.dart';
import 'package:luluzinhakids/extensions/context_extensions.dart';

class AdminFinancialScreen extends StatelessWidget {
  const AdminFinancialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Financeiro", style: context.texts.labelLarge),
        backgroundColor: context.colors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Painel Financeiro Mensal", style: context.texts.titleLarge),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(blurRadius: 5, color: Colors.black12),
                ],
              ),
              child: Column(
                children: [
                  Text("Total de Vendas: R\$ 0,00"),
                  Text("Custo de estoque: R\$ 0,00"),
                  Text("Lucro: R\$ 0,00"),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Text(
              "📊 Gráficos, vendas mensais e controle financeiro em desenvolvimento...",
              style: context.texts.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
