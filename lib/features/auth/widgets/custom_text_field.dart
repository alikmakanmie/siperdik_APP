import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String? label;
  final String placeholder;
  final TextEditingController? controller;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onTogglePassword;
  final TextInputType? keyboardType;

  const CustomTextField({
    Key? key,
    this.label,
    required this.placeholder,
    this.controller,
    this.isPassword = false,
    this.obscureText = false,
    this.onTogglePassword,
    this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: placeholder,
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.mutedForeground,
                    ),
                    onPressed: onTogglePassword,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
