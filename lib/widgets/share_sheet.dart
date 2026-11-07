import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../config/app_config.dart';

/// Feuille de partage native (WhatsApp, SMS, Telegram, etc.).
class UnioneShareSheet extends StatelessWidget {
  const UnioneShareSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const UnioneShareSheet(),
    );
  }

  Rect? _origin(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    return box == null ? null : box.localToGlobal(Offset.zero) & box.size;
  }

  Future<void> _share(BuildContext context) async {
    await SharePlus.instance.share(
      ShareParams(
        text: AppConfig.shareText,
        subject: 'UNIONE',
        sharePositionOrigin: _origin(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.share_rounded,
                          color: colorScheme.primary,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'share_title'.tr(),
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'share_desc'.tr(),
                              style: TextStyle(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      AppConfig.shareText,
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () => _share(context),
                    icon: const Icon(Icons.ios_share_rounded),
                    label: Text(
                      'share_native_action'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
