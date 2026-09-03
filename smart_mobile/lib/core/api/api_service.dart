import 'package:dio/dio.dart';
import 'package:smart_money/core/api/api_client.dart';
import 'package:smart_money/core/models/models.dart';

class ApiService {
  ApiService(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> login(String phone, String password) async {
    final res = await _client.dio.post('/login', data: {
      'phone': phone,
      'password': password,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final res = await _client.dio.post('/register', data: data);
    return res.data as Map<String, dynamic>;
  }

  Future<void> logout() async {
    await _client.dio.post('/logout');
  }

  Future<UserModel> me() async {
    final res = await _client.dio.get('/me');
    return UserModel.fromJson((res.data as Map)['user'] as Map<String, dynamic>);
  }

  Future<WalletModel> wallet() async {
    final res = await _client.dio.get('/wallet');
    return WalletModel.fromJson((res.data as Map)['wallet'] as Map<String, dynamic>);
  }

  Future<List<CountryModel>> countries() async {
    final res = await _client.dio.get('/countries');
    final list = (res.data as Map)['data'] as List;
    return list.map((e) => CountryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<OperatorModel>> operators(String countryCode) async {
    final res = await _client.dio.get('/operators', queryParameters: {'country': countryCode});
    final list = (res.data as Map)['data'] as List;
    return list.map((e) => OperatorModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<RecipientModel> lookupRecipient(String phone) async {
    final res = await _client.dio.get('/recipients/lookup', queryParameters: {'phone': phone});
    return RecipientModel.fromJson((res.data as Map)['recipient'] as Map<String, dynamic>);
  }

  Future<TransferModel> createTransfer(Map<String, dynamic> data) async {
    final res = await _client.dio.post('/transfers', data: data);
    return TransferModel.fromJson((res.data as Map)['transfer'] as Map<String, dynamic>);
  }

  Future<List<TransferModel>> transfers() async {
    final res = await _client.dio.get('/transfers');
    final list = (res.data as Map)['data'] as List;
    return list.map((e) => TransferModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<WithdrawalModel> createWithdrawal(Map<String, dynamic> data) async {
    final res = await _client.dio.post('/withdrawals', data: data);
    return WithdrawalModel.fromJson((res.data as Map)['withdrawal'] as Map<String, dynamic>);
  }

  Future<List<WithdrawalModel>> withdrawals() async {
    final res = await _client.dio.get('/withdrawals');
    final list = (res.data as Map)['data'] as List;
    return list.map((e) => WithdrawalModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<BillerModel>> billers() async {
    final res = await _client.dio.get('/billers');
    final list = (res.data as Map)['data'] as List;
    return list.map((e) => BillerModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<BillPaymentModel>> billPayments() async {
    final res = await _client.dio.get('/bill-payments');
    final list = (res.data as Map)['data'] as List;
    return list.map((e) => BillPaymentModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<BillPaymentModel> createBillPayment(Map<String, dynamic> data) async {
    final res = await _client.dio.post('/bill-payments', data: data);
    return BillPaymentModel.fromJson((res.data as Map)['payment'] as Map<String, dynamic>);
  }

  Future<List<ExchangeRateModel>> exchangeRates() async {
    final res = await _client.dio.get('/exchange/rates');
    final list = (res.data as Map)['data'] as List;
    return list.map((e) => ExchangeRateModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<DepositModel> createDeposit(Map<String, dynamic> data) async {
    final res = await _client.dio.post('/deposits', data: data);
    return DepositModel.fromJson((res.data as Map)['deposit'] as Map<String, dynamic>);
  }

  Future<List<DepositModel>> deposits() async {
    final res = await _client.dio.get('/deposits');
    final list = (res.data as Map)['data'] as List;
    return list.map((e) => DepositModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<int>> downloadReceipt(int transferId) async {
    final res = await _client.dio.get<List<int>>(
      '/transfers/$transferId/receipt',
      options: Options(responseType: ResponseType.bytes),
    );
    return res.data ?? [];
  }
}
