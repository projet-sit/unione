import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../models/menu_node.dart';
import '../services/benin_phone.dart';
import '../widgets/operator_logo.dart';
import '../services/codes_repository.dart';
import '../services/ussd_service.dart';

/// Mini écran de saisie pour les opérations ussd_param.
/// Il n'affiche jamais le code final : un seul bouton, du nom de l'opération.
class ActionScreen extends StatefulWidget {
  final String nodeId;
  const ActionScreen({super.key, required this.nodeId});

  @override
  State<ActionScreen> createState() => _ActionScreenState();
}

class _ActionScreenState extends State<ActionScreen> {
  final Map<String, TextEditingController> _controllers = {};
  bool _launching = false;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _ensureControllers(MenuNode node) {
    for (final parameter in node.params) {
      _controllers.putIfAbsent(parameter.key, TextEditingController.new);
    }
  }

  String? _valueFor(CodeParameter parameter, {bool showError = false}) {
    final entered = _controllers[parameter.key]?.text.trim() ?? '';
    String? value;
    String? error;
    switch (parameter.type) {
      case 'phone':
        value = BeninPhone.normalize(entered, parameter.format ?? '');
        error = 'Saisissez un numéro béninois valide.';
      case 'amount':
        value = entered.replaceAll(RegExp(r'[^0-9]'), '');
        if (int.tryParse(value) == null || int.parse(value) <= 0) {
          error = 'Saisissez un montant positif.';
          value = null;
        }
      default:
        value = entered;
        if (value.isEmpty) error = 'Ce champ est obligatoire.';
    }
    if (value == null && showError) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error!)));
    }
    return value;
  }

  String? _codeFor(MenuNode node, {bool showError = false}) {
    final values = <String, String>{};
    for (final parameter in node.params) {
      final value = _valueFor(parameter, showError: showError);
      if (value == null) return null;
      values[parameter.key] = value;
    }
    final code = UssdService.buildFromTemplate(template: node.code!, data: values);
    if (code.isEmpty && showError) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Le code ne peut pas être construit.')));
    }
    return code.isEmpty ? null : code;
  }

  Future<void> _pickContact(CodeParameter parameter) async {
    final allowed = await FlutterContacts.permissions.request(PermissionType.read);
    if (allowed != PermissionStatus.granted || !mounted) return;
    final contact = await FlutterContacts.native.showPicker();
    if (contact?.phones.isEmpty != false) return;
    _controllers[parameter.key]!.text = contact!.phones.first.number;
    setState(() {});
  }

  Future<void> _launch(MenuNode node, OperatorTree operator) async {
    if (node.code == null || node.status != 'ok') return;
    final code = node.params.isEmpty ? node.code! : _codeFor(node, showError: true);
    if (code == null) return;
    if (!mounted) return;
    setState(() => _launching = true);
    if (node.launchKind == 'call') {
      await UssdService.launchPhoneNumber(context, code, title: node.label, network: operator.name, serviceId: node.id);
    } else {
      await UssdService.launchUssd(context, code, title: node.label, network: operator.name, operatorId: operator.id, serviceId: node.id);
    }
    if (mounted) setState(() => _launching = false);
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<UssdTree?>(
    valueListenable: CodesRepository.instance.catalogue,
    builder: (context, tree, _) {
      final node = tree?.node(widget.nodeId);
      final operator = tree?.operatorFor(widget.nodeId);
      if (node == null || operator == null || node.type != MenuNodeType.action) {
        return const Scaffold(body: Center(child: Text('Ce service n’est plus disponible.')));
      }
      _ensureControllers(node);
      final unavailable = node.code == null || node.status != 'ok';
      final ready = node.params.isEmpty || _codeFor(node) != null;
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(title: Text(node.label), centerTitle: true),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: ListView(children: [
                if (node.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    node.description!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (node.params.isNotEmpty) ...[
                  const SizedBox(height: 18), const Text('Informations requises', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12), ...node.params.map(_fieldFor),
                ],
                if (node.notes?.isNotEmpty == true) ...[const SizedBox(height: 16), _Notice(text: node.notes!)],
                if (unavailable) ...[const SizedBox(height: 16), _Notice(text: node.status == 'obsolete' ? 'Ce code est obsolète.' : 'Code bientôt disponible. Vérification en cours.')],
                const SizedBox(height: 24),
                SizedBox(width: double.infinity, height: 56, child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: OperatorLogo.accent(context, operator.color)),
                  onPressed: unavailable || !ready || _launching ? null : () => _launch(node, operator),
                  icon: _launching ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.phone_forwarded_rounded),
                  label: Text(node.label),
                )),
              ])),
            ]),
          ),
        ),
      );
    },
  );

  Widget _fieldFor(CodeParameter parameter) {
    final isPhone = parameter.type == 'phone';
    if (parameter.type == 'choice') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: DropdownButtonFormField<String>(
          initialValue: parameter.options.contains(_controllers[parameter.key]!.text) ? _controllers[parameter.key]!.text : null,
          decoration: InputDecoration(labelText: parameter.label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
          items: parameter.options.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
          onChanged: (value) { _controllers[parameter.key]!.text = value ?? ''; setState(() {}); },
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: _controllers[parameter.key],
        keyboardType: parameter.type == 'text' ? TextInputType.text : TextInputType.number,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: parameter.label,
          helperText: parameter.notes,
          prefixIcon: Icon(isPhone ? Icons.phone_android_rounded : Icons.payments_outlined),
          suffixIcon: isPhone ? IconButton(icon: const Icon(Icons.contact_phone_rounded), tooltip: 'Choisir un contact', onPressed: () => _pickContact(parameter)) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final String text;
  const _Notice({required this.text});
  @override
  Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: .08), borderRadius: BorderRadius.circular(14)), child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)));
}
