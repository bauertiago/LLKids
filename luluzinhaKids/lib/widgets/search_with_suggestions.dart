import 'package:flutter/material.dart';
import 'package:luluzinhakids/models/productModel/product_model.dart';

import '../services/product_service.dart';
import 'custom_search_bar.dart';

class SearchWithSuggestions extends StatefulWidget {
  final void Function(Product product)? onProductSelected;

  const SearchWithSuggestions({super.key, this.onProductSelected});
  @override
  State<SearchWithSuggestions> createState() => _SearchWithSuggestionsState();
}

class _SearchWithSuggestionsState extends State<SearchWithSuggestions> {
  final _searchController = TextEditingController();
  final _productService = ProductService();
  List<Product> _suggestions = [];

  void _onSearchChanged(String value) async {
    if (value.isEmpty) return setState(() => _suggestions = []);

    final result = await _productService.searchProducts(value);
    setState(() => _suggestions = result);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomSearchBar(
          controller: _searchController,
          onChanged: _onSearchChanged,
        ),

        if (_suggestions.isNotEmpty)
          _buildSuggestionList()
        else if (_searchController.text.isNotEmpty)
          _buildNoResultsMessage(),
      ],
    );
  }

  Widget _buildSuggestionList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: _suggestions.map((product) {
          return ListTile(
            title: Text(product.name),
            dense: true,
            onTap: () {
              FocusScope.of(context).unfocus();
              _searchController.clear();
              setState(() => _suggestions = []);

              widget.onProductSelected?.call(product);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNoResultsMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Text(
          "Nenhum produto encontrado.",
          style: TextStyle(color: Colors.black54),
        ),
      ),
    );
  }
}
