import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_money/core/theme/app_colors.dart';

/// Barre de navigation à cinq entrées.
///
/// Seules quatre d'entre elles sont des branches du [StatefulNavigationShell] :
/// « Transfert » est une action qui empile l'assistant de transfert, lequel vit
/// hors du shell. D'où la traduction entre l'index visuel (0..4) et l'index de
/// branche (0..3) faite par [_branchOf] et [_selectedVisualIndex].
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  /// Index de branche correspondant à un index visuel, `null` pour « Transfert ».
  static int? _branchOf(int visual) {
    switch (visual) {
      case 0:
        return 0; // Accueil
      case 2:
        return 1; // Échange
      case 3:
        return 2; // Paiement
      case 4:
        return 3; // Profil
      default:
        return null; // Transfert -> action
    }
  }

  int get _selectedVisualIndex {
    switch (shell.currentIndex) {
      case 0:
        return 0;
      case 1:
        return 2;
      case 2:
        return 3;
      case 3:
        return 4;
      default:
        return 0;
    }
  }

  void _onTap(BuildContext context, int visual) {
    final branch = _branchOf(visual);
    if (branch == null) {
      context.push('/transfer/destination');
      return;
    }
    shell.goBranch(branch, initialLocation: branch == shell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    const items = <_NavSpec>[
      _NavSpec(Icons.home_rounded, Icons.home_outlined, 'Accueil'),
      _NavSpec(Icons.swap_horiz_rounded, Icons.swap_horiz_rounded, 'Transfert'),
      _NavSpec(Icons.currency_exchange_rounded, Icons.currency_exchange_rounded, 'Échange'),
      _NavSpec(Icons.credit_card_rounded, Icons.credit_card_outlined, 'Paiement'),
      _NavSpec(Icons.person_rounded, Icons.person_outline, 'Profil'),
    ];

    final selected = _selectedVisualIndex;

    return Scaffold(
      body: shell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 66,
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _NavItem(
                      spec: items[i],
                      selected: i == selected,
                      onTap: () => _onTap(context, i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavSpec {
  const _NavSpec(this.activeIcon, this.icon, this.label);

  final IconData activeIcon;
  final IconData icon;
  final String label;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.spec,
    required this.selected,
    required this.onTap,
  });

  final _NavSpec spec;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: selected ? AppColors.navSelectedBg : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(selected ? spec.activeIcon : spec.icon, color: color, size: 24),
            ),
            const SizedBox(height: 3),
            Text(
              spec.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
