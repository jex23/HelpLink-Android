import 'package:flutter/material.dart';

class ProfileOption {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  ProfileOption({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });
}
