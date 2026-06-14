import 'package:flutter/material.dart';
import 'package:controle_horas/src/core/theme/app_colors.dart';

enum FeedbackType { success, warning, error }

extension FeedbackExtension on BuildContext {
  void showFeedback(String message, {FeedbackType type = FeedbackType.success}) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();

    final Color backgroundColor = switch (type) {
      FeedbackType.success => AppColors.success,
      FeedbackType.warning => AppColors.warning,
      FeedbackType.error   => AppColors.error,
    };

    final duration = type == FeedbackType.error
        ? const Duration(seconds: 5)
        : const Duration(milliseconds: 2500);

    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }
}
