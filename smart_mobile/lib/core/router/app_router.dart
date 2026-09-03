import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_money/core/theme/app_colors.dart';
import 'package:smart_money/features/auth/auth_provider.dart';
import 'package:smart_money/features/auth/login_screen.dart';
import 'package:smart_money/features/auth/register_screen.dart';
import 'package:smart_money/features/coming_soon/coming_soon_screen.dart';
import 'package:smart_money/features/deposit/deposit_screen.dart';
import 'package:smart_money/features/exchange/exchange_screen.dart';
import 'package:smart_money/features/history/history_screen.dart';
import 'package:smart_money/features/home/home_screen.dart';
import 'package:smart_money/features/home/home_shell.dart';
import 'package:smart_money/features/onboarding/onboarding_screen.dart';
import 'package:smart_money/features/payment/payment_screen.dart';
import 'package:smart_money/features/profile/profile_screen.dart';
import 'package:smart_money/features/splash/splash_screen.dart';
import 'package:smart_money/features/support/support_screen.dart';
import 'package:smart_money/features/transfer/confirm_screen.dart';
import 'package:smart_money/features/transfer/corridor_screen.dart';
import 'package:smart_money/features/transfer/destination_screen.dart';
import 'package:smart_money/features/transfer/details_screen.dart';
import 'package:smart_money/features/transfer/operator_screen.dart';
import 'package:smart_money/features/transfer/success_screen.dart';
import 'package:smart_money/features/withdraw/withdraw_screen.dart';

GoRouter createRouter(AuthProvider auth) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: auth,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (auth.loading || loc == '/splash') return null;

      final loggedIn = auth.user != null;
      final onboarding = !auth.onboardingDone;
      final isAuthRoute = loc == '/login' || loc == '/register';
      final isOnboarding = loc == '/onboarding';

      if (onboarding && !isOnboarding) return '/onboarding';
      if (!onboarding && isOnboarding) {
        return loggedIn ? '/home' : '/login';
      }
      if (!loggedIn && !isAuthRoute && !isOnboarding) return '/login';
      if (loggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),

      // Les quatre branches correspondent aux onglets Accueil / Échange /
      // Paiement / Profil. L'onglet « Transfert » n'est pas une branche : il
      // empile l'assistant, voir HomeShell.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => HomeShell(shell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/exchange', builder: (_, _) => const ExchangeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/payment', builder: (_, _) => const PaymentScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
          ]),
        ],
      ),

      // Écrans empilés, atteints depuis l'en-tête ou les cartes de l'accueil.
      GoRoute(path: '/history', builder: (_, _) => const HistoryScreen()),
      GoRoute(path: '/support', builder: (_, _) => const SupportScreen()),
      GoRoute(
        path: '/notifications',
        builder: (_, _) => const ComingSoonScreen(
          title: 'Notifications',
          description:
              'Vous serez alerté ici de vos transferts reçus et de vos retraits confirmés.',
          icon: Icons.notifications_none_rounded,
          showBack: true,
        ),
      ),
      GoRoute(
        path: '/offers',
        builder: (_, _) => const ComingSoonScreen(
          title: 'Offres Partenaires',
          description:
              'Les offres exclusives de nos partenaires mobile money seront présentées ici.',
          icon: Icons.local_offer_outlined,
          showBack: true,
        ),
      ),
      GoRoute(path: '/topup', builder: (_, _) => const DepositScreen()),

      GoRoute(path: '/transfer/destination', builder: (_, _) => const DestinationScreen()),
      GoRoute(path: '/transfer/corridor', builder: (_, _) => const CorridorScreen()),
      GoRoute(
        path: '/transfer/operators',
        builder: (_, state) {
          final forRecipient = state.uri.queryParameters['for'] == 'recipient';
          return OperatorScreen(forRecipient: forRecipient);
        },
      ),
      GoRoute(path: '/transfer/details', builder: (_, _) => const DetailsScreen()),
      GoRoute(path: '/transfer/confirm', builder: (_, _) => const ConfirmScreen()),
      GoRoute(
        path: '/transfer/success',
        builder: (_, state) {
          final id = int.tryParse(state.uri.queryParameters['id'] ?? '') ?? 0;
          return SuccessScreen(transferId: id);
        },
      ),
      GoRoute(path: '/withdraw', builder: (_, _) => const WithdrawScreen()),
    ],
    errorBuilder: (context, state) => const Scaffold(
      body: Center(
        child: Text('Page introuvable', style: TextStyle(color: AppColors.textSecondary)),
      ),
    ),
  );
}
