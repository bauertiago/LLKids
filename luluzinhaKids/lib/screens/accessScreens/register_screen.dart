import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:luluzinhakids/extensions/context_extensions.dart';
import 'package:luluzinhakids/screens/accessScreens/login_screen.dart';
import 'package:luluzinhakids/utils/email_validator.dart';
import 'package:luluzinhakids/widgets/custom_input.dart';

import '../../utils/firebase_util.dart';
import 'verify_email_screen.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _Register();
}

class _Register extends State<Register> {
  bool isVisible = false;
  bool loading = false;

  bool nameError = false;
  bool emailError = false;
  bool passWordError = false;

  final firebaseUtil = FirebaseUtil();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: context.colors.secondary),
    );
  }

  Future<void> doRegister() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    setState(() {
      nameError = name.isEmpty;
      emailError = email.isEmpty;
      passWordError = password.isEmpty;
    });

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage("Preencha todos os campos obrigatórios.");
      return;
    }

    if (!EmailValidator.isValidEmail(email)) {
      _showMessage(
        "Por favor, insira um e-mail com formato válido (ex: seu.email@dominio.com).",
      );
      setState(() {
        emailError = true;
        return;
      });
    }

    if (password.length < 8) {
      _showMessage("A senha deve ter no mínimo 8 caracteres.");
      setState(() => passWordError = true);
      return;
    }

    try {
      setState(() => loading = true);

      await firebaseUtil.register(email, password);

      _showMessage("Cadastro realizado com sucesso! Verifique seu e-mail");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              VerifyEmailScreen(name: name, email: email, isRegistration: true),
        ),
      );
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? "Erro ao cadastrar usuário.");
    } finally {
      setState(() => loading = false);
    }
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
              const SizedBox(height: 16),
              Center(
                child: Icon(
                  Icons.person_add,
                  size: 100,
                  color: context.colors.primary,
                ),
              ),

              const SizedBox(height: 16),
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
              CustomInput(
                label: "Nome",
                hintText: "Digite seu nome",
                requiredField: true,
                prefixIcon: Icons.person_outline,
                controller: nameController,
                hasError: nameError,
              ),

              const SizedBox(height: 8),
              CustomInput(
                label: "E-mail",
                hintText: "Digite seu e-mail",
                requiredField: true,
                prefixIcon: Icons.email_outlined,
                controller: emailController,
                hasError: emailError,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 8),
              CustomInput(
                label: "Senha",
                hintText: "Digite sua senha",
                requiredField: true,
                prefixIcon: Icons.password,
                obscureText: !isVisible,
                controller: passwordController,
                hasError: passWordError,
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

              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: loading ? null : doRegister,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("Cadastrar", style: context.texts.labelLarge),
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
                          recognizer: TapGestureRecognizer()
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
