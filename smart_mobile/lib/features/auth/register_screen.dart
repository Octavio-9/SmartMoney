import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_money/core/api/api_client.dart';
import 'package:smart_money/core/api/api_service.dart';
import 'package:smart_money/core/models/models.dart';
import 'package:smart_money/core/theme/app_colors.dart';
import 'package:smart_money/features/auth/auth_provider.dart';
import 'package:smart_money/shared/widgets/flag_circle.dart';
import 'package:smart_money/shared/widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  List<CountryModel> _countries = [];
  CountryModel? _selected;
  bool _loading = false;
  bool _loadingCountries = true;
  String? _countriesError;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    setState(() {
      _loadingCountries = true;
      _countriesError = null;
    });
    try {
      final countries = await context.read<ApiService>().countries();
      if (!mounted) return;
      setState(() {
        _countries = countries;
        _selected = countries.firstWhere((c) => c.code == 'CI', orElse: () => countries.first);
        _loadingCountries = false;
      });
    } catch (e) {
      if (!mounted) return;
      // Sans ce message, un échec réseau laissait le sélecteur vide et le
      // bouton « S'inscrire » sans effet, sans rien indiquer à l'utilisateur.
      setState(() {
        _countriesError = context.read<ApiClient>().extractError(e);
        _loadingCountries = false;
      });
    }
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selected == null) {
      // Auparavant la méthode sortait sans rien dire : le bouton semblait mort.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisissez votre pays pour continuer.')),
      );
      return;
    }
    setState(() => _loading = true);
    final ok = await context.read<AuthProvider>().register(
          firstName: _first.text.trim(),
          lastName: _last.text.trim(),
          phone: _phone.text.trim(),
          password: _password.text,
          countryCode: _selected!.code,
        );
    setState(() => _loading = false);
    if (!mounted) return;
    if (ok) {
      context.go('/home');
    } else {
      final err = context.read<AuthProvider>().error ?? 'Inscription impossible';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  /// Les pays couverts sont montrés en entier plutôt que repliés dans un menu :
  /// la couverture est un argument de l'application, pas un détail de formulaire.
  Widget _countryPicker() {
    if (_countriesError != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.cloud_off, size: 18, color: AppColors.textSecondary),
                SizedBox(width: 8),
                Text(
                  'Pays indisponibles',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _countriesError!,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _loadCountries,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Pays couverts',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.navSelectedBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_countries.length}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Sélectionnez le vôtre. La devise du portefeuille en découle.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _countries.map(_countryChip).toList(),
        ),
      ],
    );
  }

  Widget _countryChip(CountryModel c) {
    final selected = _selected?.code == c.code;

    return InkWell(
      onTap: () => setState(() => _selected = c),
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FlagCircle(flagCode: c.flagCode, size: 26),
            const SizedBox(width: 8),
            Text(
              c.nameFr,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: selected ? Colors.white : AppColors.text,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              c.currency,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte')),
      body: _loadingCountries
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  TextField(
                    controller: _first,
                    decoration: const InputDecoration(labelText: 'Prénom'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _last,
                    decoration: const InputDecoration(labelText: 'Nom'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Téléphone'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Mot de passe'),
                  ),
                  const SizedBox(height: 12),
                  _countryPicker(),
                  const SizedBox(height: 12),
                  const Text(
                    'Un portefeuille avec 1 000 000 de solde initial sera créé.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(label: "S'inscrire", onPressed: _submit, loading: _loading),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Déjà un compte ? Se connecter'),
                  ),
                ],
              ),
            ),
    );
  }
}
