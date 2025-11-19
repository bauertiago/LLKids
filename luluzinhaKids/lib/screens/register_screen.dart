import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:luluzinhakids/extensions/context_extensions.dart';
import 'package:luluzinhakids/screens/login_screen.dart';
import 'package:luluzinhakids/widgets/custom_input.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _Register();
}

class _Register extends State<Register> {
  bool isVisible = false;

  final TextEditingController zipCodeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();

  Future<void> searchZipCode(String zipCode) async {
    if (zipCode.length == 8) {
      final url = Uri.parse("https://viacep.com.br/ws/$zipCode/json/");
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
        _showMessage("Erro ao buscar o CEP");
      }
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Icon(
                  Icons.person_add,
                  size: 100,
                  color: context.colors.primary,
                ),
              ),

              const SizedBox(height: 8),
              Text(
                "Vamos Começar!",
                style: context.texts.titleMedium,
                textAlign: TextAlign.center,
              ),
              Text(
                "Preencha seus dados para se cadastrar",
                style: context.texts.bodyMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),
              const CustomInput(
                hintText: "Nome",
                prefixIcon: Icons.person_outline,
              ),

              const SizedBox(height: 8),
              const CustomInput(
                hintText: "E-mail",
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 8),
              CustomInput(
                hintText: "Senha",
                prefixIcon: Icons.password,
                obscureText: !isVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    isVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      isVisible = !isVisible;
                    });
                  },
                ),
              ),

              const SizedBox(height: 8),
              const CustomInput(
                hintText: "Telefone",
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 8),
              const CustomInput(
                hintText: "Logradouro",
                prefixIcon: Icons.location_on_outlined,
              ),

              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CustomInput(
                      hintText: "Número",
                      prefixIcon: Icons.pin_outlined,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomInput(
                      hintText: "Bairro",
                      prefixIcon: Icons.location_on_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CustomInput(
                      hintText: "CEP",
                      prefixIcon: Icons.local_post_office_outlined,
                      keyboardType: TextInputType.number,
                      controller: zipCodeController,
                      onChanged: (value) {
                        searchZipCode(value.replaceAll(RegExp(r'[^0-9]'), ''));
                      },
                    ),
                  ),

                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomInput(
                      hintText: "Estado",
                      prefixIcon: Icons.map_outlined,
                      controller: stateController,
                      readOnly: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              CustomInput(
                hintText: "Cidade",
                prefixIcon: Icons.location_city_outlined,
                controller: cityController,
                readOnly: true,
              ),

              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
                child: Text("Cadastrar", style: context.texts.labelLarge),
              ),

              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text.rich(
                    TextSpan(
                      text: "Já possui uma conta? ",
                      style: context.texts.bodyMedium,
                      children: [
                        TextSpan(
                          text: "Faça login",
                          style: context.texts.titleLarge!.copyWith(
                            color: context.colors.primary,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => LoginScreen(),
                                    ),
                                  );
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
