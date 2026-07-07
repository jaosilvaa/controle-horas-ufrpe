import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:controle_horas/src/ui/features/auth/controllers/auth_controller.dart';
import 'package:controle_horas/src/ui/widgets/user_avatar.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final nome = context.watch<AuthController>().primeiroNome;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          nome != null ? 'Olá, $nome' : 'Olá',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: isDark ? Colors.black : Colors.white,
          ),
        ),
        const UserAvatar(),
      ],
    );
  }
}
