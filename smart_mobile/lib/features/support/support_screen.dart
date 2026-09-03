import 'package:flutter/material.dart';
import 'package:smart_money/core/theme/app_colors.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          Text('Besoin d\'aide ?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          SizedBox(height: 12),
          Text(
            'Notre équipe Smart Money est disponible pour vous accompagner.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          SizedBox(height: 24),
          ListTile(
            leading: Icon(Icons.email_outlined, color: AppColors.primary),
            title: Text('support@smartmoney.app'),
            subtitle: Text('Email'),
          ),
          ListTile(
            leading: Icon(Icons.phone_outlined, color: AppColors.primary),
            title: Text('+225 07 00 00 00 00'),
            subtitle: Text('Téléphone'),
          ),
          ListTile(
            leading: Icon(Icons.help_outline, color: AppColors.primary),
            title: Text('FAQ'),
            subtitle: Text('Comment envoyer, retirer et télécharger un reçu PDF'),
          ),
        ],
      ),
    );
  }
}
