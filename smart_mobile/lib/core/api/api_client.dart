import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smart_money/core/config.dart';

class ApiClient {
  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Dio get dio => _dio;

  Future<void> saveToken(String token) =>
      _storage.write(key: 'auth_token', value: token);

  Future<String?> getToken() => _storage.read(key: 'auth_token');

  Future<void> clearToken() => _storage.delete(key: 'auth_token');

  String extractError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      if (data is Map && data['errors'] is Map) {
        final errors = data['errors'] as Map;
        if (errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) return first.first.toString();
        }
      }
      // Sans réponse exploitable du serveur, error.message est un texte anglais
      // technique (« Failed host lookup… ») qui finissait affiché tel quel.
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Le serveur met trop de temps à répondre. Vérifiez votre connexion puis réessayez.';
        case DioExceptionType.connectionError:
          return 'Pas de connexion internet. Vérifiez votre réseau puis réessayez.';
        case DioExceptionType.badResponse:
          return 'Le serveur a rencontré une erreur (${error.response?.statusCode}). Réessayez dans un instant.';
        default:
          return 'Erreur réseau. Réessayez dans un instant.';
      }
    }
    return error.toString();
  }
}
