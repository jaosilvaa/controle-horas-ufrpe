import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? textColor;
  final IconThemeData? iconTheme;
  final double elevation;
  final double scrolledUnderElevation;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final bool centerTitle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.iconTheme,
    this.backgroundColor,
    this.textColor,
    this.elevation = 0,
    this.scrolledUnderElevation = 0,
    this.shadowColor,
    this.surfaceTintColor,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;

    final baseTitleStyle = appBarTheme.titleTextStyle ??
        const TextStyle(fontSize: 18, fontWeight: FontWeight.w500);
    final resolvedTitleStyle = baseTitleStyle.copyWith(
      color: textColor ?? baseTitleStyle.color,
    );

    final resolvedShadowColor =
        shadowColor ?? Colors.black.withValues(alpha: 0.1);

    final resolvedForegroundColor =
        textColor ?? appBarTheme.foregroundColor ?? theme.colorScheme.onSurface;

    final resolvedIconTheme = iconTheme ??
        appBarTheme.iconTheme ??
        IconThemeData(color: resolvedForegroundColor);

    return AppBar(
      backgroundColor:
          backgroundColor ?? appBarTheme.backgroundColor ?? theme.colorScheme.surface,
      elevation: elevation,
      scrolledUnderElevation: scrolledUnderElevation,
      shadowColor: resolvedShadowColor,
      surfaceTintColor: surfaceTintColor ?? Colors.transparent,
      centerTitle: centerTitle,
      iconTheme: resolvedIconTheme,
      title: Text(title, style: resolvedTitleStyle),
      leading: leading,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
