import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:controle_horas/src/core/theme/app_colors.dart';
import 'package:controle_horas/src/core/theme/app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static final TextTheme _baseTextTheme = TextTheme(
    headlineLarge: AppTextStyles.headline1,
    headlineMedium: AppTextStyles.headline2,
    headlineSmall: AppTextStyles.headline3,
    titleLarge: AppTextStyles.headline4,
    titleMedium: AppTextStyles.headline5,
    titleSmall: AppTextStyles.headline6,
    bodyLarge: AppTextStyles.bodyLarge,
    bodyMedium: AppTextStyles.bodyMedium,
    bodySmall: AppTextStyles.bodySmall,
    labelLarge: AppTextStyles.labelLarge,
    labelMedium: AppTextStyles.labelMedium,
    labelSmall: AppTextStyles.labelSmall,
  );

  static ThemeData get lightTheme {
    const Color scaffold = AppColors.white;
    const Color surface = AppColors.cardLight;
    final theme = ThemeData.light(useMaterial3: true);

    const overlay = Colors.black;
    final neutralOverlay = WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.pressed)) {
        return overlay.withValues(alpha: 0.06);
      }
      if (states.contains(WidgetState.hovered)) {
        return overlay.withValues(alpha: 0.04);
      }
      if (states.contains(WidgetState.focused)) {
        return overlay.withValues(alpha: 0.04);
      }
      return Colors.transparent;
    });

    return theme.copyWith(
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: overlay.withValues(alpha: 0.05),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          splashFactory: NoSplash.splashFactory,
          overlayColor: neutralOverlay,
        ),
      ),
      listTileTheme: ListTileThemeData(
        style: ListTileStyle.list,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.transparent,
      ),
      scaffoldBackgroundColor: scaffold,
      colorScheme: const ColorScheme.light(
        // Cor principal do app: preto no claro (antes era azul).
        primary: AppColors.black,
        secondary: AppColors.neutralLightGrey,
        surface: surface,
        tertiary: AppColors.neutralMidLightGrey,
        onPrimary: AppColors.white,
        onSecondary: AppColors.neutralGrey900,
        onSurface: AppColors.neutralGrey900,
        outline: AppColors.neutralBaseGrey,
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.interTextTheme(_baseTextTheme).apply(
        bodyColor: AppColors.neutralGrey900,
        displayColor: AppColors.black,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: AppColors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: GoogleFonts.roboto(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.black,
        ),
        iconTheme: const IconThemeData(color: AppColors.black),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: AppColors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: scaffold,
        selectedItemColor: AppColors.black,
        unselectedItemColor: AppColors.neutralBaseGrey,
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    const Color scaffold = AppColors.darkScaffold;
    const Color surface = AppColors.neutralGrey950;
    final theme = ThemeData.dark(useMaterial3: true);

    const overlay = Colors.white;
    final neutralOverlay = WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.pressed)) {
        return overlay.withValues(alpha: 0.08);
      }
      if (states.contains(WidgetState.hovered)) {
        return overlay.withValues(alpha: 0.05);
      }
      if (states.contains(WidgetState.focused)) {
        return overlay.withValues(alpha: 0.05);
      }
      return Colors.transparent;
    });

    return theme.copyWith(
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: overlay.withValues(alpha: 0.08),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          splashFactory: NoSplash.splashFactory,
          overlayColor: neutralOverlay,
        ),
      ),
      listTileTheme: ListTileThemeData(
        style: ListTileStyle.list,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.transparent,
      ),
      scaffoldBackgroundColor: scaffold,
      colorScheme: const ColorScheme.dark(
        // Cor principal do app: branco no escuro (antes era azul).
        primary: AppColors.white,
        secondary: AppColors.neutralGrey950,
        surface: surface,
        tertiary: AppColors.darkBorder,
        onPrimary: AppColors.black,
        onSecondary: AppColors.white,
        onSurface: AppColors.darkPrimaryText,
        outline: AppColors.neutralGrey900,
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.interTextTheme(_baseTextTheme).apply(
        bodyColor: AppColors.darkPrimaryText,
        displayColor: AppColors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: GoogleFonts.roboto(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppColors.darkScaffold,
          systemNavigationBarIconBrightness: Brightness.light,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: scaffold,
        selectedItemColor: AppColors.white,
        unselectedItemColor: AppColors.darkUnselectedNav,
        elevation: 0,
      ),
    );
  }
}
