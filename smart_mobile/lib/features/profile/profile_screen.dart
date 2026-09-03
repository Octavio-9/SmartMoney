import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_money/core/theme/app_colors.dart';
import 'package:smart_money/features/auth/auth_provider.dart';
import 'package:smart_money/shared/widgets/flag_circle.dart';
import 'package:smart_money/shared/widgets/money_text.dart';
import 'package:smart_money/shared/widgets/primary_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    (user?.firstName.isNotEmpty == true ? user!.firstName[0] : 'S').toUpperCase(),
                    style: const TextStyle(fontSize: 28, color: AppColors.primary, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 12),
                Text(user?.fullName ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                Text(user?.phone ?? '', style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (user?.country != null)
            ListTile(
              leading: FlagCircle(flagCode: user!.country!.flagCode, size: 28),
              title: Text(user.country!.nameFr),
              subtitle: Text('${user.currency} · ${user.country!.dialCode}'),
            ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.accent),
            title: const Text('Solde'),
            trailing: MoneyText(
              amount: user?.wallet?.balance ?? 0,
              currency: user?.currency ?? '',
              style: const TextStyle(fontSize: 14),
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Se déconnecter',
            color: AppColors.danger,
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
