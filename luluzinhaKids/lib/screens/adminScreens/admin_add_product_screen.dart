import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luluzinhakids/extensions/context_extensions.dart';

import '../../widgets/custom_input.dart';
import 'admin_home_screen.dart';

class AdminAddProductScreen extends StatefulWidget {
  const AdminAddProductScreen({super.key});

  @override
  State<AdminAddProductScreen> createState() => _AdminAddProductScreenState();
}

class _AdminAddProductScreenState extends State<AdminAddProductScreen> {
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final costController = TextEditingController();
  final priceController = TextEditingController();

  final categories = [
    "Conjuntos",
    "Calças",
    "Camisetas",
    "Blusas",
    "Shorts",
    "Vestidos",
    "Praia",
  ];

  final sizes = ["02", "04", "06", "08", "10", "12"];
  Map<String, int> stock = {};

  String? selectedCategory;
  bool highlight = false;
  File? selectedImage;
  bool loading = false;

  List<String> _generateKeywords(String text) {
    final split = text.toLowerCase().split(" ");
    final List<String> result = [];

    for (var word in split) {
      for (int i = 1; i <= word.length; i++) {
        result.add(word.substring(0, i));
      }
    }
    return result.toSet().toList();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => selectedImage = File(file.path));
    }
  }

  Future<String?> uploadImage() async {
    if (selectedImage == null) return null;

    final ref = FirebaseStorage.instance.ref().child(
      "products/${DateTime.now().millisecondsSinceEpoch}.jpg",
    );

    await ref.putFile(selectedImage!);

    return await ref.getDownloadURL();
  }

  Future<void> saveProduct() async {
    final name = nameController.text.trim();
    final desc = descController.text.trim();
    final cost = double.tryParse(costController.text.trim());
    final price = double.tryParse(priceController.text.trim());

    if (name.isEmpty ||
        desc.isEmpty ||
        cost == null ||
        price == null ||
        selectedCategory == null ||
        stock.isEmpty ||
        selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Preencha todos os campos corretamente."),
          backgroundColor: context.colors.primary,
        ),
      );
      return;
    }

    setState(() => loading = true);

    final imageUrl = await uploadImage();

    await FirebaseFirestore.instance.collection("products").add({
      "name": name,
      "description": desc,
      "costPrice": cost,
      "salePrice": price,
      "category": selectedCategory,
      "stock": stock,
      "highlight": highlight,
      "imageUrl": imageUrl,
      "createdAt": FieldValue.serverTimestamp(),
      "searchKeywords": _generateKeywords(name),
    });

    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Produto cadastrado com sucesso!"),
        backgroundColor: context.colors.primary,
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // IMAGEM
                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    height: 160,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                      image:
                          selectedImage != null
                              ? DecorationImage(
                                image: FileImage(selectedImage!),
                                fit: BoxFit.cover,
                              )
                              : null,
                    ),
                    child:
                        selectedImage == null
                            ? const Center(
                              child: Icon(Icons.add_a_photo, size: 50),
                            )
                            : null,
                  ),
                ),

                const SizedBox(height: 20),

                CustomInput(
                  label: "Nome do Produto",
                  hintText: "Digite o nome",
                  requiredField: true,
                  prefixIcon: Icons.label,
                  controller: nameController,
                ),

                CustomInput(
                  label: "Descrição",
                  hintText: "Digite a descrição",
                  requiredField: true,
                  prefixIcon: Icons.description,
                  controller: descController,
                ),

                CustomInput(
                  label: "Preço de Custo",
                  hintText: "0.00",
                  requiredField: true,
                  prefixIcon: Icons.monetization_on,
                  keyboardType: TextInputType.number,
                  controller: costController,
                ),

                CustomInput(
                  label: "Preço de Venda",
                  hintText: "0.00",
                  requiredField: true,
                  prefixIcon: Icons.sell,
                  keyboardType: TextInputType.number,
                  controller: priceController,
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.colors.secondary),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: Text(
                      "Selecione uma categoria",
                      style: context.texts.bodyMedium,
                    ),
                    value: selectedCategory,
                    items:
                        categories
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => selectedCategory = v),
                  ),
                ),

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Estoque por tamanho",
                    style: context.texts.bodyMedium,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children:
                      sizes.map((size) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(size),

                            SizedBox(
                              width: 50,
                              child: TextFormField(
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 4,
                                  ),
                                  hintText: "0",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onChanged: (value) {
                                  int val = int.tryParse(value) ?? 0;
                                  setState(() => stock[size] = val);
                                },
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),

                const SizedBox(height: 12),

                SwitchListTile(
                  title: const Text("Produto em Destaque"),
                  value: highlight,
                  onChanged: (v) => setState(() => highlight = v),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: loading ? null : saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                            "Cadastrar Produto",
                            style: context.texts.labelLarge,
                          ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
