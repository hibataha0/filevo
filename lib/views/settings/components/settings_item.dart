import 'package:flutter/material.dart';
import 'package:filevo/constants/app_colors.dart';

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const SettingsItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkSurface,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadow(isDarkMode),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.getPrimary(isDarkMode).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.getPrimary(isDarkMode),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.getTextPrimary(isDarkMode),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.getTextSecondary(isDarkMode),
          ),
        ),
        trailing: trailing ??
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.getTextSecondary(isDarkMode),
              size: 16,
            ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),
    );
  }
}