import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:luluzinhakids/extensions/context_extensions.dart';

import '../mainScreens/main_screen.dart';
import 'login_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool loading = false;
  final auth = FirebaseAuth.instance;

  DateTime? lastEmailSent;
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> resendEmail() async {
    if (lastEmailSent != null &&
        DateTime.now().difference(lastEmailSent!) <
            const Duration(seconds: 30)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Aguarde antes de reenviar o e-mail."),
          backgroundColor: context.colors.secondary,
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await auth.currentUser!.sendEmailVerification();
      lastEmailSent = DateTime.now();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("E-mail reenviado."),
          backgroundColor: context.colors.secondary,
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao reenviar e-mail."),
          backgroundColor: context.colors.secondary,
        ),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> checkVerification({bool auto = false}) async {
    await auth.currentUser!.reload();
    if (auth.currentUser!.emailVerified) {
      timer?.cancel();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen(initialIndex: 0)),
      );
      return;
    }
    if (!auto) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("E-mail ainda não verificado."),
          backgroundColor: context.colors.secondary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mark_email_read,
                size: 100,
                color: context.colors.primary,
              ),
              const SizedBox(height: 20),

              const Text(
                "Verifique seu e-mail!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              const Text(
                "Enviamos um link de confirmação para seu e-mail.\n"
                "Clique no link para ativar sua conta.",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: loading ? null : resendEmail,
                child:
                    loading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text("Reenviar e-mail"),
              ),

              TextButton(
                onPressed: () => checkVerification(auto: false),
                child: const Text("Já verifiquei"),
              ),

              TextButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text("Trocar e-mail"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
