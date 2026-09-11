import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smart_money/core/api/api_client.dart';
import 'package:smart_money/core/api/api_service.dart';
import 'package:smart_money/core/models/models.dart';
import 'package:smart_money/features/auth/auth_provider.dart';
import 'package:smart_money/features/transfer/operator_screen.dart';
import 'package:smart_money/features/transfer/transfer_draft.dart';

/// Échoue au premier appel puis réussit : une 4G qui décroche un instant.
class _FlakyApi extends ApiService {
  _FlakyApi(super.client);

  int calls = 0;

  @override
  Future<List<OperatorModel>> operators(String countryCode) async {
    calls++;
    if (calls == 1) {
      throw DioException(
        requestOptions: RequestOptions(path: '/operators'),
        type: DioExceptionType.connectionTimeout,
        message: 'Délai de connexion dépassé',
      );
    }
    return [];
  }
}

void main() {
  testWidgets('opérateurs : un échec réseau affiche une erreur, et « Réessayer » relance',
      (tester) async {
    final client = ApiClient();
    final api = _FlakyApi(client);

    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: client),
        Provider<ApiService>.value(value: api),
        ChangeNotifierProvider(create: (_) => AuthProvider(client, api)),
        ChangeNotifierProvider(create: (_) => TransferDraft()),
      ],
      child: const MaterialApp(home: OperatorScreen(forRecipient: true)),
    ));
    await tester.pumpAndSettle();

    // Avant correction : spinner éternel, pumpAndSettle expire ici.
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.textContaining('trop de temps à répondre'), findsOneWidget);

    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(api.calls, 2);
    expect(find.textContaining('trop de temps à répondre'), findsNothing);
  });
}
