import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  List<String> _placeholders = [];
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

  void _launchImmediate(String code) async {
    await UssdService.launchUssd(
      context, 
      code, 
      title: widget.action.titre, 
      network: widget.reseau.nom
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.reseau.nom} > ${widget.action.titre}',
          style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
        ),
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
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildInputForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView(
            children: [
              ..._placeholders.map((placeholder) {
                String label = placeholder;
                IconData icon = Icons.edit_note_rounded;
                if (placeholder.toLowerCase().contains('montant')) {
                  label = 'Montant (FCFA)';
                  icon = Icons.attach_money_rounded;
                } else if (placeholder.toLowerCase().contains('numero') || placeholder.toLowerCase().contains('numéro')) {
                  label = 'Numéro de téléphone';
                  icon = Icons.phone_android_rounded;
                }
                
                return _buildField(_inputControllers[placeholder]!, label, icon);
              }),
              if (_needsPin)
                _buildField(_pinController, 'Code PIN secret', Icons.lock_outline_rounded, isPin: true),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildSubmitButton(() {
          String ussd = widget.action.template!;
          for (final placeholder in _placeholders) {
            ussd = ussd.replaceAll('{{$placeholder}}', _inputControllers[placeholder]!.text.trim());
          }
          if (_needsPin) {
            ussd = ussd.replaceAll('{{pin}}', _pinController.text.trim());
          }
          _confirmAndLaunch(widget.action.titre, ussd);
        }),
      ],
    ).animate().fadeIn();
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {bool isPin = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        obscureText: isPin,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: widget.reseau.couleur.withValues(alpha: 0.7)),
          prefixIcon: Icon(icon, color: widget.reseau.couleur),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.white12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: widget.reseau.couleur),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.reseau.couleur,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.black)
            : const Text('LANCER L\'OPÉRATION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
      ),
    );
  }

  void _confirmAndLaunch(String summary, String code) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4, width: 40,
              decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 24),
            const Text('Confirmation', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Text(summary, style: const TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 8),
            Text(code, style: TextStyle(color: widget.reseau.couleur, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 32),
            _buildSubmitButton(() async {
              Navigator.pop(context);
              setState(() => _isSubmitting = true);
              
              // Bio-auth for sensitive transactions
              final auth = await UssdService.verifyIdentity();
              if (!context.mounted) return;
              
              if (auth) {
                await UssdService.launchUssd(
                  context, 
                  code, 
                  title: summary, 
                  network: widget.reseau.nom
                );
                if (context.mounted) Navigator.pop(context);
              } else {
                setState(() => _isSubmitting = false);
              }
            }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

