import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF2563EB);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  /// Cor de destaque das telas de autenticação (botões, links, bordas).
  /// Preto no modo claro e branco no escuro — substitui o azul nessas telas.
  static Color authAccent(Brightness b) =>
      b == Brightness.dark ? white : black;

  /// Cor do conteúdo (texto/ícone) que fica EM CIMA do [authAccent].
  static Color authOnAccent(Brightness b) =>
      b == Brightness.dark ? black : white;

  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFFF5252);

  // Card background in light mode
  static const Color cardLight = Color(0xFFF4F4F6);

  // Neutrals
  static const Color neutralLightGrey = Color(0xFFF5F5F5);
  static const Color neutralBaseGrey = Color(0xFFB8B8BA);
  static const Color neutralMidLightGrey = Color(0xFFE0E0E0);
  static const Color neutralDarkGrey = Color(0xFF6C7278);
  static const Color neutralGrey900 = Color(0xFF2D2D2D);
  static const Color neutralGrey950 = Color(0xFF18191B);

  // Dark-mode specific
  static const Color darkScaffold = Color(0xFF0D0D0D);
  static const Color darkBorder = Color(0xFF1F1F1F);
  static const Color darkIconContainer = Color(0xFF2B2B2B);
  static const Color darkProgressBg = Color(0xFF393939);
  static const Color darkCircularTrack = Color(0xFF454545);
  static const Color darkUnselectedNav = Color(0xFF555555);
  static const Color darkSubtitle = Color(0xFF80808C);
  static const Color darkSecondaryText = Color(0xFF949494);
  static const Color darkPrimaryText = Color(0xFFE5E5E5);
}
