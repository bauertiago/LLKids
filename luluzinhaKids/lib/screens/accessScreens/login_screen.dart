import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:luluzinhakids/extensions/context_extensions.dart';
import 'package:luluzinhakids/screens/accessScreens/register_screen.dart';
import 'package:luluzinhakids/screens/accessScreens/verify_email_screen.dart';
import 'package:luluzinhakids/screens/mainScreens/main_screen.dart';
import 'package:luluzinhakids/services/firebase_auth_service.dart';
import 'package:luluzinhakids/utils/email_validator.dart';
import 'package:luluzinhakids/widgets/custom_input.dart';

import '../../utils/firebase_util.dart';
import '../adminScreens/admin_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool loading = false;
  bool isVisible = false;

  bool emailError = false;
  bool passWordError = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  FirebaseAuthService authService = FirebaseAuthService();

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: context.colors.secondary, content: Text(msg)),
    );
  }

  Future<void> doLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    setState(() {
      emailError = email.isEmpty;
      passWordError = password.isEmpty;
    });

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Preencha todos os campos");
      return;
    }

    if (!EmailValidator.isValidEmail(email)) {
      _showMessage("Digite um e-mail válido.");
      return;
    }

    if (password.length < 8) {
      _showMessage("A senha deve ter pelo menos 8 caracteres.");
      setState(() => passWordError = true);
      return;
    }

    try {
      setState(() => loading = true);

      final credential = await authService.makeLogin(email, password);

      if (!credential.user!.emailVerified) {
        _showMessage("Verifique seu e-mail antes de entrar");

        authService.logout();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => VerifyEmailScreen()),
        );
        return;
      }

      final doc =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(credential.user!.uid)
              .get();
      final role = doc.data()?["role"] ?? "user";

      if (role == "admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
        );
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } on FirebaseAuthException catch (e) {
      const invalidCodes = [
        "user-not-found",
        "wrong-password",
        "invalid-credential",
      ];
      if (invalidCodes.contains(e.code)) {
        _showMessage("Credenciais inválidas. Verifique e tente novamente.");
        setState(() {
          emailError = true;
          passWordError = true;
        });
      } else if (e.code == "network-request-failed") {
        _showMessage("Falha na conexão. Verifique sua internet.");
      } else {
        _showMessage("Erro inesperado. Tente Novamente.");
      }
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 4),
              Center(
                child: Image.asset(
                  'assets/images/Logo.png',
                  width: 250,
                  height: 250,
                ),
              ),

              const SizedBox(height: 4),
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

              const SizedBox(height: 24),
              CustomInput(
                label: "E-mail",
                requiredField: true,
                hintText: "Digite seu e-mail",
                hasError: emailError,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
              ),

              const SizedBox(height: 12),
              CustomInput(
                label: "Senha",
                hintText: "Digite sua senha",
                controller: passwordController,
                requiredField: true,
                hasError: passWordError,
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

              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: doLogin,
                child: Text("Entrar", style: context.texts.labelLarge),
              ),

              const SizedBox(height: 4),
              Text(
                "Campos com * são obrigatórios",
                textAlign: TextAlign.right,
                style: context.texts.bodySmall?.copyWith(color: Colors.red),
              ),

              const SizedBox(height: 8),
              Text(
                "ou",
                textAlign: TextAlign.center,
                style: context.texts.bodyMedium,
              ),

              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
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
                  onPressed: () async {
                    final util = FirebaseUtil();
                    final result = await util.signInWithGoogle();

                    if (result != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MainScreen(initialIndex: 0),
                        ),
                      );
                    }
                  },
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
