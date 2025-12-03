import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luluzinhakids/extensions/context_extensions.dart';

class AdminFinancialScreen extends StatefulWidget {
  const AdminFinancialScreen({super.key});

  @override
  State<AdminFinancialScreen> createState() => _AdminFinancialScreenState();
}

class _AdminFinancialScreenState extends State<AdminFinancialScreen> {
  DateTime selectedMonth = DateTime.now();
  bool loading = true;

  double totalVendasMes = 0;
  double totalCustoMes = 0;
  double lucroMes = 0;

  double totalEstoque = 0;
  double totalVendasHistorico = 0;
  double totalCustoHistorico = 0;
  double lucroGeral = 0;

  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  @override
  void initState() {
    super.initState();
    _loadFinancialData();
  }

  Future<void> _loadFinancialData() async {
    setState(() => loading = true);

    await Future.wait([_loadMensalData(), _loadGeralData()]);

    setState(() => loading = false);
  }

  Future<void> _loadMensalData() async {
    final start = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final end = DateTime(selectedMonth.year, selectedMonth.month + 1, 1);

    final snap =
        await FirebaseFirestore.instance
            .collection("orders")
            .where("createdAt", isGreaterThanOrEqualTo: start)
            .where("createdAt", isLessThan: end)
            .get();

    double vendas = 0;
    double custo = 0;

    for (var doc in snap.docs) {
      final data = doc.data();
      vendas += (data["total"] ?? 0).toDouble();

      final items = List<Map<String, dynamic>>.from(data["items"] ?? []);

      for (var item in items) {
        final quantity = item["quantity"] ?? 1;
        final costPrice = (item["costPrice"] ?? 0).toDouble();

        // custo total = custo * quantidade
        custo += costPrice * quantity;
      }
    }
    totalVendasMes = vendas;
    totalCustoMes = custo;
    lucroMes = vendas - custo;
  }

  Future<void> _loadGeralData() async {
    // 1) ESTOQUE TOTAL PARADO
    final products =
        await FirebaseFirestore.instance.collection("products").get();

    double estoque = 0;

    for (var doc in products.docs) {
      final p = doc.data();
      final cost = (p["costPrice"] ?? 0).toDouble();
      final stock = Map<String, dynamic>.from(p["stock"] ?? {});

      final totalQty = stock.values.fold<int>(0, (sum, q) => sum + (q as int));
      estoque += cost * totalQty;
    }

    totalEstoque = estoque;

    // 2) HISTÓRICO DE VENDAS
    final orders = await FirebaseFirestore.instance.collection("orders").get();

    double totalVendas = 0;
    double totalCusto = 0;

    for (var doc in orders.docs) {
      final data = doc.data();

      totalVendas += (data["total"] ?? 0).toDouble();

      final items = List<Map<String, dynamic>>.from(data["items"] ?? []);
      for (var item in items) {
        final qty = item["quantity"] ?? 1;
        final cost = (item["costPrice"] ?? 0).toDouble();
        totalCusto += qty * cost;
      }
    }

    totalVendasHistorico = totalVendas;
    totalCustoHistorico = totalCusto;
    lucroGeral = totalVendasHistorico - totalCustoHistorico;
  }

  void _selectMonth() async {
    final result = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      helpText: "Selecione o mês",
    );

    if (result != null) {
      selectedMonth = DateTime(result.year, result.month);
      _loadFinancialData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Center(
          child: CircularProgressIndicator(color: context.colors.secondary),
        )
        : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle(
                "Resumo Mensal",
                DateFormat.yMMMM("pt_BR").format(selectedMonth),
                onTap: _selectMonth,
              ),
              const SizedBox(height: 10),
              _buildCard([
                _infoItem("Total vendido", totalVendasMes),
                _infoItem("Custo vendido", totalCustoMes),
                _infoItem(
                  "Lucro do mês",
                  lucroMes,
                  highlight: true,
                  positive: lucroMes >= 0,
                ),
              ]),

              const SizedBox(height: 32),

              _buildSectionTitle("Resumo geral", "Histórico total"),
              const SizedBox(height: 10),
              _buildCard([
                _infoItem("Estoque parado", totalEstoque),
                _infoItem("Total vendido", totalVendasHistorico),
                _infoItem("Custo total", totalCustoHistorico),
                _infoItem(
                  "Lucro geral",
                  lucroGeral,
                  highlight: true,
                  positive: lucroGeral >= 0,
                ),
              ]),
            ],
          ),
        );
  }

  Widget _buildSectionTitle(
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: context.texts.titleLarge),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: context.texts.titleMedium!.copyWith(
                color: context.colors.primary,
              ),
            ),
          ],
        ),
        if (onTap != null)
          IconButton(
            icon: Icon(Icons.calendar_month, color: context.colors.secondary),
            onPressed: onTap,
          ),
      ],
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children:
            children
                .map(
                  (w) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: w,
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _infoItem(
    String title,
    double value, {
    bool highlight = false,
    bool positive = true,
  }) {
    final color =
        highlight
            ? (positive ? Colors.green : Colors.redAccent)
            : context.texts.bodyLarge?.color;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: context.texts.bodyLarge),
        Text(
          currencyFormat.format(value),
          style: context.texts.bodyLarge!.copyWith(
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }
}
