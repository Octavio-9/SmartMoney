import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:smart_money/core/api/api_service.dart';
import 'package:smart_money/core/models/models.dart';
import 'package:smart_money/core/theme/app_colors.dart';
import 'package:smart_money/shared/widgets/money_text.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<TransferModel> _transfers = [];
  List<WithdrawalModel> _withdrawals = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final api = context.read<ApiService>();
    final results = await Future.wait([
      api.transfers(),
      api.withdrawals(),
    ]);
    setState(() {
      _transfers = results[0] as List<TransferModel>;
      _withdrawals = results[1] as List<WithdrawalModel>;
      _loading = false;
    });
  }

  Future<void> _openReceipt(TransferModel t) async {
    final bytes = await context.read<ApiService>().downloadReceipt(t.id);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/recu_${t.reference}.pdf');
    await file.writeAsBytes(bytes, flush: true);
    await OpenFilex.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('Transferts', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 8),
                  if (_transfers.isEmpty)
                    const Text('Aucun transfert', style: TextStyle(color: AppColors.textSecondary)),
                  ..._transfers.map((t) {
                    final sent = t.direction == 'sent';
                    return Card(
                      elevation: 0,
                      color: AppColors.background,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: (sent ? AppColors.primary : AppColors.accent)
                              .withValues(alpha: 0.15),
                          child: Icon(
                            sent ? Icons.arrow_upward : Icons.arrow_downward,
                            color: sent ? AppColors.primary : AppColors.accent,
                          ),
                        ),
                        title: Text(sent ? (t.recipientName ?? 'Envoi') : (t.senderName ?? 'Réception')),
                        subtitle: Text(t.reference),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            MoneyText(
                              amount: sent ? t.amountSent : t.amountReceived,
                              currency: sent ? t.senderCurrency : t.recipientCurrency,
                              style: const TextStyle(fontSize: 13),
                              color: sent ? AppColors.danger : AppColors.accent,
                            ),
                            if (sent)
                              GestureDetector(
                                onTap: () => _openReceipt(t),
                                child: const Text('PDF', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  const Text('Retraits', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 8),
                  if (_withdrawals.isEmpty)
                    const Text('Aucun retrait', style: TextStyle(color: AppColors.textSecondary)),
                  ..._withdrawals.map(
                    (w) => Card(
                      elevation: 0,
                      color: AppColors.background,
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0x1A277A1F),
                          child: Icon(Icons.outbox, color: AppColors.accent),
                        ),
                        title: Text(w.operatorCode),
                        subtitle: Text(w.reference),
                        trailing: MoneyText(
                          amount: w.amount,
                          currency: w.currency,
                          style: const TextStyle(fontSize: 13),
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
