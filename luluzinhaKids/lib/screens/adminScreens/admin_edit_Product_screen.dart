import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:luluzinhakids/extensions/context_extensions.dart';

import '../../widgets/custom_input.dart';

class AdminEditProductScreen extends StatefulWidget {
  final String productId;

  const AdminEditProductScreen({super.key, required this.productId});

  @override
  State<AdminEditProductScreen> createState() => _AdminEditProductScreenState();
}

class _AdminEditProductScreenState extends State<AdminEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final salePriceCtrl = TextEditingController();
  final imageCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();
  Map<String, int> stock = {};

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    final doc =
        await FirebaseFirestore.instance
            .collection("products")
            .doc(widget.productId)
            .get();

    final data = doc.data()!;
    nameCtrl.text = data["name"];
    priceCtrl.text = data["costPrice"].toString();
    salePriceCtrl.text = data["salePrice"].toString();
    imageCtrl.text = data["imageUrl"];
    categoryCtrl.text = data["category"];
    stock = Map<String, int>.from(data["stock"]);

    setState(() => loading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    await FirebaseFirestore.instance
        .collection("products")
        .doc(widget.productId)
        .update({
          "name": nameCtrl.text,
          "costPrice": double.tryParse(priceCtrl.text) ?? 0,
          "salePrice": double.tryParse(salePriceCtrl.text) ?? 0,
          "imageUrl": imageCtrl.text,
          "category": categoryCtrl.text,
          "stock": stock,
        });

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Produto"),
        backgroundColor: context.colors.primary,
      ),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),

                    Text(
                      "Editar Produto",
                      style: context.texts.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "Atualize as informações e salve",
                      style: context.texts.bodyMedium,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomInput(
                            label: "Nome",
                            hintText: "Digite o nome do produto",
                            prefixIcon: Icons.label_outline,
                            controller: nameCtrl,
                          ),

                          const SizedBox(height: 8),

                          CustomInput(
                            label: "Preço de custo",
                            hintText: "Ex: 59.90",
                            prefixIcon: Icons.attach_money,
                            keyboardType: TextInputType.number,
                            controller: priceCtrl,
                          ),

                          const SizedBox(height: 8),

                          CustomInput(
                            label: "Preço de venda",
                            hintText: "Ex: 49.90",
                            prefixIcon: Icons.local_offer_outlined,
                            keyboardType: TextInputType.number,
                            controller: salePriceCtrl,
                          ),

                          const SizedBox(height: 8),

                          CustomInput(
                            label: "Imagem",
                            hintText: "URL da imagem",
                            prefixIcon: Icons.photo_outlined,
                            controller: imageCtrl,
                          ),

                          const SizedBox(height: 8),

                          CustomInput(
                            label: "Categoria",
                            hintText: "Ex: Moda Infantil",
                            prefixIcon: Icons.category_outlined,
                            controller: categoryCtrl,
                          ),

                          const SizedBox(height: 16),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Estoque",
                              style: context.texts.titleMedium,
                            ),
                          ),

                          const SizedBox(height: 8),

                          ...stock.keys.map((size) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: stockCounter(
                                size: size,
                                value: stock[size]!,
                                onChanged: (newQty) {
                                  setState(() {
                                    stock[size] = newQty;
                                  });
                                },
                              ),
                            );
                          }),

                          const SizedBox(height: 24),

                          Padding(
                            padding: EdgeInsets.only(
                              bottom:
                                  MediaQuery.of(context).viewInsets.bottom + 20,
                              top: 24,
                            ),
                            child: SafeArea(
                              top: false,
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: context.colors.primary,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: _save,
                                  child: Text(
                                    "Salvar alterações",
                                    style: context.texts.labelLarge,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget stockCounter({
    required String size,
    required int value,
    required void Function(int) onChanged,
  }) {
    return Row(
      children: [
        Container(
          width: 55,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: context.colors.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            size,
            textAlign: TextAlign.center,
            style: context.texts.bodyMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(width: 12),

        CircleAvatar(
          radius: 18,
          backgroundColor: context.colors.secondary.withValues(alpha: 0.2),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(Icons.remove, color: context.colors.secondary),
            onPressed: () {
              if (value > 0) onChanged(value - 1);
            },
          ),
        ),

        const SizedBox(width: 12),

        Container(
          width: 70,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: context.colors.secondary, width: 1),
          ),
          child: Text(
            value.toString(),
            textAlign: TextAlign.center,
            style: context.texts.bodyMedium,
          ),
        ),

        const SizedBox(width: 12),

        CircleAvatar(
          radius: 18,
          backgroundColor: context.colors.primary.withValues(alpha: 0.2),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(Icons.add, color: context.colors.primary),
            onPressed: () {
              onChanged(value + 1);
            },
          ),
        ),
      ],
    );
  }
}
