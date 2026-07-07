import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:controle_horas/src/core/theme/app_colors.dart';
import 'package:controle_horas/src/ui/widgets/app_drawer.dart';

/// Chave do Scaffold que envolve toda a navegação principal — usada pelas
/// páginas internas (Home/Criar/Configurações) pra abrir o drawer, já que
/// ele vive um nível acima delas (no [MainScreen]).
final mainScaffoldKey = GlobalKey<ScaffoldState>();

void openAppDrawer() => mainScaffoldKey.currentState?.openDrawer();

class MainScreen extends StatelessWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    if (path.startsWith('/home')) return 0;
    if (path.startsWith('/create')) return 1;
    if (path.startsWith('/settings')) return 2;
    return 0;
  }

  void _onTap(int index, BuildContext context) {
    switch (index) {
      case 0: context.go('/home'); break;
      case 1: context.go('/create'); break;
      case 2: context.go('/settings'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return Scaffold(
      key: mainScaffoldKey,
      extendBody: true,
      drawer: const AppDrawer(),
      body: child,
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: 94,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _FloatingNavBar(
                currentIndex: currentIndex,
                onTap: (index) => _onTap(index, context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark
        ? const Color(0xFF0D0D0D).withValues(alpha: 0.75)
        : Colors.white.withValues(alpha: 0.75);

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.white.withValues(alpha: 0.90);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.50 : 0.10),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(200),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            width: 220,
            height: 62,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(200),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavItem(icon: Iconsax.home, isSelected: currentIndex == 0, onTap: () => onTap(0), isDark: isDark),
                  _NavItem(icon: Iconsax.add_circle, isSelected: currentIndex == 1, onTap: () => onTap(1), isDark: isDark),
                  _NavItem(icon: Iconsax.setting, isSelected: currentIndex == 2, onTap: () => onTap(2), isDark: isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _NavItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = isDark ? AppColors.white : AppColors.neutralGrey900;
    final unselectedColor = isDark
        ? Colors.white.withValues(alpha: 0.35)
        : Colors.black.withValues(alpha: 0.30);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 48,
        height: 62,
        child: Center(
          child: Icon(
            icon,
            color: isSelected ? selectedColor : unselectedColor,
            size: 26,
          ),
        ),
      ),
    );
  }
}
