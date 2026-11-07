import 'package:flutter/material.dart';

import '../services/user_preferences_service.dart';
import 'onboarding_screen.dart';
import 'selection_reseau_screen.dart';

/// Affiche l'introduction au premier lancement, puis l'accueil.
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  bool? _onboardingSeen;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final seen = await UserPreferencesService.instance.onboardingSeen();
    if (mounted) setState(() => _onboardingSeen = seen);
  }

  Future<void> _finishOnboarding() async {
    await UserPreferencesService.instance.setOnboardingSeen();
    if (mounted) setState(() => _onboardingSeen = true);
  }

  @override
  Widget build(BuildContext context) {
    final seen = _onboardingSeen;
    if (seen == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }
    if (!seen) {
      return OnboardingScreen(onDone: _finishOnboarding);
    }
    return const SelectionReseauScreen();
  }
}
