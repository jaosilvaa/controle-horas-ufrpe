import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:controle_horas/src/core/theme/app_colors.dart';

class MainScreen extends StatelessWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    if (path.startsWith('/home')) return 0;
    if (path.startsWith('/categories')) return 1;
    if (path.startsWith('/create')) return 2;
    if (path.startsWith('/settings')) return 3;
    return 0;
  }

  void _onTap(int index, BuildContext context) {
    switch (index) {
      case 0: context.go('/home'); break;
      case 1: context.go('/categories'); break;
      case 2: context.go('/create'); break;
      case 3: context.go('/settings'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.neutralMidLightGrey,
              width: 1,
            ),
          ),
          color: theme.scaffoldBackgroundColor,
        ),
        child: _BottomNavBar(
          currentIndex: _currentIndex(context),
          onTap: (index) => _onTap(index, context),
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItem(context, 0, Iconsax.home, 'Home'),
          _buildItem(context, 1, Iconsax.category, 'Categorias'),
          _buildItem(context, 2, Iconsax.add_circle, 'Criar'),
          _buildItem(context, 3, Iconsax.setting, 'Config'),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index, IconData icon, String label) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = index == currentIndex;
    final selectedColor = isDark ? AppColors.white : AppColors.neutralGrey900;
    final unselectedColor = isDark ? AppColors.darkUnselectedNav : AppColors.neutralBaseGrey;

    return InkWell(
      onTap: () => onTap(index),
      splashFactory: InkRipple.splashFactory,
      highlightColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      splashColor: (isDark ? AppColors.white : AppColors.black).withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? selectedColor : unselectedColor, size: 26),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selectedColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
