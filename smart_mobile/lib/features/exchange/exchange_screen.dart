import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_money/core/api/api_client.dart';
import 'package:smart_money/core/api/api_service.dart';
import 'package:smart_money/core/models/models.dart';
import 'package:smart_money/core/theme/app_colors.dart';
import 'package:smart_money/features/auth/auth_provider.dart';

/// Convertisseur de devises.
///
/// Aucun mouvement de fonds : la table `wallets` impose un portefeuille unique
/// par utilisateur, dans la devise de son pays. L'écran calcule et affiche une
/// conversion à partir des taux réels de l'API, avec la même formule que
/// TransferService — montant × taux, arrondi à deux décimales.
class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({super.key});

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  final _amount = TextEditingController(text: '10000');
  List<ExchangeRateModel> _rates = [];
  ExchangeRateModel? _target;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _amount.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final rates = await context.read<ApiService>().exchangeRates();
      if (!mounted) return;
      setState(() {
        _rates = rates;
        _target = rates.isNotEmpty ? rates.first : null;
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

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  double get _parsedAmount =>
      double.tryParse(_amount.text.replaceAll(',', '.')) ?? 0;

  String _fmt(double v) => NumberFormat('#,##0.##', 'fr_FR').format(v);

  @override
  Widget build(BuildContext context) {
    final base = context.watch<AuthProvider>().user?.currency ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Échange')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _errorView()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    children: [
                      _inputCard(base),
                      const SizedBox(height: 16),
                      _resultCard(base),
                      const SizedBox(height: 28),
                      Text(
                        'Tous les taux depuis $base',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      ..._rates.map((r) => _rateRow(base, r)),
                      const SizedBox(height: 24),
                      _disclaimer(),
                    ],
                  ),
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

  Widget _inputCard(String base) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Vous convertissez', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              suffixText: base,
              suffixStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Text('Vers', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ExchangeRateModel>(
                    value: _target,
                    isExpanded: true,
                    items: _rates
                        .map((r) => DropdownMenuItem(
                              value: r,
                              child: Text(
                                r.currency,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _target = v),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resultCard(String base) {
    final target = _target;
    final converted = target == null
        ? 0.0
        : double.parse((_parsedAmount * target.rate).toStringAsFixed(2));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.balanceStart, AppColors.balanceEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Vous obtenez', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            target == null ? '—' : '${_fmt(converted)} ${target.currency}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (target != null) ...[
            const SizedBox(height: 10),
            Text(
              '1 $base = ${_fmt(target.rate)} ${target.currency}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Widget _rateRow(String base, ExchangeRateModel r) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              r.currency,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              '1 $base',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '${_fmt(r.rate)} ${r.currency}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _disclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.navSelectedBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: AppColors.primary),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Conversion indicative. Votre portefeuille reste dans sa devise '
              'd\'origine : aucun fonds n\'est déplacé. Ces taux sont ceux '
              'appliqués à vos transferts internationaux.',
              style: TextStyle(color: AppColors.primary, fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
