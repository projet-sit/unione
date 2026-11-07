import 'package:flutter/material.dart';

/// Introduction affichée au premier lancement (et accessible depuis l'aide).
/// Trois écrans seulement, pour expliquer l'essentiel sans surcharger.
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  static const _pages = <({IconData icon, String title, String body})>[
    (
      icon: Icons.grid_view_rounded,
      title: 'Tous vos services USSD, au même endroit',
      body:
          'Solde, forfaits, transferts et assistance pour MTN, Moov et '
          'Celtiis, réunis dans une seule application.',
    ),
    (
      icon: Icons.verified_user_outlined,
      title: 'Vous gardez le contrôle',
      body:
          'UNIONE lance uniquement le code que vous choisissez. Android gère '
          'la carte SIM et l’autorisation Téléphone. Aucun appel n’est '
          'enregistré.',
    ),
    (
      icon: Icons.offline_bolt_outlined,
      title: 'Rapide, hors ligne et privé',
      body:
          'Le catalogue est embarqué dans l’application. Vos favoris et vos '
          'récents restent sur votre téléphone : aucun numéro, montant ou '
          'code PIN n’est stocké.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index == _pages.length - 1) {
      widget.onDone();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLast = _index == _pages.length - 1;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: widget.onDone,
                child: const Text('Passer'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _index = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            page.icon,
                            size: 56,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.body,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.68,
                            ),
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                final active = index == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 28, 32, 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: _next,
                  child: Text(
                    isLast ? 'Commencer' : 'Suivant',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
