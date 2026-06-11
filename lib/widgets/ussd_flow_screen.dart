import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/ussd_service.dart';
import '../data/ussd_tree.dart';

class UssdFlowScreen extends StatefulWidget {
  final String network;
  final String operation;
  final Color themeColor;

  const UssdFlowScreen({
    super.key,
    required this.network,
    required this.operation,
    required this.themeColor,
  });

  @override
  State<UssdFlowScreen> createState() => _UssdFlowScreenState();
}

class _UssdFlowScreenState extends State<UssdFlowScreen> {
  late List<dynamic> history;
  late List<String> breadcrumbs;
  final Map<int, TextEditingController> _inputControllers = {};
  final TextEditingController _pinController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final initialStep = ussdTree[widget.network]?[widget.operation];
    history = [initialStep];
    breadcrumbs = [widget.network, widget.operation];

    if (initialStep is String && !initialStep.contains('{{')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _launchImmediate(initialStep);
      });
    }
  }

  void _launchImmediate(String code) async {
    await UssdService.launchUssd(
      context, 
      code, 
      title: widget.operation, 
      network: widget.network
    );
    if (mounted) Navigator.pop(context);
  }

  void _nextStep(String title, dynamic nextData) {
    setState(() {
      history.add(nextData);
      breadcrumbs.add(title);
    });
  }

  void _goBack() {
    if (history.length > 1) {
      setState(() {
        history.removeLast();
        breadcrumbs.removeLast();
        _inputControllers.clear();
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentData = history.last;

    return Scaffold(
      backgroundColor: const Color(0xFF0A2540),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: _goBack,
        ),
        title: Text(
          breadcrumbs.join(' > '),
          style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: _buildBody(currentData),
        ),
      ),
    );
  }

  Widget _buildBody(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data.containsKey('__input__')) {
        return _buildInputForm(data);
      }
      return _buildOptionsList(data);
    }
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildOptionsList(Map<String, dynamic> options) {
    return ListView.builder(
      itemCount: options.keys.length,
      itemBuilder: (context, index) {
        final title = options.keys.elementAt(index);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              final next = options[title];
              if (next is String && !next.contains('{{')) {
                _confirmAndLaunch(title, next);
              } else {
                _nextStep(title, next);
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: widget.themeColor.withValues(alpha: 0.5), width: 1.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, color: widget.themeColor, size: 18),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1);
      },
    );
  }

  Widget _buildInputForm(Map<String, dynamic> data) {
    final List<String> inputs = List<String>.from(data['__input__']);
    final bool needsPin = data['__ussd__'].toString().contains('{{pin}}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView(
            children: [
              ...List.generate(inputs.length, (index) {
                _inputControllers[index] ??= TextEditingController();
                return _buildField(_inputControllers[index]!, inputs[index], Icons.edit_note_rounded);
              }),
              if (needsPin)
                _buildField(_pinController, 'Code PIN secret', Icons.lock_outline_rounded, isPin: true),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildSubmitButton(() async {
          String ussd = data['__ussd__'];
          for (int i = 0; i < inputs.length; i++) {
            ussd = ussd.replaceAll('{{$i}}', _inputControllers[i]!.text.trim());
          }
          if (needsPin) {
            ussd = ussd.replaceAll('{{pin}}', _pinController.text.trim());
          }
          _confirmAndLaunch(widget.operation, ussd);
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
          labelStyle: TextStyle(color: widget.themeColor.withValues(alpha: 0.7)),
          prefixIcon: Icon(icon, color: widget.themeColor),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: widget.themeColor),
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
          backgroundColor: widget.themeColor,
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
      backgroundColor: const Color(0xFF16213E),
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
            Text(code, style: TextStyle(color: widget.themeColor, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 32),
            _buildSubmitButton(() async {
              Navigator.pop(context);
              setState(() => _isSubmitting = true);
              
              // Bio-auth for sensitive transactions
              final auth = await UssdService.verifyIdentity();
              if (!mounted) return;
              
              if (auth) {
                await UssdService.launchUssd(
                  context, 
                  code, 
                  title: summary, 
                  network: widget.network
                );
                if (mounted) Navigator.pop(context);
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
