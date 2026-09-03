import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_money/core/api/api_service.dart';
import 'package:smart_money/core/models/models.dart';
import 'package:smart_money/core/theme/app_colors.dart';
import 'package:smart_money/features/auth/auth_provider.dart';
import 'package:smart_money/shared/widgets/flag_circle.dart';

/// Une ligne d'historique, transfert ou retrait confondus.
class _Activity {
  _Activity({
    required this.label,
    required this.amount,
    required this.currency,
    required this.date,
    required this.icon,
    required this.incoming,
  });

  final String label;
  final double amount;
  final String currency;
  final DateTime? date;
  final IconData icon;
  final bool incoming;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CountryModel> _countries = [];
  List<_Activity> _activities = [];
  bool _hideBalance = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().refreshUser();
      _load();
    });
  }

  Future<void> _load() async {
    final api = context.read<ApiService>();
    try {
      final results = await Future.wait([
        api.countries(),
        api.transfers(),
        api.withdrawals(),
        api.deposits(),
        api.billPayments(),
      ]);

      final countries = results[0] as List<CountryModel>;
      final transfers = results[1] as List<TransferModel>;
      final withdrawals = results[2] as List<WithdrawalModel>;
      final deposits = results[3] as List<DepositModel>;
      final payments = results[4] as List<BillPaymentModel>;

      final activities = <_Activity>[
        for (final t in transfers)
          _Activity(
            label: t.direction == 'sent'
                ? 'Envoi à ${t.recipientName ?? t.recipientPhone ?? ''}'.trim()
                : 'Réception de ${t.senderName ?? ''}'.trim(),
            amount: t.direction == 'sent' ? t.amountSent : t.amountReceived,
            currency: t.direction == 'sent' ? t.senderCurrency : t.recipientCurrency,
            date: DateTime.tryParse(t.createdAt ?? ''),
            icon: t.direction == 'sent' ? Icons.north_east : Icons.south_west,
            incoming: t.direction != 'sent',
          ),
        for (final w in withdrawals)
          _Activity(
            label: 'Retrait ${w.operatorCode}',
            amount: w.amount,
            currency: w.currency,
            date: DateTime.tryParse(w.createdAt ?? ''),
            icon: Icons.outbox_outlined,
            incoming: false,
          ),
        for (final d in deposits)
          _Activity(
            label: 'Rechargement ${d.operatorCode}',
            amount: d.amount,
            currency: d.currency,
            date: DateTime.tryParse(d.createdAt ?? ''),
            icon: Icons.add_card_outlined,
            incoming: true,
          ),
        for (final p in payments)
          _Activity(
            label: 'Paiement ${p.billerName}',
            amount: p.amount,
            currency: p.currency,
            date: DateTime.tryParse(p.createdAt ?? ''),
            icon: Icons.receipt_long,
            incoming: false,
          ),
      ]..sort((a, b) {
          final da = a.date, db = b.date;
          if (da == null || db == null) return 0;
          return db.compareTo(da);
        });

      if (!mounted) return;
      setState(() {
        _countries = countries;
        _activities = activities.take(3).toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _refresh() async {
    await context.read<AuthProvider>().refreshUser();
    await _load();
  }

  /// « 1000000 » -> « 1.000.000 », comme sur la maquette.
  String _formatAmount(double value) =>
      NumberFormat('#,##0', 'en_US').format(value).replaceAll(',', '.');

  /// XOF et XAF s'écrivent « FCFA » dans l'usage courant.
  String _currencyLabel(String code) =>
      (code == 'XOF' || code == 'XAF') ? 'FCFA' : code;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final balance = user?.wallet?.balance ?? 0;
    final currency = user?.wallet?.currency ?? user?.currency ?? '';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              _header(context),
              const SizedBox(height: 20),
              _balanceCard(balance, currency),
              const SizedBox(height: 18),
              _offersCard(context),
              const SizedBox(height: 26),
              const Text(
                'Pays couverts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              _countriesRow(),
              const SizedBox(height: 26),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Transactions récentes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () => context.push('/history'),
                    child: const Text(
                      'Voir plus',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              _activityList(currency),
            ],
          ),
        ),
      ),
    );
  }

  /// Le profil n'est plus accessible d'ici : il a son propre onglet.
  Widget _header(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Smart Money',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.balanceStart,
            ),
          ),
        ),
        IconButton(
          onPressed: () => context.push('/notifications'),
          icon: const Icon(Icons.notifications_none_rounded),
          color: AppColors.balanceStart,
          tooltip: 'Notifications',
        ),
        IconButton(
          onPressed: () => context.push('/support'),
          icon: const Icon(Icons.headset_mic_outlined),
          color: AppColors.balanceStart,
          tooltip: 'Support',
        ),
      ],
    );
  }

  Widget _balanceCard(double balance, String currency) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.balanceStart, AppColors.balanceEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Solde', style: TextStyle(color: Colors.white70, fontSize: 15)),
                const SizedBox(height: 6),
                Text(
                  _hideBalance ? '••••••' : '${_formatAmount(balance)}F',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _currencyLabel(currency),
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _iconAction(Icons.refresh, 'Actualiser', _refresh),
                    const SizedBox(width: 18),
                    _iconAction(
                      _hideBalance ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      _hideBalance ? 'Afficher le solde' : 'Masquer le solde',
                      () => setState(() => _hideBalance = !_hideBalance),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              _balanceButton(Icons.add, 'Ajouter', () => context.push('/topup')),
              const SizedBox(height: 12),
              _balanceButton(Icons.remove, 'Retirer', () => context.push('/withdraw')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconAction(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, color: Colors.white70, size: 22),
        ),
      ),
    );
  }

  Widget _balanceButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 92,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _offersCard(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/offers'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.offerStart, AppColors.offerEnd],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.local_offer_outlined, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Offres Partenaires',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Découvrez nos partenaires et leurs offres exclusives',
                    style: TextStyle(color: Colors.white70, height: 1.35),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _countriesRow() {
    if (_loading) {
      return const SizedBox(
        height: 88,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (_countries.isEmpty) {
      return const Text(
        'Liste des pays indisponible.',
        style: TextStyle(color: AppColors.textSecondary),
      );
    }

    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _countries.length,
        separatorBuilder: (_, _) => const SizedBox(width: 18),
        itemBuilder: (_, i) {
          final c = _countries[i];
          return SizedBox(
            width: 76,
            child: Column(
              children: [
                FlagCircle(flagCode: c.flagCode, size: 46),
                const SizedBox(height: 8),
                Text(
                  c.nameFr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _activityList(String currency) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (_activities.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text(
          'Aucune transaction pour le moment.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return Column(
      children: [
        for (final a in _activities)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    a.icon,
                    size: 20,
                    color: a.incoming ? AppColors.accent : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (a.date != null)
                        Text(
                          DateFormat('d MMM y', 'fr_FR').format(a.date!),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  '${a.incoming ? '+' : '-'}${_formatAmount(a.amount)} ${_currencyLabel(a.currency)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: a.incoming ? AppColors.accent : AppColors.text,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
