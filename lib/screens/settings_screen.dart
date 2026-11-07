import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../services/whatsapp_launcher.dart';
import '../widgets/info_bottom_sheet.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/share_sheet.dart';
import 'history_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _launchWhatsApp(BuildContext context, {String? message}) async {
    await WhatsAppLauncher.openWithFeedback(context, message: message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('settings'.tr()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafePage(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildSectionTitle(context, 'general'.tr()),
            _buildSettingsCard(context, [
              _buildSettingTile(
                context: context,
                icon: Icons.history,
                title: 'history'.tr(),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  );
                },
              ),
            ]),

            const SizedBox(height: 24),
            _buildSectionTitle(context, 'security_legal'.tr()),
            _buildSettingsCard(context, [
              _buildSettingTile(
                context: context,
                icon: Icons.privacy_tip_outlined,
                title: 'privacy'.tr(),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      title: Text(
                        'privacy'.tr(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      content: Text(
                        'privacy_content'.tr(),
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(
                            'ok'.tr(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              _buildDivider(context),
              _buildSettingTile(
                context: context,
                icon: Icons.description_outlined,
                title: 'terms'.tr(),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) => InfoBottomSheet(
                      title: 'terms_title'.tr(),
                      subtitle: 'terms_subtitle'.tr(),
                      content: 'terms_desc'.tr(),
                      icon: Icons.description_outlined,
                    ),
                  );
                },
              ),
            ]),

            const SizedBox(height: 24),
            _buildSectionTitle(context, 'contact'.tr()),
            _buildSupportCard(context),

            const SizedBox(height: 24),
            _buildSectionTitle(context, 'about_section'.tr()),
            _buildSettingsCard(context, [
              _buildSettingTile(
                context: context,
                icon: Icons.info_outline,
                title: 'about'.tr(),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => InfoBottomSheet(
                      title: 'about'.tr(),
                      subtitle: 'Version ${AppConfig.appVersion}',
                      content: 'about_zoli_desc'.tr(),
                      icon: Icons.info_outline,
                    ),
                  );
                },
              ),
              _buildDivider(context),
              _buildSettingTile(
                context: context,
                icon: Icons.star_border,
                title: 'rate'.tr(),
                onTap: () => _showRateDialog(context),
              ),
              _buildDivider(context),
              _buildSettingTile(
                context: context,
                icon: Icons.share,
                title: 'share'.tr(),
                onTap: () => UnioneShareSheet.show(context),
              ),
            ]),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard(BuildContext context) {
    const whatsappGreen = Color(0xFF25D366);
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [whatsappGreen, whatsappGreen.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: whatsappGreen.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _launchWhatsApp(context),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chat_bubble_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'contact_whatsapp'.tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Assistance directe & feedback',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white54,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRateDialog(BuildContext context) => _rateApp(context);

  Future<void> _rateApp(BuildContext context) async {
    final marketUri = Uri.parse('market://details?id=${AppConfig.packageId}');
    final storeUri = Uri.parse(AppConfig.playStoreUrl);
    try {
      if (await canLaunchUrl(marketUri)) {
        final opened = await launchUrl(
          marketUri,
          mode: LaunchMode.externalApplication,
        );
        if (opened) return;
      }
    } catch (_) {}
    try {
      if (await launchUrl(storeUri, mode: LaunchMode.externalApplication)) {
        return;
      }
    } catch (_) {}
    if (!context.mounted) return;
    await _launchWhatsApp(
      context,
      message:
          'Bonjour, je souhaite donner mon avis sur UNIONE '
          '(version ${AppConfig.appVersion}).',
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: primaryColor, size: 22),
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
        size: 20,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      color: Colors.black.withValues(alpha: 0.05),
      height: 1,
      indent: 60,
      endIndent: 16,
    );
  }
}
