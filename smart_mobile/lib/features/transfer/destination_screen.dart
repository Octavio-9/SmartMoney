import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_money/core/api/api_client.dart';
import 'package:smart_money/core/api/api_service.dart';
import 'package:smart_money/core/models/models.dart';
import 'package:smart_money/core/theme/app_colors.dart';
import 'package:smart_money/features/transfer/transfer_draft.dart';
import 'package:smart_money/shared/widgets/flag_circle.dart';

class DestinationScreen extends StatefulWidget {
  const DestinationScreen({super.key});

  @override
  State<DestinationScreen> createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationScreen> {
  List<CountryModel> _countries = [];
  List<CountryModel> _filtered = [];
  bool _loading = true;
  String? _error;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await context.read<ApiService>().countries();
      if (!mounted) return;
      setState(() {
        _countries = list;
        _filtered = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      // Sans ce catch, un seul raté réseau laissait _loading à true pour
      // toujours : spinner éternel, aucun message, aucun moyen de réessayer.
      setState(() {
        _error = context.read<ApiClient>().extractError(e);
        _loading = false;
      });
    }
  }

  void _onSearch(String q) {
    final query = q.toLowerCase();
    setState(() {
      _filtered = _countries.where((c) {
        return c.nameFr.toLowerCase().contains(query) ||
            c.currency.toLowerCase().contains(query) ||
            c.code.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 40,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            const Text(
              'Impossible de charger les pays',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Image.asset('assets/images/logo.png', height: 36),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Text(
              'Sélectionner la Destination',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _search,
              onChanged: _onSearch,
              decoration: const InputDecoration(
                hintText: 'Rechercher par pays, code devise...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? _errorView()
                : ListView.separated(
                    itemCount: _filtered.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final c = _filtered[i];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        leading: FlagCircle(flagCode: c.flagCode, size: 44),
                        title: Text(
                          c.nameFr,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${c.currency} - ${c.currencyName}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: AppColors.textSecondary,
                        ),
                        onTap: () {
                          context.read<TransferDraft>().setDestination(c);
                          context.push('/transfer/corridor');
                        },
                      );
                    },
                  ),
          ),
          Container(
            width: double.infinity,
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: const Text(
              'Choisissez le pays de votre destinataire',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
