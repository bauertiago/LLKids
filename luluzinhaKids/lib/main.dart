import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:luluzinhakids/screens/accessScreens/login_screen.dart';
import 'package:luluzinhakids/screens/mainScreens/home_screen.dart';
import 'package:luluzinhakids/services/firebase_auth_service.dart';

import 'firebase_options.dart';

class BrandColors {
  final Color primaryColor;
  final Color secondaryColor;
  final Color textDarkColor;
  final Color textLightColor;

  BrandColors({
    required this.primaryColor,
    required this.secondaryColor,
    required this.textDarkColor,
    required this.textLightColor,
  });
}

final brand = BrandColors(
  primaryColor: const Color(0xFFFF2BA9),
  secondaryColor: const Color(0xFF8A9BD9),
  textDarkColor: const Color(0xFF404557),
  textLightColor: Colors.white,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Stripe.publishableKey =
      'pk_test_51SZDQ42NvLmRG9PZ5VvemzME4t46gajFExSDs3UuxMc6PVYRC3dCtfMT3u39wFy7ZKHiqOjRnt1ow6TXut03pXC400VIrHtWkY';
  await Stripe.instance.applySettings();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: brand.primaryColor,
          secondary: brand.secondaryColor,
          brightness: Brightness.light,
        ),

        scaffoldBackgroundColor: Color(0xFFF6F8FF),

        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFF6F8FF),
          foregroundColor: brand.secondaryColor,
        ),

        iconTheme: IconThemeData(color: brand.secondaryColor),

        //Textos
        textTheme: TextTheme(
          //Titulos Dark
          titleLarge: TextStyle(
            color: brand.textDarkColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(
            color: brand.textDarkColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          titleSmall: TextStyle(
            color: brand.textDarkColor,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),

          //Textos Dark
          bodyLarge: TextStyle(color: brand.textDarkColor, fontSize: 20),
          bodyMedium: TextStyle(color: brand.textDarkColor, fontSize: 18),
          bodySmall: TextStyle(color: brand.textDarkColor, fontSize: 14),

          //Textos Light
          labelLarge: TextStyle(
            color: brand.textLightColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          labelMedium: TextStyle(color: brand.textLightColor, fontSize: 18),
          labelSmall: TextStyle(color: brand.textLightColor, fontSize: 14),
        ),

        //Inputs
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFFFFEFE),
          hintStyle: TextStyle(color: Color(0xFFCFD4EC)),
          labelStyle: TextStyle(color: Color(0xFF404557)),
          floatingLabelStyle: TextStyle(
            color: Color(0xFFFF2BA9),
            fontWeight: FontWeight.bold,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF8A9BD9), width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFFF2BA9), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          prefixIconColor: Color(0xFF8A9BD9),
        ),

        //Icones de botões
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            iconColor: WidgetStateProperty.all(Color(0xFF8A9BD9)),
          ),
        ),
      ),

      home: LoginScreen(),
    );
  }
}

class Initializer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Initializer();
}

class _Initializer extends State<Initializer> {
  final FirebaseAuthService firebaseAuth = FirebaseAuthService();
  @override
  Widget build(BuildContext context) {
    return firebaseAuth.firebaseAuth.currentUser != null
        ? HomeScreen()
        : LoginScreen();
  }
}
