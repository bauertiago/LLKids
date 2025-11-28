import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:luluzinhakids/extensions/context_extensions.dart';

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Produtos Cadastrados", style: context.texts.labelLarge),
        backgroundColor: context.colors.primary,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("products").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (_, i) {
              final product = products[i];
              final stock = Map<String, int>.from(product["stock"]);

              return Card(
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product["imageUrl"],
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    product["name"],
                                    style: context.texts.titleMedium,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                PopupMenuButton(
                                  icon: const Icon(Icons.more_vert),
                                  itemBuilder:
                                      (_) => const [
                                        PopupMenuItem(
                                          value: "edit",
                                          child: Text("Editar"),
                                        ),
                                        PopupMenuItem(
                                          value: "delete",
                                          child: Text("Deletar"),
                                        ),
                                      ],
                                  onSelected: (op) async {
                                    if (op == "delete") {
                                      await FirebaseFirestore.instance
                                          .collection("products")
                                          .doc(product.id)
                                          .delete();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      buildStockTable(context, stock),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget buildStockTable(BuildContext context, Map<String, int> stock) {
    final sizes = [
      "02",
      "03",
      "04",
      "05",
      "06",
      "07",
      "08",
      "09",
      "10",
      "11",
      "12",
    ];
    final int total = stock.values.fold(0, (sum, qtd) => sum + qtd);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _cell(context, "Tam", header: true, width: 50),
              ...sizes.map((e) => _cell(context, e, header: true, width: 45)),
            ],
          ),

          Row(
            children: [
              _cell(context, "Qtd", header: true, width: 50),
              ...sizes.map(
                (s) => _cell(
                  context,
                  stock[s]?.toString() ?? "-",
                  bold: true,
                  width: 45,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              _cell(context, "Total", header: true, width: 70),
              _cell(context, "$total", bold: true, width: 60),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cell(
    BuildContext context,
    String text, {
    bool header = false,
    bool bold = false,
    double width = 40,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.secondary),
        color: header ? context.colors.secondary.withValues(alpha: .12) : null,
      ),
      child: Text(
        text,
        style: context.texts.bodySmall!.copyWith(
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
