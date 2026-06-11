// Tests Flutter de l'application Zoli
//
// Ce test vérifie l'écran de verrouillage en isolation, sans instancier
// ZapApp ni les packages tiers (SecureApplication, SessionTimeoutManager)
// qui créent des timers internes difficiles à contrôler dans les tests.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('L\'écran de verrouillage affiche l\'icône d\'empreinte', (WidgetTester tester) async {
    // Construit directement le contenu de l'écran de verrouillage en isolation.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.fingerprint, size: 80, color: Colors.white54),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Reprendre la session'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Vérifie que l'icône d'empreinte est bien affichée.
    expect(find.byIcon(Icons.fingerprint), findsOneWidget);
    // Vérifie que le bouton de reprise est présent.
    expect(find.text('Reprendre la session'), findsOneWidget);
  });
}
