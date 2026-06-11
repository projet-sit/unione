import 'package:flutter/material.dart';

enum SettingType { action, navigation, toggle }

class SettingItem {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final SettingType type;
  final bool? value;
  final ValueChanged<bool>? onToggle;

  SettingItem({
    required this.title,
    required this.icon,
    this.onTap,
    this.type = SettingType.navigation,
    this.value,
    this.onToggle,
  });
}
