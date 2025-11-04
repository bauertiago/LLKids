import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:luluzinhakids/widgets/custom_input.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _Register();
}

class _Register extends State<Register> {
  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Icon(
                  Icons.person_add,
                  size: 100,
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(height: 16),
              Text(
                "Vamos Começar!",
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              Text(
                "Preencha seus dados para se cadastrar",
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),
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
                    ),
                  ),

                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomInput(
                      hintText: "Estado",
                      prefixIcon: Icons.map_outlined,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              CustomInput(
                hintText: "Cidade",
                prefixIcon: Icons.location_city_outlined,
              ),

              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
                child: Text("Cadastrar", style: theme.textTheme.labelLarge),
              ),

              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text.rich(
                    TextSpan(
                      text: "Já possui uma conta? ",
                      style: theme.textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: "Faça login",
                          style: theme.textTheme.titleLarge!.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => Register(),
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
