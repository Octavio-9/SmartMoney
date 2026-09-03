import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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
    final ops = await context.read<ApiService>().operators(code);
    setState(() {
      _ops = ops;
      _loading = false;
    });
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
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _ops.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
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
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                    ),
                  ),
                  title: Text(op.name, style: const TextStyle(fontWeight: FontWeight.w600)),
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
