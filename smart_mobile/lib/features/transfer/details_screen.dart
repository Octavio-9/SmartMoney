import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_money/core/api/api_client.dart';
import 'package:smart_money/core/api/api_service.dart';
import 'package:smart_money/core/theme/app_colors.dart';
import 'package:smart_money/features/auth/auth_provider.dart';
import 'package:smart_money/features/transfer/transfer_draft.dart';
import 'package:smart_money/shared/widgets/primary_button.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final _phone = TextEditingController();
  final _amount = TextEditingController();
  bool _looking = false;
  String? _lookupError;

  @override
  void dispose() {
    _phone.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _lookup() async {
    final phone = _phone.text.trim();
    if (phone.isEmpty) return;
    setState(() {
      _looking = true;
      _lookupError = null;
    });
    try {
      final recipient = await context.read<ApiService>().lookupRecipient(phone);
      if (!mounted) return;
      context.read<TransferDraft>().setRecipient(recipient, phone: phone);
    } catch (e) {
      if (!mounted) return;
      context.read<TransferDraft>().setRecipient(null, phone: phone);
      setState(() => _lookupError = context.read<ApiClient>().extractError(e));
    } finally {
      if (mounted) setState(() => _looking = false);
    }
  }

  void _continue() {
    final draft = context.read<TransferDraft>();
    final amount = double.tryParse(_amount.text.replaceAll(',', '.')) ?? 0;
    if (draft.recipient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vérifiez le numéro du destinataire')),
      );
      return;
    }
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrez un montant valide')),
      );
      return;
    }
    draft.setAmount(amount);
    context.push('/transfer/confirm');
  }

  @override
  Widget build(BuildContext context) {
    final draft = context.watch<TransferDraft>();
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('Destinataire')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Méthode de retrait', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(draft.recipientOperator?.name ?? '-'),
          ),
          const SizedBox(height: 20),
          const Text('Numéro du destinataire', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(hintText: 'Ex: 0700000002'),
                  onSubmitted: (_) => _lookup(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _looking ? null : _lookup,
                style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                icon: _looking
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.search, color: Colors.white),
              ),
            ],
          ),
          if (_lookupError != null) ...[
            const SizedBox(height: 8),
            Text(_lookupError!, style: const TextStyle(color: AppColors.danger)),
          ],
          if (draft.recipient != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.accent,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Destinataire confirmé', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        Text(
                          draft.recipient!.fullName,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        Text(draft.recipient!.phone, style: const TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          const Text('Montant à envoyer', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: '0',
              suffixText: user?.currency ?? '',
              prefixIcon: const Icon(Icons.payments_outlined, color: AppColors.accent),
            ),
          ),
          const SizedBox(height: 32),
          PrimaryButton(label: 'Continuer', onPressed: _continue, color: AppColors.accent),
        ],
      ),
    );
  }
}
