import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../models/menu_node.dart';
import '../services/benin_phone.dart';
import '../services/ussd_service.dart';
import '../widgets/operator_logo.dart';
import '../widgets/responsive_layout.dart';

class FlowScreen extends StatefulWidget {
  final MenuNode node;
  final OperatorTree operator;

  const FlowScreen({super.key, required this.node, required this.operator});

  @override
  State<FlowScreen> createState() => _FlowScreenState();
}

class _FlowScreenState extends State<FlowScreen> {
  int _stepIndex = 0;
  final Map<String, String> _answers = {};
  bool _submitting = false;

  List<FlowStep> get _steps => widget.node.steps ?? const [];
  List<FlowAction> get _actions => widget.node.actions ?? const [];

  bool get _isLastStep => _stepIndex >= _steps.length;

  String? _currentError;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final Map<String, TextEditingController> _textControllers = {};

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final operatorColor = OperatorLogo.accent(context, widget.operator.color);

    if (_isLastStep) {
      return _buildSummary(context, colorScheme, operatorColor);
    }

    final step = _steps[_stepIndex];
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.node.label,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
        leading: _stepIndex > 0
            ? IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                tooltip: 'Retour',
                onPressed: () {
                  setState(() {
                    _stepIndex--;
                    _currentError = null;
                  });
                },
              )
            : IconButton(
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Fermer',
                onPressed: () => Navigator.of(context).pop(),
              ),
      ),
      body: SafePage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BreadcrumbStep(current: _stepIndex + 1, total: _steps.length),
            const SizedBox(height: 24),
            Text(
              step.label,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _stepHint(step),
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: _buildStepContent(
                context,
                step,
                colorScheme,
                operatorColor,
              ),
            ),
            const SizedBox(height: 24),
            _buildNavigationBar(context, colorScheme, operatorColor),
          ],
        ),
      ),
    );
  }

  String _stepHint(FlowStep step) => switch (step.key) {
    'type' => 'Choisissez le type de service.',
    'pour' => 'Choisissez qui bénéficiera de l activation.',
    'montant' => 'Saisissez le montant ou choisissez une offre rapide.',
    _ => 'Saisissez les informations demandees.',
  };

  Widget _buildStepContent(
    BuildContext context,
    FlowStep step,
    ColorScheme colorScheme,
    Color operatorColor,
  ) {
    switch (step.key) {
      case 'type':
      case 'pour':
        return _buildOptionsList(context, step, colorScheme, operatorColor);
      case 'montant':
        return _buildAmountInput(context, colorScheme, operatorColor);
      case 'numero':
        return _buildPhoneInput(context, colorScheme, operatorColor);
      case 'prenom':
      case 'nom':
        return _buildTextInput(context, step, colorScheme, operatorColor);
      default:
        return _buildOptionsList(context, step, colorScheme, operatorColor);
    }
  }

  Widget _buildOptionsList(
    BuildContext context,
    FlowStep step,
    ColorScheme colorScheme,
    Color operatorColor,
  ) {
    final selectedId = _answers[step.key];
    final widgets = <Widget>[];
    for (final option in step.options) {
      final isSelected = selectedId == option.id;
      widgets.add(
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: isSelected ? operatorColor.withValues(alpha: 0.1) : null,
          child: ListTile(
            leading: Icon(
              isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: isSelected ? operatorColor : null,
            ),
            title: Text(
              option.label,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            onTap: () {
              setState(() {
                _answers[step.key] = option.id;
                _currentError = null;
              });
            },
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildAmountInput(
    BuildContext context,
    ColorScheme colorScheme,
    Color operatorColor,
  ) {
    final montantParam = _findAmountParam();
    final min = montantParam?.min ?? 100;
    final max = montantParam?.max ?? 50000;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Montant (FCFA)',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() => _currentError = null),
          decoration: InputDecoration(
            hintText: 'Ex: 500',
            errorText: _currentError,
            helperText: min > 0 || max > 0 ? 'Entre $min F et $max F' : null,
            prefixIcon: Icon(Icons.attach_money_rounded, color: operatorColor),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Offres rapides',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),
        const SizedBox(height: 8),
        _buildQuickAmounts(context, colorScheme, operatorColor),
      ],
    );
  }

  void _setAmount(String amount) {
    _amountController.text = amount;
    setState(() => _currentError = null);
  }

  Widget _buildQuickAmounts(
    BuildContext context,
    ColorScheme colorScheme,
    Color operatorColor,
  ) {
    final amounts = const <int>[100, 200, 500, 1000, 2000, 5000];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: amounts.length,
        separatorBuilder: (_, index2) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final amount = amounts[index];
          return ActionChip(
            visualDensity: VisualDensity.compact,
            label: Text('$amount F'),
            onPressed: () => _setAmount(amount.toString()),
            avatar: Icon(
              Icons.attach_money_rounded,
              size: 16,
              color: operatorColor,
            ),
          );
        },
      ),
    );
  }

  FlowVariant? _selectedVariant() {
    final pourAutre = _answers['pour'] == 'autre';
    if (_actions.isEmpty) return null;
    final action = _actions.first;
    return pourAutre ? action.autre : action.moi;
  }

  CodeParameter? _findAmountParam() {
    final variant = _selectedVariant();
    if (variant == null) return null;
    return variant.params.where((p) => p.type == 'amount').firstOrNull;
  }

  Widget _buildPhoneInput(
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
                'Numero du beneficiaire',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 16,
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
          onChanged: (_) => setState(() => _currentError = null),
          decoration: InputDecoration(
            hintText: '01 XX XX XX XX',
            errorText: _currentError,
            helperText: 'Accepte 01 XX XX XX XX, +229…, 00229…',
            prefixIcon: Icon(Icons.phone_android_rounded, color: operatorColor),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
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
      _currentError = null;
    });
  }

  Widget _buildTextInput(
    BuildContext context,
    FlowStep step,
    ColorScheme colorScheme,
    Color operatorColor,
  ) {
    final controller = _textControllerFor(step.key);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step.label,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: (_) => setState(() => _currentError = null),
          decoration: InputDecoration(
            errorText: _currentError,
            prefixIcon: Icon(Icons.person_rounded, color: operatorColor),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }

  TextEditingController _textControllerFor(String key) {
    return _textControllers.putIfAbsent(key, () => TextEditingController());
  }

  Widget _buildNavigationBar(
    BuildContext context,
    ColorScheme colorScheme,
    Color operatorColor,
  ) {
    final canNext = _canProceed();
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.icon(
        onPressed: _submitting || !canNext ? null : _nextStep,
        icon: _submitting
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.chevron_right_rounded),
        label: Text(
          _isLastStep ? 'Valider' : 'Suivant',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  bool _canProceed() {
    final step = _steps[_stepIndex];

    if (step.key == 'montant') {
      final montant = _amountController.text.trim();
      if (montant.isEmpty) return false;
      final amount = int.tryParse(montant);
      if (amount == null) return false;
      final param = _findAmountParam();
      if (param != null) {
        if (param.min != null && amount < param.min!) return false;
        if (param.max != null && amount > param.max!) return false;
      }
      return true;
    }

    if (step.key == 'numero') {
      final numero = _phoneController.text.trim();
      if (numero.isEmpty) return false;
      final param = _selectedVariant()?.params
          .where((p) => p.type == 'phone')
          .firstOrNull;
      final format = param?.format ?? '8';
      return BeninPhone.normalize(numero, format) != null;
    }

    if (step.key == 'prenom' || step.key == 'nom') {
      final controller = _textControllerFor(step.key);
      return controller.text.trim().isNotEmpty;
    }

    return _answers[step.key] != null && _answers[step.key]!.isNotEmpty;
  }

  void _nextStep() {
    final step = _steps[_stepIndex];

    switch (step.key) {
      case 'montant':
        _answers[step.key] = _amountController.text.trim();
        break;
      case 'numero':
        _answers[step.key] = _phoneController.text.trim();
        break;
      case 'prenom':
      case 'nom':
        _answers[step.key] = _textControllerFor(step.key).text.trim();
        break;
      default:
        break;
    }

    if (!_canProceed()) return;

    if (_stepIndex < _steps.length - 1) {
      setState(() {
        _stepIndex++;
        _currentError = null;
      });
    } else {
      _submit();
    }
  }

  Future<void> _submit() async {
    final variant = _selectedVariant();
    if (variant == null || variant.code == null || variant.code!.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code indisponible pour cette combinaison.'),
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    final data = <String, String>{};
    for (final param in variant.params) {
      switch (param.type) {
        case 'phone':
          final format = param.format ?? '8';
          final normalized = BeninPhone.normalize(
            _answers[param.key] ?? '',
            format,
          );
          if (normalized == null) {
            setState(() => _submitting = false);
            if (!mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Numero invalide.')));
            return;
          }
          data[param.key] = normalized;
        case 'amount':
          data[param.key] = _answers[param.key] ?? '';
        case 'text':
          data[param.key] = _answers[param.key] ?? '';
        default:
          data[param.key] = _answers[param.key] ?? '';
      }
    }

    final code = UssdService.buildFromTemplate(
      template: variant.code!,
      data: data,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code invalide. Verifiez les informations saisies.'),
        ),
      );
      return;
    }

    await UssdService.launchUssd(
      context,
      code,
      title: widget.node.label,
      network: widget.operator.name,
      operatorId: widget.operator.id,
      serviceId: widget.node.id,
    );
  }

  Widget _buildSummary(
    BuildContext context,
    ColorScheme colorScheme,
    Color operatorColor,
  ) {
    final variant = _selectedVariant();
    final code = variant != null && variant.code != null
        ? _buildResolvedCode(variant)
        : '';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.node.label,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          tooltip: 'Retour',
          onPressed: () {
            setState(() {
              _stepIndex--;
              _currentError = null;
            });
          },
        ),
      ),
      body: SafePage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'Recapitulatif',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Verifiez avant de valider.',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: ListView(
                children: [
                  SummaryRow(
                    label: 'Operation',
                    value: widget.node.label,
                    color: operatorColor,
                  ),
                  ..._buildSummaryRows(colorScheme),
                  if (code.isNotEmpty)
                    SummaryRow(
                      label: 'Code USSD',
                      value: code,
                      color: operatorColor,
                      isCode: true,
                    ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_rounded,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'L operateur vous demandera votre code secret apres validation.',
                            style: TextStyle(
                              color: colorScheme.onSurface.withValues(alpha: 0.9),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: _submitting ? null : () => _submitFromSummary(),
                icon: _submitting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_rounded),
                label: const Text(
                  'Valider',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSummaryRows(ColorScheme colorScheme) {
    final rows = <Widget>[];
    for (final step in _steps) {
      final value = _answers[step.key] ?? '';
      if (value.isEmpty) continue;
      rows.add(
        SummaryRow(
          label: step.label,
          value: step.key == 'numero' ? _maskNumber(value) : value,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }
    return rows;
  }

  String _maskNumber(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 4) return raw;
    return '•• •• •• ${digits.substring(digits.length - 4)}';
  }

  String _buildResolvedCode(FlowVariant variant) {
    final data = <String, String>{};
    for (final param in variant.params) {
      switch (param.type) {
        case 'phone':
          final format = param.format ?? '8';
          data[param.key] =
              BeninPhone.normalize(_answers[param.key] ?? '', format) ?? '';
        case 'amount':
          data[param.key] = _answers[param.key] ?? '';
        case 'text':
          data[param.key] = _answers[param.key] ?? '';
        default:
          data[param.key] = _answers[param.key] ?? '';
      }
    }
    return UssdService.buildFromTemplate(template: variant.code!, data: data);
  }

  Future<void> _submitFromSummary() async {
    final variant = _selectedVariant();
    if (variant == null || variant.code == null || variant.code!.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code indisponible pour cette combinaison.'),
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    final data = <String, String>{};
    for (final param in variant.params) {
      switch (param.type) {
        case 'phone':
          final format = param.format ?? '8';
          final normalized = BeninPhone.normalize(
            _answers[param.key] ?? '',
            format,
          );
          if (normalized == null) {
            setState(() => _submitting = false);
            if (!mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Numero invalide.')));
            return;
          }
          data[param.key] = normalized;
        case 'amount':
          data[param.key] = _answers[param.key] ?? '';
        case 'text':
          data[param.key] = _answers[param.key] ?? '';
        default:
          data[param.key] = _answers[param.key] ?? '';
      }
    }

    final code = UssdService.buildFromTemplate(
      template: variant.code!,
      data: data,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code invalide. Verifiez les informations saisies.'),
        ),
      );
      return;
    }

    await UssdService.launchUssd(
      context,
      code,
      title: widget.node.label,
      network: widget.operator.name,
      operatorId: widget.operator.id,
      serviceId: widget.node.id,
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    for (final c in _textControllers.values) {
      c.dispose();
    }
    super.dispose();
  }
}

class BreadcrumbStep extends StatelessWidget {
  final int current;
  final int total;
  const BreadcrumbStep({super.key, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (index) {
        final active = index < current;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: active
                    ? Theme.of(context).colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
            ),
            if (index < total - 1)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 2,
                width: 24,
                decoration: BoxDecoration(
                  color: active
                      ? Theme.of(context).colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isCode;

  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.isCode = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14,
                fontWeight: isCode ? FontWeight.w800 : FontWeight.w600,
                fontFamily: isCode ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
