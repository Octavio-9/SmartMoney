import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_money/core/theme/app_colors.dart';
import 'package:smart_money/features/auth/auth_provider.dart';
import 'package:smart_money/features/transfer/transfer_draft.dart';
import 'package:smart_money/shared/widgets/flag_circle.dart';
import 'package:smart_money/shared/widgets/primary_button.dart';

class CorridorScreen extends StatelessWidget {
  const CorridorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final draft = context.watch<TransferDraft>();
    final dest = draft.destination;

    return Scaffold(
      appBar: AppBar(title: const Text('Résumé du corridor')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _CountryCard(
                    title: 'Origine',
                    name: user?.country?.nameFr ?? user?.countryCode ?? '',
                    flag: user?.country?.flagCode ?? 'ci',
                    currency: user?.currency ?? '',
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: 32),
                ),
                Expanded(
                  child: _CountryCard(
                    title: 'Destination',
                    name: dest?.nameFr ?? '',
                    flag: dest?.flagCode ?? 'sn',
                    currency: dest?.currency ?? '',
                  ),
                ),
              ],
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Choisir mon opérateur',
              onPressed: () => context.push('/transfer/operators'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountryCard extends StatelessWidget {
  const _CountryCard({
    required this.title,
    required this.name,
    required this.flag,
    required this.currency,
  });

  final String title;
  final String name;
  final String flag;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 10),
          FlagCircle(flagCode: flag, size: 48),
          const SizedBox(height: 10),
          Text(name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(currency, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
