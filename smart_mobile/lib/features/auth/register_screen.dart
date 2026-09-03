import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      final countries = await context.read<ApiService>().countries();
      setState(() {
        _countries = countries;
        _selected = countries.firstWhere((c) => c.code == 'CI', orElse: () => countries.first);
        _loadingCountries = false;
      });
    } catch (_) {
      setState(() => _loadingCountries = false);
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
    if (_selected == null) return;
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
                  DropdownButtonFormField<CountryModel>(
                    initialValue: _selected,
                    items: _countries
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Row(
                              children: [
                                FlagCircle(flagCode: c.flagCode, size: 22),
                                const SizedBox(width: 10),
                                Expanded(child: Text(c.nameFr)),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selected = v),
                    decoration: const InputDecoration(labelText: 'Pays'),
                  ),
                  const SizedBox(height: 8),
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
