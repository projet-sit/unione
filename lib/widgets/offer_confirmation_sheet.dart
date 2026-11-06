import 'package:flutter/material.dart';

import '../models/catalog_model.dart';
import '../models/menu_node.dart';
import '../services/ussd_service.dart';

class OfferConfirmationSheet extends StatefulWidget {
  final CatalogModel catalog;
  final OfferModel offer;
  final OperatorTree operator;

  const OfferConfirmationSheet({
    super.key,
    required this.catalog,
    required this.offer,
    required this.operator,
  });

  static Future<bool?> show(
    BuildContext context, {
    required CatalogModel catalog,
    required OfferModel offer,
    required OperatorTree operator,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OfferConfirmationSheet(
        catalog: catalog,
        offer: offer,
        operator: operator,
      ),
    );
  }

  @override
  State<OfferConfirmationSheet> createState() => _OfferConfirmationSheetState();
}

class _OfferConfirmationSheetState extends State<OfferConfirmationSheet> {
  late String _selectedPaymentId;
  bool _launching = false;

  @override
  void initState() {
    super.initState();
    final paymentOptions = _availablePaymentOptions();
    _selectedPaymentId = paymentOptions.isNotEmpty ? paymentOptions.first.id : 'default';
  }

  List<CatalogPaymentOption> _availablePaymentOptions() {
    if (widget.offer.payWith != null && widget.offer.payWith!.isNotEmpty) {
      return widget.offer.payWith!;
    }
    return widget.catalog.payWith;
  }

  String _resolveFinalCode() {
    final paymentOptions = _availablePaymentOptions();
    String template;
    if (paymentOptions.isNotEmpty) {
      final selected = paymentOptions.firstWhere(
        (opt) => opt.id == _selectedPaymentId,
        orElse: () => paymentOptions.first,
      );
      template = selected.code;
    } else if (widget.offer.launch != null) {
      template = widget.offer.launch!.code;
    } else {
      template = widget.catalog.launch.code;
    }
    return template.replaceAll('{price}', widget.offer.price.toString());
  }

  String _resolveMode() {
    if (widget.offer.launch != null) {
      return widget.offer.launch!.mode;
    }
    return widget.catalog.launch.mode;
  }

  String? _resolveHint() {
    return widget.offer.hint;
  }

  Future<void> _launch() async {
    final code = _resolveFinalCode();
    if (code.isEmpty) return;

    setState(() => _launching = true);
    Navigator.of(context).pop(true);

    final title = '${widget.catalog.label} : ${widget.offer.title} (${widget.offer.price} F)';
    await UssdService.launchUssd(
      context,
      code,
      title: title,
      network: widget.operator.name,
      operatorId: widget.operator.id,
      serviceId: widget.offer.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paymentOptions = _availablePaymentOptions();
    final mode = _resolveMode();
    final hint = _resolveHint();
    final finalCode = _resolveFinalCode();
    final isToTest = widget.offer.confidence == 'to_test';

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        14,
        24,
        MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poignée
          Center(
            child: Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // En-tête
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.operator.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.shopping_bag_outlined, color: widget.operator.color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.offer.title == 'à confirmer' ? 'Forfait à confirmer' : widget.offer.title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      '${widget.catalog.label} · ${widget.operator.name}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${widget.offer.price} FCFA',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: widget.operator.color,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Informations récapitulatives
          if (widget.offer.validityLabel != null)
            _InfoRow(label: 'Validité', value: widget.offer.validityLabel!),
          if (widget.offer.contents.isNotEmpty)
            ...widget.offer.contents.map((item) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item, style: const TextStyle(fontSize: 13))),
                ],
              ),
            )),

          if (isToTest)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.amber),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tarif ou volume à confirmer auprès de l’opérateur.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

          // Choix du mode de paiement si plusieurs options (ex: Crédit principal vs Mobile Money)
          if (paymentOptions.length > 1) ...[
            const SizedBox(height: 16),
            const Text(
              'Mode de paiement :',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Row(
              children: paymentOptions.map((opt) {
                final isSelected = opt.id == _selectedPaymentId;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(opt.label),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedPaymentId = opt.id);
                    },
                  ),
                );
              }).toList(),
            ),
          ],

          // Indication du mode menu
          if (mode == 'menu' && hint != null && hint.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.operator.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.touch_app_outlined, color: widget.operator.color, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Dans le menu qui s’affiche : $hint',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),
          // Code USSD final
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Code à lancer :', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                SelectableText(
                  finalCode,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          // Mentions légales requises
          Text(
            'Le montant est débité de votre solde. Tarifs indicatifs : l’opérateur confirme le prix réel.',
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Le PIN sera demandé uniquement par l’opérateur. UNIONE ne demande, ne stocke et ne transmet jamais votre PIN.',
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),

          const SizedBox(height: 22),
          // Boutons d'action
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('ANNULER'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: widget.operator.color,
                    foregroundColor: widget.operator.id == 'mtn' ? const Color(0xFF1E1E1E) : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _launching ? null : _launch,
                  child: _launching
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'ACTIVER LE FORFAIT',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
