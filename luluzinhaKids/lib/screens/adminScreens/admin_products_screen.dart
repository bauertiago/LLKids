import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:luluzinhakids/extensions/context_extensions.dart';

import 'admin_edit_Product_screen.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final Map<String, bool> _expandes = {};

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("products").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data!.docs;

        if (products.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                "Nenhum produto encontrado. \nUse a aba 'Cadastrar' para adicionar novos itens.",
                style: context.texts.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (_, i) {
            final product = products[i];
            final stock = Map<String, int>.from(product["stock"]);
            final expanded = _expandes[product.id] ?? false;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),

              child: Padding(
                padding: const EdgeInsets.all(8),
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
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product["name"],
                                style: context.texts.titleMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 4),

                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _expandes[product.id] = !expanded;
                                  });
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      "Estoque",
                                      style: context.texts.bodyMedium,
                                    ),
                                    Icon(
                                      expanded
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      color: context.colors.secondary,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        PopupMenuButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: Colors.white,
                          elevation: 4,
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: context.colors.secondary.withValues(
                                alpha: .12,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.more_vert,
                              color: context.colors.secondary,
                            ),
                          ),

                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: "edit",
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: context.colors.secondary,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Editar",
                                    style: context.texts.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: "delete_item",
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.remove_circle,
                                    size: 18,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Remover tamanho",
                                    style: context.texts.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: "delete_product",
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Deletar produto",
                                    style: context.texts.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (op) async {
                            if (op == "edit") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AdminEditProductScreen(
                                    productId: product.id,
                                  ),
                                ),
                              );
                              return;
                            }

                            if (op == "delete_item") {
                              _showDeleteOneDialog(product.id, stock);
                              return;
                            }

                            if (op == "delete_product") {
                              final total = stock.values.fold(
                                0,
                                (sum, qtd) => sum + qtd,
                              );
                              if (total > 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: context.colors.secondary,
                                    content: Text(
                                      "O produto não pode ser deletado \npor conter unidades no estoque.",
                                    ),
                                  ),
                                );
                                return;
                              }

                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Deletar produto"),
                                  content: const Text(
                                    "Tem certeza? O estoque está zerado e isso apagará o produto definitivamente.",
                                  ),
                                  actions: [
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor:
                                            context.colors.secondary,
                                      ),
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text("Cancelar"),
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: context.colors.primary,
                                      ),
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text("Deletar"),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await FirebaseFirestore.instance
                                    .collection("products")
                                    .doc(product.id)
                                    .delete();
                              }
                            }
                          },
                        ),
                      ],
                    ),
                    if (expanded) ...[
                      const SizedBox(height: 12),
                      buildStockTable(context, stock),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildStockTable(BuildContext context, Map<String, int> stock) {
    final sizes = ["02", "04", "06", "08", "10", "12"];
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

  void _showDeleteOneDialog(String productId, Map<String, int> stock) async {
    final sizes = stock.keys.toList();

    String? selectedSize;

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Remover 1 unidade"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Escolha o tamanho para remover 1 unidade:"),
              const SizedBox(height: 12),

              DropdownButton<String>(
                borderRadius: BorderRadius.circular(12),
                hint: const Text("Selecione o tamanho"),
                value: selectedSize,
                isExpanded: true,
                items: sizes.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text("$e • ${stock[e]} unidades"),
                  );
                }).toList(),
                onChanged: (val) {
                  selectedSize = val;
                  Navigator.of(context).pop(); // fecha primeiro diálogo
                  _confirmDeleteOne(productId, val!, stock[val]!);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteOne(String productId, String size, int currentQty) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmar remoção"),
        content: Text("Deseja remover 1 unidade do tamanho $size?"),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: context.colors.secondary,
            ),
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancelar"),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: context.colors.primary,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Remover"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection("products")
          .doc(productId)
          .update({"stock.$size": currentQty - 1});
    }
  }
}
