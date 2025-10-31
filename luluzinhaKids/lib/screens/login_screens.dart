import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  bool isVisible = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                style: theme.textTheme.titleMedium,
              ),

              Text(
                "Faça login para continuar",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 32),
              TextField(
                decoration: InputDecoration(
                  hintText: "E-mail",
                  prefixIcon: Icon(Icons.email_outlined),
                  isDense: true,
                  fillColor: Color(0xFFFFFEFE),
                ),
              ),

              const SizedBox(height: 16),
              TextField(
                obscureText: !isVisible,
                decoration: InputDecoration(
                  hintText: "Senha",
                  isDense: true,
                  fillColor: Color(0xFFFFFEFE),
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isVisible ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        isVisible = !isVisible;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
                child: Text("Entrar", style: theme.textTheme.labelLarge),
              ),

              const SizedBox(height: 16),
              Text(
                "ou",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity, // ocupa toda a largura
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
                    backgroundColor: Colors.white, // fundo branco
                  ),
                  icon: Image.asset(
                    'assets/images/logoGoogle.png',
                    width: 24,
                    height: 24,
                  ),
                  label: Text(
                    "Entrar com o Google",
                    style: theme.textTheme.bodyMedium,
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
                      style: theme.textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: "Cadastre-se",
                          style: theme.textTheme.titleLarge!.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {},
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
