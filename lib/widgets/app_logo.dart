import 'package:flutter/material.dart';
import 'zoli_logo.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo.large({super.key}) : size = 120;
  const AppLogo.medium({super.key}) : size = 56;
  const AppLogo.small({super.key}) : size = 36;
  const AppLogo({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return ZoliLogo(size: size);
  }
}
