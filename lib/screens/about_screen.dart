import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A2540),
      appBar: AppBar(title: Text('about'.tr()), backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Zoli', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Zoli est une application conçue pour simplifier l\'accès aux codes USSD au Bénin.', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
            Text('Version: 1.0.0+2', style: const TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}
