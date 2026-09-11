import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_money/core/theme/app_colors.dart';
import 'package:smart_money/features/auth/auth_provider.dart';
import 'package:smart_money/shared/widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  final _pages = const [
    (
      Icons.send_rounded,
      'Envoyez de l\'argent',
      'Transférez facilement vers vos proches à travers plusieurs pays.',
    ),
    (
      Icons.account_balance_wallet_rounded,
      'Portefeuille intelligent',
      'Suivez votre solde en temps réel après chaque envoi ou réception.',
    ),
    (
      Icons.mobile_friendly_rounded,
      'Retirez via mobile money',
      'Choisissez votre opérateur local et retirez en quelques secondes.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('Passer'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) {
                    final page = _pages[i];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(page.$1, size: 56, color: AppColors.primary),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          page.$2,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page.$3,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _index == i ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _index == i ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: _index == _pages.length - 1 ? 'Commencer' : 'Suivant',
                onPressed: () {
                  if (_index == _pages.length - 1) {
                    _finish();
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _finish() async {
    await context.read<AuthProvider>().completeOnboarding();
    if (mounted) context.go('/login');
  }
}
