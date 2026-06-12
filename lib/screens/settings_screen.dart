import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/info_bottom_sheet.dart';
import 'history_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text('settings'.tr()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildSectionTitle('Général'),
          _buildSettingsCard([
            _buildSettingTile(
              icon: Icons.language,
              title: 'language'.tr(),
              subtitle: context.locale == const Locale('fr', 'FR') ? 'Français' : 'English',
              onTap: () async {
                if (context.locale == const Locale('fr', 'FR')) {
                  await context.setLocale(const Locale('en', 'US'));
                } else {
                  await context.setLocale(const Locale('fr', 'FR'));
                }
              },
            ),
            _buildDivider(),
            _buildSettingTile(
              icon: Icons.history,
              title: 'history'.tr(),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
              },
            ),
            _buildDivider(),
            _buildSettingTile(
              icon: Icons.favorite_border,
              title: 'favorites'.tr(),
              onTap: () {
                // TODO: Favorites Screen
              },
            ),
          ]),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Sécurité & Légal'),
          _buildSettingsCard([
            _buildSettingTile(
              icon: Icons.security,
              title: 'security'.tr(),
              onTap: () {
                // TODO: Security Settings
              },
            ),
            _buildDivider(),
            _buildSettingTile(
              icon: Icons.privacy_tip_outlined,
              title: 'privacy'.tr(),
              onTap: () {
                showDialog(context: context, builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF1E1E1E),
                  title: Text('privacy'.tr(), style: const TextStyle(color: Colors.white)),
                  content: Text('privacy_content'.tr(), style: const TextStyle(color: Colors.white70)),
                  actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
                ));
              },
            ),
            _buildDivider(),
            _buildSettingTile(
              icon: Icons.description_outlined,
              title: 'terms'.tr(),
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 24),
          _buildSectionTitle('À propos'),
          _buildSettingsCard([
            _buildSettingTile(
              icon: Icons.info_outline,
              title: 'À propos de Zoli',
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const InfoBottomSheet(
                    title: 'À propos de Zoli',
                    subtitle: 'Version 1.0.0+2',
                    content: "Zoli est une application conçue pour simplifier l'accès aux codes USSD des opérateurs mobiles au Bénin (MTN, MOOV, Celtiis). Plus besoin de mémoriser ou chercher les codes — tout est regroupé en un seul endroit, organisé et accessible en quelques secondes.",
                    icon: Icons.info_outline,
                  ),
                );
              },
            ),
            _buildDivider(),
            _buildSettingTile(
              icon: Icons.code,
              title: 'À propos du développeur',
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const InfoBottomSheet(
                    title: 'À propos du développeur',
                    subtitle: 'Ulrich IDOHOU',
                    content: "Je suis Ulrich IDOHOU, développeur Flutter basé à Abomey-Calavi, Bénin. Passionné par la création d'outils utiles et accessibles pour le quotidien africain, je développe des applications centrées sur l'expérience utilisateur locale.",
                    icon: Icons.person,
                  ),
                );
              },
            ),
            _buildDivider(),
            _buildSettingTile(
              icon: Icons.star_border,
              title: 'rate'.tr(),
              onTap: () {},
            ),
            _buildDivider(),
            _buildSettingTile(
              icon: Icons.share,
              title: 'share'.tr(),
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF00AEEF).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF00AEEF), size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.white30, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: Colors.white10,
      height: 1,
      indent: 60,
      endIndent: 16,
    );
  }
}
