import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:secure_application/secure_application.dart';
import 'package:local_session_timeout/local_session_timeout.dart';
import 'theme/app_theme.dart';
import 'screens/selection_reseau_screen.dart';
import 'services/security_service.dart';
import 'services/codes_repository.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await CodesRepository.instance.initialize();

  FlutterError.onError = (details) {
    AuditService.logError('Flutter Error', details.exception, details.stack);
  };

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('fr', 'FR')],
      path: 'assets/translations',
      fallbackLocale: const Locale('fr', 'FR'),
      child: const ZapApp(),
    ),
  );
}

class ZapApp extends StatelessWidget {
  final SecureApplicationController? secureApplicationController;
  const ZapApp({super.key, this.secureApplicationController});

  @override
  Widget build(BuildContext context) {
    final secureApp = SecureApplication(
      secureApplicationController: secureApplicationController,
      nativeRemoveDelay: 500,
      child: Builder(
        builder: (context) {
          return ListenableBuilder(
            listenable: themeNotifier,
            builder: (context, _) {
              return MaterialApp(
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: const Locale('fr', 'FR'),
                title: 'UNIONE',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeNotifier.themeMode,
                home: SecureGate(
                  opacity: 0.9,
                  lockedBuilder: (context, notifier) =>
                      _buildLockedScreen(notifier),
                  child: const SelectionReseauScreen(),
                ),
              );
            },
          );
        },
      ),
    );

    if (kIsWeb || Platform.environment.containsKey('FLUTTER_TEST')) {
      return secureApp;
    }

    final sessionConfig = SessionConfig(
      invalidateSessionForAppLostFocus: const Duration(seconds: 30),
      invalidateSessionForUserInactivity: const Duration(minutes: 5),
    );

    return SessionTimeoutManager(
      userActivityDebounceDuration: const Duration(seconds: 1),
      sessionConfig: sessionConfig,
      child: secureApp,
    );
  }

  Widget _buildLockedScreen(SecureApplicationController? notifier) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fingerprint, size: 80, color: Colors.white54),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => notifier?.unlock(),
              child: const Text('Reprendre la session'),
            ),
          ],
        ),
      ),
    );
  }
}
