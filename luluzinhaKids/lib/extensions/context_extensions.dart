import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  ThemeData get theme => Theme.of(this);
  TextTheme get texts => theme.textTheme;
  ColorScheme get colors => theme.colorScheme;
  get appBar => theme.appBarTheme;
  IconButtonThemeData get iconButton => theme.iconButtonTheme;
  IconThemeData get icon => theme.iconTheme;
  get inputDecoration => theme.inputDecorationTheme;
}
