import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_money/core/api/api_client.dart';
import 'package:smart_money/core/api/api_service.dart';
import 'package:smart_money/core/models/models.dart';
import 'package:smart_money/core/theme/app_colors.dart';
import 'package:smart_money/features/auth/auth_provider.dart';
import 'package:smart_money/features/transfer/transfer_draft.dart';

class OperatorScreen extends StatefulWidget {
  const OperatorScreen({super.key, required this.forRecipient});

  final bool forRecipient;

  @override
  State<OperatorScreen> createState() => _OperatorScreenState();
}

class _OperatorScreenState extends State<OperatorScreen> {
  List<OperatorModel> _ops = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final draft = context.read<TransferDraft>();
    final user = context.read<AuthProvider>().user;
    final code = widget.forRecipient
        ? (draft.destination?.code ?? '')
        : (user?.countryCode ?? '');
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final ops = await context.read<ApiService>().operators(code);
      if (!mounted) return;
      setState(() {
        _ops = ops;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      // Même défaut que l'écran Destination : sans ce catch, un raté réseau
      // figeait l'écran sur un spinner éternel.
      setState(() {
        _error = context.read<ApiClient>().extractError(e);
        _loading = false;
      });
    }
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 40,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            const Text(
              'Impossible de charger les opérateurs',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.forRecipient
        ? 'Opérateur du destinataire'
        : 'Votre opérateur';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _errorView()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _ops.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final op = _ops[i];
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      op.name.substring(0, 1),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  title: Text(
                    op.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(op.code),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    final draft = context.read<TransferDraft>();
                    if (widget.forRecipient) {
                      draft.setRecipientOperator(op);
                      context.push('/transfer/details');
                    } else {
                      draft.setSenderOperator(op);
                      context.push('/transfer/operators?for=recipient');
                    }
                  },
                );
              },
            ),
    );
  }
}
