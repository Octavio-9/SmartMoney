import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_money/core/api/api_client.dart';
import 'package:smart_money/core/api/api_service.dart';
import 'package:smart_money/core/models/models.dart';
import 'package:smart_money/core/theme/app_colors.dart';
import 'package:smart_money/features/auth/auth_provider.dart';
import 'package:smart_money/shared/widgets/money_text.dart';
import 'package:smart_money/shared/widgets/primary_button.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  List<OperatorModel> _ops = [];
  OperatorModel? _selected;
  final _amount = TextEditingController();
  final _phone = TextEditingController();
  bool _loadingOps = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      _phone.text = user?.phone ?? '';
      _loadOps();
    });
  }

  Future<void> _loadOps() async {
    final code = context.read<AuthProvider>().user?.countryCode ?? 'CI';
    final ops = await context.read<ApiService>().operators(code);
    if (!mounted) return;
    setState(() {
      _ops = ops;
      _selected = ops.isNotEmpty ? ops.first : null;
      _loadingOps = false;
    });
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amount.text.replaceAll(',', '.')) ?? 0;
    if (_selected == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vérifiez le montant et l\'opérateur')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await context.read<ApiService>().createDeposit({
        'amount': amount,
        'operator_code': _selected!.code,
        'phone': _phone.text.trim(),
      });
      if (!mounted) return;
      await context.read<AuthProvider>().refreshUser();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rechargement effectué avec succès')),
      );
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<ApiClient>().extractError(e))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter de l\'argent')),
      body: _loadingOps
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Solde actuel', style: TextStyle(color: AppColors.textSecondary)),
                      MoneyText(
                        amount: user?.wallet?.balance ?? 0,
                        currency: user?.currency ?? '',
                        style: const TextStyle(fontSize: 22),
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Opérateur', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<OperatorModel>(
                  initialValue: _selected,
                  items: _ops
                      .map((o) => DropdownMenuItem(value: o, child: Text(o.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _selected = v),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Numéro à débiter'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _amount,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Montant',
                    suffixText: user?.currency ?? '',
                    helperText: 'Maximum 1 000 000 par rechargement',
                  ),
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: 'Confirmer le rechargement',
                  onPressed: _submit,
                  loading: _submitting,
                ),
              ],
            ),
    );
  }
}
