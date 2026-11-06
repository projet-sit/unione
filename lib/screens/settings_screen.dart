import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/android_ussd_gateway.dart';
import '../services/theme_service.dart';
import '../services/user_preferences_service.dart';
import '../widgets/info_bottom_sheet.dart';
import 'history_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _simOperators = <({String id, String name})>[
    (id: 'mtn', name: 'MTN'),
    (id: 'moov', name: 'Moov Africa'),
    (id: 'celtiis', name: 'Celtiis'),
  ];

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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                );
              },
            ),
            _buildDivider(context),
            ListenableBuilder(
              listenable: themeNotifier,
              builder: (context, _) => _buildSettingTile(
                context: context,
                icon: Icons.palette_outlined,
                title: 'theme'.tr(),
                subtitle: switch (themeNotifier.themeMode) {
                  ThemeMode.light => 'light'.tr(),
                  ThemeMode.dark => 'dark'.tr(),
                  ThemeMode.system => 'system'.tr(),
                },
                onTap: () => _showThemeDialog(context),
              ),
            ),
          ]),

          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Réseau'),
          _buildSettingsCard(context, [
            _buildSettingTile(
              context: context,
              icon: Icons.sim_card_outlined,
              title: 'SIM par défaut',
              subtitle: 'Choix de carte pour MTN, Moov Africa et Celtiis',
              onTap: () => _showDefaultSimSheet(context),
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
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'contact'.tr()),
          _buildSupportCard(context),

          const SizedBox(height: 40),
        ],
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
          onTap: _launchWhatsApp,
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

  Future<void> _showDefaultSimSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => const _DefaultSimSheet(),
    );
  }

  void _showThemeDialog(BuildContext context) {    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'theme_mode'.tr(),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.light_mode_outlined),
              title: Text('light'.tr()),
              trailing: themeNotifier.themeMode == ThemeMode.light
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                themeNotifier.setThemeMode(ThemeMode.light);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode_outlined),
              title: Text('dark'.tr()),
              trailing: themeNotifier.themeMode == ThemeMode.dark
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                themeNotifier.setThemeMode(ThemeMode.dark);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.brightness_auto_outlined),
              title: Text('system'.tr()),
              trailing: themeNotifier.themeMode == ThemeMode.system
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                themeNotifier.setThemeMode(ThemeMode.system);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
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
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'rate_subtitle'.tr(),
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starNumber = index + 1;
                      return IconButton(
                        icon: Icon(
                          starNumber <= selectedStars
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
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
                  child: Text(
                    'cancel'.tr(),
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
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
                  child: Text(
                    'submit'.tr(),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
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
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
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

/// Feuille de réglage de la SIM par défaut, opérateur par opérateur.
/// Le choix est mémorisé puis appliqué automatiquement aux lancements USSD.
class _DefaultSimSheet extends StatefulWidget {
  const _DefaultSimSheet();

  @override
  State<_DefaultSimSheet> createState() => _DefaultSimSheetState();
}

class _DefaultSimSheetState extends State<_DefaultSimSheet> {
  List<SimCard> _sims = const [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadSims();
  }

  Future<void> _loadSims() async {
    _sims = await AndroidUssdGateway().getSims();
    if (mounted) setState(() => _loaded = true);
  }

  Future<({String label, int? subscriptionId})?> _savedFor(String operatorId) async {
    final savedId = await UserPreferencesService.instance.lastSim(operatorId);
    if (savedId == null) return null;
    final sim = _sims.where((item) => item.subscriptionId == savedId).firstOrNull;
    return (label: sim?.label ?? 'Carte SIM', subscriptionId: savedId);
  }

  Future<void> _pickFor(String operatorId) async {
    if (_sims.isEmpty) return;
    final selected = await showModalBottomSheet<SimCard>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: Text(
                'SIM par défaut — ${SettingsScreen._simOperators.firstWhere((item) => item.id == operatorId).name}',
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
              ),
            ),
            ..._sims.map(
              (sim) => ListTile(
                leading: const Icon(Icons.sim_card_rounded),
                title: Text(sim.label),
                subtitle: sim.operatorName == null ? null : Text(sim.operatorName!),
                onTap: () => Navigator.pop(sheetContext, sim),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.block_rounded),
              title: const Text('Aucune préférence'),
              onTap: () => Navigator.pop<SimCard>(sheetContext, null),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (selected != null) {
      await UserPreferencesService.instance
          .saveLastSim(operatorId, selected.subscriptionId);
    } else {
      await UserPreferencesService.instance.clearLastSim(operatorId);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ListView(
        shrinkWrap: true,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SIM par défaut',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 6),
                Text(
                  'Carte utilisée automatiquement pour chaque opérateur, double SIM uniquement.',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (!_loaded)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_sims.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Aucune carte SIM active n’a été détectée. Ce réglage sert aux téléphones avec double SIM.',
              ),
            )
          else
            ...SettingsScreen._simOperators.map((item) => FutureBuilder<({String label, int? subscriptionId})?>(
                  future: _savedFor(item.id),
                  builder: (context, snapshot) => ListTile(
                    leading: const Icon(Icons.sim_card_outlined),
                    title: Text(item.name),
                    subtitle: Text(snapshot.data?.label ?? 'Aucune définie (détection auto)'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _pickFor(item.id),
                  ),
                )),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
