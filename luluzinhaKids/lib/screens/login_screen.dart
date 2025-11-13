import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:luluzinhakids/extensions/context_extensions.dart';
import 'package:luluzinhakids/screens/main_screen.dart';
import 'package:luluzinhakids/screens/register_screen.dart';
import 'package:luluzinhakids/widgets/custom_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Image.asset(
                  'assets/images/Logo.png',
                  width: 250,
                  height: 250,
                ),
              ),

              const SizedBox(height: 16),
              Text(
                "Bem Vindo!",
                textAlign: TextAlign.center,
                style: context.texts.titleMedium,
              ),

              Text(
                "Faça login para continuar",
                textAlign: TextAlign.center,
                style: context.texts.bodyMedium,
              ),

              const SizedBox(height: 32),
              const CustomInput(
                hintText: "E-mail",
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),
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

              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => MainScreen()),
                  );
                },
                child: Text("Entrar", style: context.texts.labelLarge),
              ),

              const SizedBox(height: 16),
              Text(
                "ou",
                textAlign: TextAlign.center,
                style: context.texts.bodyMedium,
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.secondary,
                    ), // borda cinza leve
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  icon: Image.asset(
                    'assets/images/logoGoogle.png',
                    width: 24,
                    height: 24,
                  ),
                  label: Text(
                    "Entrar com o Google",
                    style: context.texts.bodyMedium,
                  ),
                  onPressed: () {},
                ),
              ),

              const SizedBox(height: 8),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text.rich(
                    TextSpan(
                      text: "Não tem uma conta? ",
                      style: context.texts.bodyMedium,
                      children: [
                        TextSpan(
                          text: "Cadastre-se",
                          style: context.texts.titleLarge!.copyWith(
                            color: context.colors.primary,
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
