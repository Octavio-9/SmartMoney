import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_money/core/api/api_client.dart';
import 'package:smart_money/core/api/api_service.dart';
import 'package:smart_money/core/theme/app_colors.dart';
import 'package:smart_money/features/auth/auth_provider.dart';
import 'package:smart_money/features/transfer/transfer_draft.dart';
import 'package:smart_money/shared/widgets/money_text.dart';
import 'package:smart_money/shared/widgets/primary_button.dart';

class ConfirmScreen extends StatefulWidget {
  const ConfirmScreen({super.key});

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  bool _loading = false;

  Future<void> _confirm() async {
    setState(() => _loading = true);
    final draft = context.read<TransferDraft>();
    try {
      final transfer = await context.read<ApiService>().createTransfer(draft.toPayload());
      if (!mounted) return;
      await context.read<AuthProvider>().refreshUser();
      if (!mounted) return;
      draft.reset();
      context.go('/transfer/success?id=${transfer.id}');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<ApiClient>().extractError(e))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = context.watch<TransferDraft>();
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmation')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Facture de paiement', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _row('Destinataire', draft.recipient?.fullName ?? '-'),
            _row('Téléphone', draft.recipientPhone),
            _row('Pays', draft.destination?.nameFr ?? '-'),
            _row('Opérateur expéditeur', draft.senderOperator?.name ?? '-'),
            _row('Opérateur destinataire', draft.recipientOperator?.name ?? '-'),
            const Divider(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Vous envoyez'),
                MoneyText(amount: draft.amount, currency: user?.currency ?? ''),
              ],
            ),
            const SizedBox(height: 10),
            _row('Frais Smart Money', '0,00 ${user?.currency ?? ''}'),
            _row('Taux', '1 ${user?.currency ?? ''} ≈ ${draft.destination?.currency ?? ''}'),
            const Spacer(),
            if (_loading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 12),
                    Text('Traitement du paiement...'),
                  ],
                ),
              )
            else
              PrimaryButton(
                label: 'Confirmer le paiement',
                onPressed: _confirm,
                color: AppColors.accent,
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Flexible(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
