import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/info_bottom_sheet.dart';
import 'history_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _launchWhatsApp() async {
    final Uri whatsappUri = Uri.parse("https://wa.me/22991831317");
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    }
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
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildSectionTitle(context, 'general'.tr()),
          _buildSettingsCard(context, [
            _buildSettingTile(
              context: context,
              icon: Icons.history,
              title: 'history'.tr(),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
              },
            ),
          ]),
          
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'security_legal'.tr()),
          _buildSettingsCard(context, [
            _buildSettingTile(
              context: context,
              icon: Icons.security,
              title: 'security'.tr(),
              onTap: () => _showSecuritySheet(context),
            ),
            _buildDivider(context),
            _buildSettingTile(
              context: context,
              icon: Icons.privacy_tip_outlined,
              title: 'privacy'.tr(),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    title: Text('privacy'.tr(), style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w900)),
                    content: Text('privacy_content'.tr(), style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('ok'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
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
              onTap: () => _showTermsSheet(context),
            ),
          ]),

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
                    subtitle: 'Version 1.0.0+2',
                    content: 'about_zoli_desc'.tr(),
                    icon: Icons.info_outline,
                  ),
                );
              },
            ),
            _buildDivider(context),
            _buildSettingTile(
              context: context,
              icon: Icons.code,
              title: 'about_developer'.tr(),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => InfoBottomSheet(
                    title: 'about_developer'.tr(),
                    subtitle: 'Ulrich IDOHOU',
                    content: 'about_dev_desc'.tr(),
                    icon: Icons.person,
                  ),
                );
              },
            ),
            _buildDivider(context),
            _buildSettingTile(
              context: context,
              icon: Icons.chat_outlined,
              title: 'contact_whatsapp'.tr(),
              onTap: _launchWhatsApp,
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
              onTap: () => _showShareSheet(context),
            ),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showSecuritySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return InfoBottomSheet(
          title: 'security_title'.tr(),
          subtitle: 'security_subtitle'.tr(),
          content: 'security_desc'.tr(),
          icon: Icons.security_rounded,
        );
      },
    );
  }

  void _showTermsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return InfoBottomSheet(
          title: 'terms_title'.tr(),
          subtitle: 'terms_subtitle'.tr(),
          content: 'terms_desc'.tr(),
          icon: Icons.description_outlined,
        );
      },
    );
  }

  void _showRateDialog(BuildContext context) {
    int selectedStars = 5;
    final primaryColor = Theme.of(context).colorScheme.primary;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              title: Text(
                'rate_title'.tr(),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w900),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'rate_subtitle'.tr(),
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starNumber = index + 1;
                      return IconButton(
                        icon: Icon(
                          starNumber <= selectedStars ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: Colors.amber,
                          size: 42,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedStars = starNumber;
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('cancel'.tr(), style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text('submit'.tr(), style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return InfoBottomSheet(
          title: 'share_title'.tr(),
          subtitle: 'UNIONE App',
          content: 'share_desc'.tr(),
          icon: Icons.share_rounded,
        );
      },
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
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
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
