import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_money/core/api/api_client.dart';
import 'package:smart_money/core/api/api_service.dart';
import 'package:smart_money/core/models/models.dart';
import 'package:smart_money/core/theme/app_colors.dart';
import 'package:smart_money/features/auth/auth_provider.dart';
import 'package:smart_money/shared/widgets/primary_button.dart';

/// Libellé et icône de chaque catégorie de facturier.
const _categories = <String, (String, IconData)>{
  'electricite': ('Électricité', Icons.bolt),
  'eau': ('Eau', Icons.water_drop_outlined),
  'internet': ('Internet', Icons.wifi),
  'tv': ('Télévision', Icons.tv),
  'telephone': ('Téléphone', Icons.phone_outlined),
};

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  List<BillerModel> _billers = [];
  List<BillPaymentModel> _history = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final api = context.read<ApiService>();
      final results = await Future.wait([api.billers(), api.billPayments()]);
      if (!mounted) return;
      setState(() {
        _billers = results[0] as List<BillerModel>;
        _history = results[1] as List<BillPaymentModel>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = context.read<ApiClient>().extractError(e);
        _loading = false;
      });
    }
  }

  Future<void> _openForm(BillerModel biller) async {
    final paid = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => _PayBillSheet(biller: biller),
    );

    if (paid == true && mounted) {
      await context.read<AuthProvider>().refreshUser();
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paiement')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _errorView()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                    children: [
                      const Text(
                        'Payer une facture',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Sélectionnez un facturier disponible dans votre pays.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      ..._byCategory(),
                      if (_history.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        const Text(
                          'Paiements récents',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        ..._history.take(5).map(_historyRow),
                      ],
                    ],
                  ),
                ),
    );
  }

  List<Widget> _byCategory() {
    final grouped = <String, List<BillerModel>>{};
    for (final b in _billers) {
      grouped.putIfAbsent(b.category, () => []).add(b);
    }

    final widgets = <Widget>[];
    grouped.forEach((category, billers) {
      final meta = _categories[category] ?? (category, Icons.receipt_long);
      widgets.add(Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 6),
        child: Row(
          children: [
            Icon(meta.$2, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              meta.$1,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ));
      widgets.addAll(billers.map(_billerTile));
    });
    return widgets;
  }

  Widget _billerTile(BillerModel b) {
    final meta = _categories[b.category] ?? (b.category, Icons.receipt_long);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        onTap: () => _openForm(b),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(meta.$2, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(
                      b.referenceLabel,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _historyRow(BillPaymentModel p) {
    final date = DateTime.tryParse(p.createdAt ?? '');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_long, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.billerName, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  date != null
                      ? '${p.customerReference} · ${DateFormat('d MMM y', 'fr_FR').format(date)}'
                      : p.customerReference,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '-${NumberFormat('#,##0.##', 'fr_FR').format(p.amount)} ${p.currency}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _loading = true;
                  _error = null;
                });
                _load();
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Formulaire de paiement, présenté en feuille modale pour rester sur l'onglet.
class _PayBillSheet extends StatefulWidget {
  const _PayBillSheet({required this.biller});

  final BillerModel biller;

  @override
  State<_PayBillSheet> createState() => _PayBillSheetState();
}

class _PayBillSheetState extends State<_PayBillSheet> {
  final _reference = TextEditingController();
  final _amount = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _reference.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amount.text.replaceAll(',', '.')) ?? 0;
    if (_reference.text.trim().isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Renseignez ${widget.biller.referenceLabel.toLowerCase()} et le montant')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await context.read<ApiService>().createBillPayment({
        'biller_code': widget.biller.code,
        'customer_reference': _reference.text.trim(),
        'amount': amount,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Paiement ${widget.biller.name} effectué')),
      );
      Navigator.of(context).pop(true);
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
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Padding(
      padding: EdgeInsets.only(
        left: 22,
        right: 22,
        top: 22,
        bottom: MediaQuery.of(context).viewInsets.bottom + 22,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            widget.biller.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            'Solde disponible : ${NumberFormat('#,##0.##', 'fr_FR').format(user?.wallet?.balance ?? 0)} ${user?.currency ?? ''}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _reference,
            decoration: InputDecoration(labelText: widget.biller.referenceLabel),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Montant',
              suffixText: user?.currency ?? '',
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Payer',
            onPressed: _submit,
            loading: _submitting,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
