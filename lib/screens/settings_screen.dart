import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/setting_item.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void navigateTo(Widget screen) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
    }

    final List<SettingItem> settings = [
      SettingItem(title: 'profile'.tr(), icon: Icons.person_outline),
      SettingItem(title: 'language'.tr(), icon: Icons.language, onTap: () async {
        if (context.locale == const Locale('fr', 'FR')) {
          await context.setLocale(const Locale('en', 'US'));
        } else {
          await context.setLocale(const Locale('fr', 'FR'));
        }
      }),
      SettingItem(title: 'history'.tr(), icon: Icons.history),
      SettingItem(title: 'favorites'.tr(), icon: Icons.favorite_border),
      SettingItem(title: 'security'.tr(), icon: Icons.security),
      SettingItem(title: 'about'.tr(), icon: Icons.info_outline, onTap: () => navigateTo(const AboutScreen())),
      SettingItem(title: 'privacy'.tr(), icon: Icons.privacy_tip_outlined, onTap: () {
         showDialog(context: context, builder: (ctx) => AlertDialog(title: Text('privacy'.tr()), content: Text('privacy_content'.tr())));
      }),
      SettingItem(title: 'terms'.tr(), icon: Icons.description_outlined),
      SettingItem(title: 'contact'.tr(), icon: Icons.support_agent),
      SettingItem(title: 'share'.tr(), icon: Icons.share),
      SettingItem(title: 'rate'.tr(), icon: Icons.star_border),
      SettingItem(title: 'updates'.tr(), icon: Icons.update),
      SettingItem(title: 'technical'.tr(), icon: Icons.developer_mode),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A2540),
      appBar: AppBar(
        title: Text('settings'.tr()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: settings.length,
        separatorBuilder: (context, index) => const Divider(color: Colors.white10),
        itemBuilder: (context, index) {
          final item = settings[index];
          return ListTile(
            leading: Icon(item.icon, color: const Color(0xFF00AEEF)),
            title: Text(item.title, style: const TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white54),
            onTap: item.onTap,
          );
        },
      ),
    );
  }
}
