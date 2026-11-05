import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/menu_node.dart';
import '../services/benin_phone.dart';
import '../services/codes_repository.dart';
import '../services/ussd_service.dart';
import 'menu_screen.dart';
import 'selection_reseau_screen.dart';

/// Feuille générique, alimentée exclusivement par un nœud action du JSON.
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
    if (node.financial || node.destructive) {
      final summary = <String>[];
      for (final parameter in node.params) {
        final value = _valueFor(parameter)!;
        summary.add('${parameter.label} : $value');
      }
      final approved = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(node.destructive ? 'Confirmer la désactivation' : 'Vérifier l’opération'),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(node.label, style: const TextStyle(fontWeight: FontWeight.w800)),
            if (summary.isNotEmpty) ...[const SizedBox(height: 10), ...summary.map(Text.new)],
            const SizedBox(height: 14), const Text('Code à envoyer :'),
            SelectableText(code, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            const Text('Le PIN sera demandé seulement par l’opérateur. UNIONE ne le demande, ne le stocke et ne le journalise jamais.'),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('ANNULER')),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('CONFIRMER')),
          ],
        ),
      );
      if (approved != true) return;
    }
    setState(() => _launching = true);
    if (node.launchKind == 'call') {
      await UssdService.launchPhoneNumber(context, code, title: node.label, network: operator.name);
    } else {
      await UssdService.launchUssd(context, code, title: node.label, network: operator.name, operatorId: operator.id);
    }
    if (mounted) setState(() => _launching = false);
  }

  Future<void> _report(MenuNode node, OperatorTree operator, UssdTree tree) async {
    final path = [operator.name, ...tree.breadcrumb(node.id).map((item) => item.label)].join(' › ');
    final message = '''Bonjour, je souhaite signaler un code qui ne marche plus.

Opérateur : ${operator.name}
Chemin : $path
Service : ${node.label}
Code : ${node.code ?? 'non disponible'}
Version de l’app : ${const String.fromEnvironment('UNIONE_APP_VERSION', defaultValue: '1.0.0+2')}
Version du JSON : ${tree.version}''';
    final uri = Uri.https('wa.me', '/22991831317', {'text': message});
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WhatsApp n’a pas pu être ouvert.')));
    }
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
      final preview = unavailable ? null : node.params.isEmpty ? node.code : _codeFor(node);
      final path = [operator.name, ...tree!.breadcrumb(widget.nodeId).map((item) => item.label)].join(' › ');
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Détail du service'), centerTitle: true,
          actions: [IconButton(tooltip: 'Accueil', icon: const Icon(Icons.home_outlined), onPressed: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const SelectionReseauScreen()), (route) => false))],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(path, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .48))),
              const SizedBox(height: 18),
              Expanded(child: ListView(children: [
                CircleAvatar(radius: 28, backgroundColor: operator.color.withValues(alpha: .12), child: Icon(menuIconFor(node.icon), color: operator.color, size: 28)),
                const SizedBox(height: 18),
                Text(node.label, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                if (node.description != null) ...[const SizedBox(height: 8), Text(node.description!)],
                if (node.price != null || node.validity != null) ...[const SizedBox(height: 16), Wrap(spacing: 8, children: [if (node.price != null) Chip(label: Text(node.price!)), if (node.validity != null) Chip(label: Text(node.validity!))])],
                const SizedBox(height: 22),
                if (unavailable) _Notice(text: node.status == 'obsolete' ? 'Ce code est obsolète.' : 'Code bientôt disponible. Vérification en cours.') else ...[
                  if (node.params.isNotEmpty) ...[const Text('Informations requises', style: TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 12), ...node.params.map(_fieldFor)],
                  const SizedBox(height: 20), const Text('Aperçu du code final', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  SelectableText(preview ?? 'Complétez les informations ci-dessus.', style: TextStyle(fontSize: preview == null ? 14 : 18, fontWeight: FontWeight.w800, color: preview == null ? Theme.of(context).colorScheme.onSurface.withValues(alpha: .5) : null)),
                ],
                if (node.notes?.isNotEmpty == true) ...[const SizedBox(height: 16), _Notice(text: node.notes!)],
              ])),
              SizedBox(width: double.infinity, height: 56, child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: operator.color),
                onPressed: unavailable || preview == null || _launching ? null : () => _launch(node, operator),
                icon: _launching ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.phone_forwarded_rounded),
                label: Text(unavailable ? 'CODE INDISPONIBLE' : node.launchKind == 'call' ? 'APPELER LE SERVICE' : 'LANCER LE CODE'),
              )),
              TextButton.icon(
                onPressed: () => _report(node, operator, tree),
                icon: const Icon(Icons.report_problem_outlined),
                label: const Text('Signaler un code qui ne marche plus'),
              ),
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
          value: parameter.options.contains(_controllers[parameter.key]!.text) ? _controllers[parameter.key]!.text : null,
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
