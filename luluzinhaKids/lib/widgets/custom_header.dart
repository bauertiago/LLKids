import 'package:flutter/material.dart';

import '../screens/mainScreens/main_screen.dart';

class CustomHeader extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onCartTap;
  final String? title;
  final bool showBackButton;
  final bool showLogo;

  const CustomHeader({
    super.key,
    this.onBack,
    this.onCartTap,
    this.title,
    this.showBackButton = true,
    this.showLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          showBackButton
              ? IconButton(
                icon: const Icon(Icons.arrow_back_outlined),
                onPressed: onBack ?? () => Navigator.pop(context),
              )
              : const SizedBox(width: 48), // mantém alinhamento
          if (showLogo)
            Image.asset('assets/images/Logo.png', width: 80)
          else
            Text(
              title ?? '',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed:
                onCartTap ??
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MainScreen(initialIndex: 3),
                    ),
                  );
                },
          ),
        ],
      ),
    );
  }
}
