import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../widgets/app_logo.dart';
import 'selection_reseau_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(2500.ms, _goToSelection);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  void _goToSelection() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SelectionReseauScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo.large()
                .animate()
                .fadeIn(duration: 400.ms)
                .then(delay: 100.ms)
                .rotate(
                  begin: 0,
                  end: 1,
                  duration: 700.ms,
                  curve: Curves.easeInOut,
                )
                .then()
                .scale(
                  begin: const Offset(1.2, 1.2),
                  end: const Offset(1, 1),
                  duration: 300.ms,
                ),
            const SizedBox(height: 24),
            const Text(
                  'Zoli',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                )
                .animate()
                .fadeIn(delay: 600.ms, duration: 500.ms)
                .custom(
                  delay: 600.ms,
                  duration: 500.ms,
                  begin: 0,
                  end: 6,
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Text(
                      'Zoli',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: value,
                        height: 1,
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}
