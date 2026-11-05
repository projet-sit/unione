import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../models/action_ussd.dart';
import '../models/reseau.dart';
import '../services/ussd_service.dart';

class UssdFlowScreen extends StatefulWidget {
  final Reseau reseau;
  final ActionUssd action;
  const UssdFlowScreen({super.key, required this.reseau, required this.action});
  @override
  State<UssdFlowScreen> createState() => _UssdFlowScreenState();
}

class _UssdFlowScreenState extends State<UssdFlowScreen> {
  late final Map<String, TextEditingController> _controllers = {
    for (final param in widget.action.params.where((param) => !param.sensitive))
      param.key: TextEditingController(),
  };
  bool _submitting = false;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickContact(TextEditingController controller) async {
    final allowed = await FlutterContacts.permissions.request(
      PermissionType.read,
    );
    if (allowed != PermissionStatus.granted || !mounted) return;
    final contact = await FlutterContacts.native.showPicker();
    if (contact?.phones.isNotEmpty == true) {
      controller.text = _normalizePhone(contact!.phones.first.number);
      setState(() {});
    }
  }

  String _normalizePhone(String value) {
    var phone = value.replaceAll(RegExp(r'[^0-9+]'), '');
    if (phone.startsWith('+229')) phone = phone.substring(4);
    if (phone.startsWith('00229')) phone = phone.substring(5);
    return phone;
  }

  String? _validate(CodeParameter parameter, String value) {
    final clean = value.trim();
    if (clean.isEmpty) return 'Ce champ est obligatoire.';
    if (parameter.type == 'phone' &&
        !RegExp(r'^[0-9]{8,10}$').hasMatch(_normalizePhone(clean))) {
      return 'Saisissez un numéro béninois valide (8 à 10 chiffres).';
    }
    if (parameter.type == 'amount') {
      final amount = int.tryParse(clean.replaceAll(RegExp(r'[^0-9]'), ''));
      if (amount == null || amount <= 0) return 'Saisissez un montant positif.';
    }
    return null;
  }

  Future<void> _confirmAndExecute() async {
    final data = <String, String>{};
    for (final parameter in widget.action.params) {
      // Les PIN ne sont jamais saisis, journalisés ou conservés par UNIONE.
      if (parameter.sensitive) continue;
      final value = _controllers[parameter.key]!.text;
      final error = _validate(parameter, value);
      if (error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
        return;
      }
      data[parameter.key] = parameter.type == 'phone'
          ? _normalizePhone(value)
          : value.replaceAll(RegExp(r'[^0-9]'), '');
    }
    final code = UssdService.buildFromTemplate(
      template: widget.action.template!,
      data: data,
    );
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Le code nécessite une confirmation dans le menu de l’opérateur.',
          ),
        ),
      );
      return;
    }
    final launch = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Vérifier l’opération'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.action.titre,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            const Text('Code à envoyer :'),
            const SizedBox(height: 4),
            SelectableText(
              code,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            if (widget.action.params.any((item) => item.sensitive)) ...[
              const SizedBox(height: 12),
              const Text(
                'Votre code PIN sera demandé uniquement par l’opérateur et ne sera jamais saisi ni enregistré par UNIONE.',
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('ANNULER'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('LANCER'),
          ),
        ],
      ),
    );
    if (launch != true || !mounted) return;
    setState(() => _submitting = true);
    await UssdService.launchUssd(
      context,
      code,
      title: widget.action.titre,
      network: widget.reseau.nom,
      operatorId: widget.reseau.type.name,
    );
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    appBar: AppBar(title: Text(widget.action.titre), centerTitle: true),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Complétez les informations',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text('Vérifiez le numéro et le montant avant le lancement.'),
            const SizedBox(height: 28),
            Expanded(
              child: ListView(
                children: [
                  ...widget.action.params
                      .where((param) => !param.sensitive)
                      .map(_buildField),
                  if (widget.action.params.any((param) => param.sensitive))
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Pour votre sécurité, le code PIN sera demandé directement par l’opérateur.',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: widget.reseau.couleur,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: _submitting ? null : _confirmAndExecute,
                child: _submitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'APERÇU ET LANCEMENT',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildField(CodeParameter parameter) {
    final isPhone = parameter.type == 'phone';
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: _controllers[parameter.key],
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: parameter.label,
          prefixIcon: Icon(
            isPhone ? Icons.phone_android_rounded : Icons.payments_outlined,
            color: widget.reseau.couleur,
          ),
          suffixIcon: isPhone
              ? IconButton(
                  icon: const Icon(Icons.contact_phone_rounded),
                  tooltip: 'Choisir un contact',
                  onPressed: () => _pickContact(_controllers[parameter.key]!),
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
