import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:smart_money/core/api/api_client.dart';
import 'package:smart_money/core/api/api_service.dart';
import 'package:smart_money/core/router/app_router.dart';
import 'package:smart_money/core/theme/app_theme.dart';
import 'package:smart_money/features/auth/auth_provider.dart';
import 'package:smart_money/features/transfer/transfer_draft.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // DateFormat exige des données de locale explicites, contrairement à
  // NumberFormat dont les symboles sont embarqués.
  await initializeDateFormatting('fr_FR', null);
  runApp(const SmartMoneyApp());
}

class SmartMoneyApp extends StatefulWidget {
  const SmartMoneyApp({super.key});

  @override
  State<SmartMoneyApp> createState() => _SmartMoneyAppState();
}

class _SmartMoneyAppState extends State<SmartMoneyApp> {
  late final ApiClient _apiClient;
  late final ApiService _apiService;
  late final AuthProvider _auth;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    _apiService = ApiService(_apiClient);
    _auth = AuthProvider(_apiClient, _apiService);
    _router = createRouter(_auth);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: _apiClient),
        Provider.value(value: _apiService),
        ChangeNotifierProvider.value(value: _auth),
        ChangeNotifierProvider(create: (_) => TransferDraft()),
      ],
      child: MaterialApp.router(
        title: 'Smart Money',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        routerConfig: _router,
      ),
    );
  }
}
