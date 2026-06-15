import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../services/ussd_service.dart';
import '../models/reseau.dart';
import '../models/action_ussd.dart';

class UssdFlowScreen extends StatefulWidget {
  final Reseau reseau;
  final ActionUssd action;

  const UssdFlowScreen({
    super.key,
    required this.reseau,
    required this.action,
  });

  @override
  State<UssdFlowScreen> createState() => _UssdFlowScreenState();
}

class _UssdFlowScreenState extends State<UssdFlowScreen> {
  final Map<String, TextEditingController> _inputControllers = {};
  final TextEditingController _pinController = TextEditingController();
  bool _isSubmitting = false;
  final List<String> _placeholders = [];
  bool _needsPin = false;

  @override
  void initState() {
    super.initState();

    if (widget.action.template != null && widget.action.aBesoinParam) {
      _extractPlaceholders(widget.action.template!);
    } else if (widget.action.codeBase != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _launchImmediate(widget.action.codeBase!);
      });
    } else if (widget.action.template != null && !widget.action.aBesoinParam) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _launchImmediate(widget.action.template!);
      });
    }
  }

  void _extractPlaceholders(String template) {
    final RegExp regExp = RegExp(r'\{\{([^}]+)\}\}');
    final matches = regExp.allMatches(template);
    for (final match in matches) {
      final placeholder = match.group(1);
      if (placeholder != null) {
        if (placeholder == 'pin') {
          _needsPin = true;
        } else if (!_placeholders.contains(placeholder)) {
          _placeholders.add(placeholder);
          _inputControllers[placeholder] = TextEditingController();
        }
      }
    }
  }

  Future<void> _launchImmediate(String code) async {
    await UssdService.launchUssd(
      context,
      code,
      title: widget.action.titre,
      network: widget.reseau.nom
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickContact(TextEditingController controller) async {
    if (await FlutterContacts.permissions.request(PermissionType.read) == PermissionStatus.granted) {
      final contact = await FlutterContacts.native.showPicker();
      if (contact != null && contact.phones.isNotEmpty) {
        String number = contact.phones.first.number;
        number = number.replaceAll(RegExp(r'[\s\-\(\)]'), '');
        if (number.startsWith('+229')) {
          number = number.substring(4);
        } else if (number.startsWith('00229')) {
          number = number.substring(5);
        }
        setState(() {
          controller.text = number;
        });
      }
    }
  }

  Future<void> _executeOperation() async {
    setState(() => _isSubmitting = true);
    
    final Map<String, String> data = {};
    _inputControllers.forEach((key, controller) {
      data[key] = controller.text;
    });
    
    if (_needsPin) {
      data['pin'] = _pinController.text;
    }
    
    final code = UssdService.buildFromTemplate(
      template: widget.action.template!,
      data: data,
    );
    
    await UssdService.launchUssd(
      context, 
      code,
      title: widget.action.titre,
      network: widget.reseau.nom
    );
    
    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: onSurfaceColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.action.titre.tr(),
          style: TextStyle(color: onSurfaceColor, fontSize: 18, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (widget.action.template != null && widget.action.aBesoinParam) {
      return _buildInputForm();
    }
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(widget.reseau.couleur),
      ),
    );
  }

  Widget _buildInputForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView(
            children: [
              const SizedBox(height: 10),
              ..._placeholders.map((placeholder) {
                String label = placeholder;
                IconData icon = Icons.edit_note_rounded;
                bool isPhone = false;
                if (placeholder.toLowerCase().contains('montant')) {
                  label = 'amount_label'.tr();
                  icon = Icons.attach_money_rounded;
                } else if (placeholder.toLowerCase().contains('numero')) {
                  label = 'phone_number_label'.tr();
                  icon = Icons.phone_android_rounded;
                  isPhone = true;
                }
                return _buildField(_inputControllers[placeholder]!, label, icon, isPhone: isPhone);
              }),
              if (_needsPin)
                _buildField(_pinController, 'pin_label'.tr(), Icons.lock_outline_rounded, isPin: true),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildSubmitButton(_executeOperation),
        const SizedBox(height: 10),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, curve: Curves.easeOut);
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {bool isPin = false, bool isPhone = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            obscureText: isPin,
            keyboardType: TextInputType.number,
            style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: widget.reseau.couleur),
              suffixIcon: isPhone
                ? Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                        icon: Icon(Icons.contact_phone_rounded, color: widget.reseau.couleur),
                        onPressed: () => _pickContact(controller),
                      ),
                  )
                : null,
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: widget.reseau.couleur, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: widget.reseau.couleur.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.reseau.couleur,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                'launch_operation'.tr(), 
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, letterSpacing: 0.5)
              ),
      ),
    );
  }
}
