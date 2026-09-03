import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:smart_money/core/api/api_client.dart';
import 'package:smart_money/core/api/api_service.dart';
import 'package:smart_money/core/theme/app_colors.dart';
import 'package:smart_money/shared/widgets/primary_button.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key, required this.transferId});

  final int transferId;

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  bool _opening = false;

  Future<void> _openPdf() async {
    setState(() => _opening = true);
    try {
      final bytes = await context.read<ApiService>().downloadReceipt(widget.transferId);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/recu_smart_money_${widget.transferId}.pdf');
      await file.writeAsBytes(bytes, flush: true);
      await OpenFilex.open(file.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<ApiClient>().extractError(e))),
      );
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: AppColors.accent, size: 72),
              ),
              const SizedBox(height: 24),
              const Text(
                'Paiement réussi !',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              const Text(
                'Le destinataire verra son portefeuille s\'incrémenter immédiatement.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Voir le reçu PDF',
                onPressed: _openPdf,
                loading: _opening,
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('Retour à l\'accueil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
