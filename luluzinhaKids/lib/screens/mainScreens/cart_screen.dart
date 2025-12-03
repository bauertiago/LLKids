import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:luluzinhakids/extensions/context_extensions.dart';
import 'package:luluzinhakids/models/addressModels/address_model.dart';
import 'package:luluzinhakids/screens/mainScreens/main_screen.dart';
import 'package:luluzinhakids/screens/paymentScreens/payment_screen.dart';
import 'package:luluzinhakids/services/address_service.dart';
import 'package:luluzinhakids/widgets/custom_header.dart';

import '../../models/productModels/product_model.dart';
import '../../services/cart_service.dart';
import '../../widgets/custom_input.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final cartService = CartService();
  final addressService = AddressService();

  Timer? _debounce;

  bool isEditingAddress = false;
  bool isLoadingAddresses = true;
  bool isSavingAddress = false;

  bool phoneError = false;
  bool streetError = false;
  bool numberError = false;
  bool districtError = false;
  bool stateError = false;
  bool cityError = false;
  bool zipCodeError = false;

  List<Address> _addresses = [];
  Address? _selectedAddress;

  final phoneController = TextEditingController();
  final streetController = TextEditingController();
  final numberController = TextEditingController();
  final districtController = TextEditingController();
  final stateController = TextEditingController();
  final cityController = TextEditingController();
  final zipCodeController = TextEditingController();

  final NumberFormat currency = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }

  Future<void> _loadAddresses() async {
    try {
      final list = await addressService.loadAddresses();
      setState(() {
        _addresses = list;
        _selectedAddress = list.isNotEmpty ? list.last : null;
        isLoadingAddresses = false;
      });
    } catch (e) {
      setState(() => isLoadingAddresses = false);
    }
  }

  Future<void> _searchZipCode(String zipCode) async {
    final cleanZip = zipCode.replaceAll(RegExp(r'[^0-9]'), '');

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (cleanZip.length != 8) return;

      final url = Uri.parse("https://viacep.com.br/ws/$cleanZip/json/");
      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (!data.containsKey('erro')) {
            setState(() {
              cityController.text = data['localidade'] ?? '';
              stateController.text = data['uf'] ?? '';
            });
          } else {
            _showMessage("CEP não encontrado.");
          }
        } else {
          _showMessage("Erro ao buscar o CEP.");
        }
      } catch (_) {
        _showMessage("Erro de conexão ao buscar o CEP.");
      }
    });
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: context.colors.secondary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Product>>(
      stream: cartService.watchCart(),
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final cart = snapshot.data!;
        final total = cartService.getTotal(cart);

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                CustomHeader(showBackButton: true, showLogo: true),
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Carrinho", style: context.texts.titleLarge),
                  ),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child:
                      cart.isEmpty ? _buildEmptyCart() : _buildCartList(cart),
                ),
              ],
            ),
          ),
          bottomNavigationBar:
              cart.isEmpty
                  ? _buildBottomEmptyCartButton()
                  : _buildBottomCartButtons(total: total),
        );
      },
    );
  }

  Widget _buildEmptyCart() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.shopping_cart_outlined,
          size: 100,
          color: context.colors.secondary,
        ),
        const SizedBox(height: 16),
        Text("Seu carrinho está vazio.", style: context.texts.titleMedium),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Adicione produtos de sua preferência ao carrinho.",
            style: context.texts.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildBottomEmptyCartButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const MainScreen(initialIndex: 0),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text("Encontrar produtos", style: context.texts.labelLarge),
        ),
      ),
    );
  }

  Widget _buildCartList(List<Product> cart) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ...cart.map((product) => _buildCartItem(product)),
          const SizedBox(height: 16),
          _buildTotal(cart),
          const SizedBox(height: 16),
          _buildAddressSection(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCartItem(Product product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.imageUrl,
                  width: 150,
                  height: 170,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        width: 150,
                        height: 170,
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: Icon(Icons.image_not_supported, size: 28),
                      ),
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        cartService.removeFromCart(product);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.colors.secondary),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: context.colors.secondary,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        cartService.decreaseQuantity(product);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        border: Border.all(color: context.colors.secondary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.remove,
                        size: 20,
                        color: context.colors.secondary,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Text("${product.quantity}", style: context.texts.titleMedium),

                  const SizedBox(width: 12),

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        cartService.addQuantity(product);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.colors.secondary),
                      ),
                      child: Icon(
                        Icons.add,
                        size: 20,
                        color: context.colors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: context.texts.titleMedium),
                const SizedBox(height: 8),
                Text(
                  "Tamanho: ${product.selectedSize}",
                  style: context.texts.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  "Valor unitário: ${currency.format(product.salePrice)}",
                  style: context.texts.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotal(List<Product> cart) {
    final total = cartService.getTotal(cart);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Total do Pedido: ${currency.format(total)}",
          style: context.texts.titleMedium,
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Endereço de entrega", style: context.texts.titleMedium),
          const SizedBox(height: 4),

          // Endereço atual fixo
          if (isLoadingAddresses)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            if (!isEditingAddress && _selectedAddress == null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nenhum endereço cadastrado.",
                    style: context.texts.bodySmall,
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => isEditingAddress = true);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: context.colors.secondary,
                          width: 1,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Adicionar Endereço de Entrega",
                        style: context.texts.titleMedium?.copyWith(
                          color: context.colors.secondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            if (!isEditingAddress && _selectedAddress != null)
              _buildSelectedAddressCard(),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isEditingAddress ? _buildAddressForm() : const SizedBox(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectedAddressCard() {
    final addr = _selectedAddress!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.secondary),
          ),
          child: Text(addr.toString(), style: context.texts.bodySmall),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    isEditingAddress = true;
                    streetController.clear();
                    numberController.clear();
                    districtController.clear();
                    stateController.clear();
                    cityController.clear();
                    zipCodeController.clear();
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: context.colors.secondary, width: 1),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Adicionar novo endereço",
                  style: context.texts.bodySmall?.copyWith(
                    color: context.colors.secondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (_addresses.length > 1)
              Expanded(
                child: OutlinedButton(
                  onPressed: _showAddressSelector,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: context.colors.secondary, width: 1),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Trocar endereço",
                    style: context.texts.bodySmall?.copyWith(
                      color: context.colors.secondary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddressForm() {
    return Column(
      key: const ValueKey("addressForm"),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        CustomInput(
          label: "Telefone",
          requiredField: true,
          controller: phoneController,
          hintText: "Ex: (11) 99999-9999",
          hasError: phoneError,
          prefixIcon: Icons.phone,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 8),
        CustomInput(
          label: "Logradouro",
          requiredField: true,
          controller: streetController,
          hintText: "Logradouro",
          hasError: streetError,
          prefixIcon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CustomInput(
                label: "Número",
                requiredField: true,
                controller: numberController,
                hintText: "Número",
                hasError: numberError,
                prefixIcon: Icons.home_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomInput(
                label: "Bairro",
                requiredField: true,
                controller: districtController,
                hintText: "Bairro",
                hasError: districtError,
                prefixIcon: Icons.map_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        CustomInput(
          label: "CEP",
          requiredField: true,
          controller: zipCodeController,
          hintText: "CEP",
          hasError: zipCodeError,
          prefixIcon: Icons.local_post_office_outlined,
          keyboardType: TextInputType.number,
          onChanged: _searchZipCode,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CustomInput(
                label: "Estado",
                requiredField: true,
                controller: stateController,
                hintText: "Estado",
                hasError: stateError,
                prefixIcon: Icons.flag_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomInput(
                label: "Cidade",
                requiredField: true,
                controller: cityController,
                hintText: "Cidade",
                hasError: cityError,
                prefixIcon: Icons.location_city_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: isSavingAddress ? null : _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    isSavingAddress
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text("Confirmar", style: context.texts.labelMedium),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    isEditingAddress = false;

                    phoneController.clear();
                    numberController.clear();
                    streetController.clear();
                    districtController.clear();
                    cityController.clear();
                    stateController.clear();
                    zipCodeController.clear();
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: context.colors.secondary, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text("Cancelar", style: context.texts.bodyMedium),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Future<void> _saveAddress() async {
    final phone = phoneController.text.trim();
    final street = streetController.text.trim();
    final number = numberController.text.trim();
    final district = districtController.text.trim();
    final city = cityController.text.trim();
    final state = stateController.text.trim();
    final zipcode = zipCodeController.text.trim();

    if (phone.isEmpty ||
        street.isEmpty ||
        number.isEmpty ||
        district.isEmpty ||
        city.isEmpty ||
        state.isEmpty ||
        zipcode.isEmpty) {
      setState(() {
        phoneError = phone.isEmpty;
        streetError = street.isEmpty;
        numberError = number.isEmpty;
        districtError = district.isEmpty;
        cityError = city.isEmpty;
        stateError = state.isEmpty;
        zipCodeError = zipcode.isEmpty;
      });
      _showMessage("Preencha todos os campos do endereço.");
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection("users").doc(user.uid).update(
        {"phone": phone},
      );
    }

    final address = Address(
      street: street,
      number: number,
      district: district,
      city: city,
      state: state,
      zipcode: zipcode,
    );

    try {
      setState(() => isSavingAddress = true);
      final saved = await addressService.addAddress(address);

      setState(() {
        _addresses.add(saved);
        _selectedAddress = saved; // último vira padrão
        isEditingAddress = false;
        isSavingAddress = false;
      });

      _showMessage("Endereço salvo com sucesso!");
    } catch (e) {
      setState(() => isSavingAddress = false);
      _showMessage("Erro ao salvar endereço.");
    }
  }

  Future<void> _showAddressSelector() async {
    final selected = await showModalBottomSheet<Address>(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 16),
                Text("Selecione o endereço", style: context.texts.titleMedium),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: _addresses.length,
                    itemBuilder: (_, i) {
                      final addr = _addresses[i];
                      final isSelected = addr.id == _selectedAddress?.id;

                      return Card(
                        child: ListTile(
                          title: Text(addr.toString()),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected)
                                Icon(
                                  Icons.check,
                                  color: context.colors.primary,
                                ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  bool confirm = await _confirmDeleteAddress();
                                  if (confirm) {
                                    await addressService.deleteAddress(addr.id);
                                    setState(() {
                                      _addresses.removeAt(i);
                                      if (_selectedAddress?.id == addr.id) {
                                        _selectedAddress =
                                            _addresses.isNotEmpty
                                                ? _addresses.last
                                                : null;
                                      }
                                    });
                                    Navigator.pop(context);
                                    _showMessage(
                                      "Endereço excluído com sucesso.",
                                    );
                                  }
                                },
                              ),
                            ],
                          ),

                          onTap: () => Navigator.pop(context, addr),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
      isScrollControlled: true,
    );

    if (selected != null) {
      setState(() {
        _selectedAddress = selected;
      });
    }
  }

  Future<bool> _confirmDeleteAddress() async {
    return await showDialog<bool>(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text(
                "Excluir endereço?",
                style: context.texts.titleMedium,
              ),
              content: Text(
                "Tem certeza que deseja remover este endereço?",
                style: context.texts.bodyMedium,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    "Cancelar",
                    style: TextStyle(color: context.colors.secondary),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text("Excluir", style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        ) ??
        false; // se fechar sem escolher nada, retorna false
  }

  Widget _buildBottomCartButtons({required double total}) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedAddress == null) {
                    _showMessage(
                      "Adicione um endereço de entrega antes de finalizar a compra.",
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PaymentScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Finalizar Compra",
                  style: context.texts.labelLarge,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MainScreen(initialIndex: 0),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: context.colors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Continuar Compra",
                  style: context.texts.labelLarge,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
