import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/settings_menu_item.dart';
import '../widgets/logout_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          // Profile Section
          Container(
            color: AppColors.card,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        color: AppColors.accentBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 48,
                        color: AppColors.foreground,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 16,
                          color: AppColors.primaryForeground,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Lucas Scott',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '@lucasscott3',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          
          // Settings Menu
          Container(
            color: AppColors.card,
            child: Column(
              children: [
                SettingsMenuItem(
                  title: 'Notifications',
                  onTap: () {},
                ),
                SettingsMenuItem(
                  title: 'Appearance',
                  onTap: () {},
                ),
                SettingsMenuItem(
                  title: 'Privacy & Security',
                  onTap: () {},
                ),
                SettingsMenuItem(
                  title: 'Storage',
                  onTap: () {},
                  showBorder: false,
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Logout Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const LogoutDialog(),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.destructive, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Log out',
                  style: TextStyle(
                    color: AppColors.destructive,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
