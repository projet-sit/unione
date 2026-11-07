import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../models/catalog_model.dart';
import '../models/menu_node.dart';
import '../services/benin_phone.dart';
import '../widgets/operator_logo.dart';

/// Résultat de la sélection du destinataire d'un forfait.
class OfferRecipient {
  /// true = pour soi-même (par défaut), false = pour un autre numéro.
  final bool forSelf;
  /// Numéro normalisé selon le format du paramètre (8, 10 ou 229+8), null si pour soi.
  final String? phoneNumber;
  /// Numéro affiché (masqué pour l'historique), null si pour soi.
  final String? displayNumber;

  const OfferRecipient.forSelf()
      : forSelf = true,
        phoneNumber = null,
        displayNumber = null;

  const OfferRecipient.forOther({
    required this.phoneNumber,
    required this.displayNumber,
  }) : forSelf = false;
}

/// Feuille de sélection du destinataire : "Pour moi" ou "Pour un autre numéro".
///
/// Affiche l'option "Pour un autre numéro" uniquement si l'offre déclare une
/// variante `other` vérifiée sur une source officielle.
class OfferRecipientSheet extends StatefulWidget {
  final OfferModel offer;
  final OperatorTree operator;

  const OfferRecipientSheet({
    super.key,
    required this.offer,
    required this.operator,
  });

  static Future<OfferRecipient?> show(
    BuildContext context, {
    required OfferModel offer,
    required OperatorTree operator,
  }) {
    return showModalBottomSheet<OfferRecipient?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OfferRecipientSheet(offer: offer, operator: operator),
    );
  }

  bool get _hasOtherVariant =>
      offer.other != null &&
      offer.other!.code != null &&
      offer.other!.code!.isNotEmpty &&
      (offer.status == null || offer.status == 'ok');

  @override
  State<OfferRecipientSheet> createState() => _OfferRecipientSheetState();
}

class _OfferRecipientSheetState extends State<OfferRecipientSheet> {
  bool _forOther = false;
  final TextEditingController _phoneController = TextEditingController();
  String? _phoneError;
  String? _normalizedPhone;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickContact() async {
    final allowed = await FlutterContacts.permissions.request(
      PermissionType.read,
    );
    if (!mounted || allowed != PermissionStatus.granted) return;
    final contact = await FlutterContacts.native.showPicker();
    if (!mounted || contact?.phones.isEmpty != false) return;
    setState(() {
      _phoneController.text = contact!.phones.first.number;
      _validatePhone();
    });
  }

  void _validatePhone() {
    String format = '8';
    final otherVariant = widget.offer.other;
    if (otherVariant != null) {
      final phoneParam =
          otherVariant.params.where((p) => p.type == 'phone').firstOrNull;
      if (phoneParam != null && phoneParam.format != null) {
        format = phoneParam.format!;
      }
    }
    final normalized = BeninPhone.normalize(
      _phoneController.text.trim(),
      format,
    );
    setState(() {
      _normalizedPhone = normalized;
      _phoneError = normalized == null && _phoneController.text.isNotEmpty
          ? 'Numéro béninois invalide.'
          : null;
    });
  }

  String _maskedNumber(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 4) return raw;
    final visible = digits.substring(digits.length - 4);
    return '•• •• •• $visible';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final operatorColor = OperatorLogo.accent(context, widget.operator.color);
    final canLaunchOther = _forOther && _normalizedPhone != null;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
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
                          color: operatorColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget._hasOtherVariant
                              ? Icons.person_outline_rounded
                              : Icons.person_rounded,
                          color: operatorColor,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Qui profite du forfait ?',
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Choisissez le bénéficiaire de l’activation.',
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
                  const SizedBox(height: 24),
                  ..._buildOptions(context, colorScheme, operatorColor),
                  if (widget._hasOtherVariant && _forOther) ...[
                    const SizedBox(height: 20),
                    _buildPhoneField(context, colorScheme, operatorColor),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: _forOther && !canLaunchOther
                          ? null
                          : () {
                              Navigator.pop(
                                context,
                                _forOther
                                    ? OfferRecipient.forOther(
                                        phoneNumber: _normalizedPhone!,
                                        displayNumber: _maskedNumber(
                                          _phoneController.text.trim(),
                                        ),
                                      )
                                    : const OfferRecipient.forSelf(),
                              );
                            },
                      icon: const Icon(Icons.person_rounded),
                      label: Text(
                        _forOther && canLaunchOther
                            ? 'Activer pour ce numéro'
                            : 'Activer pour moi',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
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

  List<Widget> _buildOptions(
    BuildContext context,
    ColorScheme colorScheme,
    Color operatorColor,
  ) {
    final options = <Widget>[
      _buildOptionTile(
        context: context,
        value: false,
        groupValue: _forOther,
        title: 'Pour moi',
        subtitle: 'Utilise votre propre ligne',
        leadingIcon: Icons.person_rounded,
        color: operatorColor,
        onSelected: () => setState(() => _forOther = false),
      ),
    ];

    if (widget._hasOtherVariant) {
      options.add(
        _buildOptionTile(
          context: context,
          value: true,
          groupValue: _forOther,
          title: 'Pour un autre numéro',
          subtitle: 'Saisissez le numéro du bénéficiaire',
          leadingIcon: Icons.person_add_outlined,
          color: operatorColor,
          onSelected: () => setState(() => _forOther = true),
        ),
      );
    } else {
      options.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 20,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'L’option “Pour un autre numéro” n’est pas disponible '
                  'pour ce forfait (code non vérifié officiellement).',
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.55),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return options;
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required bool value,
    required bool groupValue,
    required String title,
    required String subtitle,
    required IconData leadingIcon,
    required Color color,
    required VoidCallback onSelected,
  }) {
    final isSelected = value == groupValue;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onSelected,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : Theme.of(context).colorScheme.surface.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.5)
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                leadingIcon,
                color: isSelected ? Colors.white : color,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.circle_outlined,
              color: isSelected ? color : null,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneField(
    BuildContext context,
    ColorScheme colorScheme,
    Color operatorColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Numéro du bénéficiaire',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.contact_phone_rounded),
              tooltip: 'Choisir un contact',
              onPressed: _pickContact,
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          onChanged: (_) => _validatePhone(),
          decoration: InputDecoration(
            hintText: '01 XX XX XX XX',
            helperText: _phoneError != null
                ? _phoneError!
                : 'Accepte 01 XX XX XX XX, +229…, 00229…',
            errorText: _phoneError,
            prefixIcon: Icon(
              Icons.phone_android_rounded,
              color: operatorColor,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }
}
