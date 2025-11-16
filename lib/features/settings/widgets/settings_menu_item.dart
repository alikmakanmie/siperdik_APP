import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SettingsMenuItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool showBorder;

  const SettingsMenuItem({
    Key? key,
    required this.title,
    required this.onTap,
    this.showBorder = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: showBorder
              ? const Border(
                  bottom: BorderSide(color: AppColors.border),
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.foreground,
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: AppColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}
