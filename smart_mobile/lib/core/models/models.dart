class CountryModel {
  final String code;
  final String nameFr;
  final String currency;
  final String currencyName;
  final String flagCode;
  final String dialCode;

  CountryModel({
    required this.code,
    required this.nameFr,
    required this.currency,
    required this.currencyName,
    required this.flagCode,
    required this.dialCode,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      code: json['code'] as String,
      nameFr: json['name_fr'] as String,
      currency: json['currency'] as String,
      currencyName: json['currency_name'] as String,
      flagCode: json['flag_code'] as String,
      dialCode: json['dial_code'] as String,
    );
  }
}

class OperatorModel {
  final int id;
  final String countryCode;
  final String name;
  final String code;

  OperatorModel({
    required this.id,
    required this.countryCode,
    required this.name,
    required this.code,
  });

  factory OperatorModel.fromJson(Map<String, dynamic> json) {
    return OperatorModel(
      id: json['id'] as int,
      countryCode: json['country_code'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
    );
  }
}

class WalletModel {
  final double balance;
  final String currency;

  WalletModel({required this.balance, required this.currency});

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] as String,
    );
  }
}

class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String phone;
  final String countryCode;
  final String currency;
  final CountryModel? country;
  final WalletModel? wallet;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.phone,
    required this.countryCode,
    required this.currency,
    this.country,
    this.wallet,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      fullName: json['full_name'] as String? ??
          '${json['first_name']} ${json['last_name']}',
      phone: json['phone'] as String,
      countryCode: json['country_code'] as String,
      currency: json['currency'] as String,
      country: json['country'] != null
          ? CountryModel.fromJson(json['country'] as Map<String, dynamic>)
          : null,
      wallet: json['wallet'] != null
          ? WalletModel.fromJson(json['wallet'] as Map<String, dynamic>)
          : null,
    );
  }
}

class RecipientModel {
  final int id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String phone;
  final String countryCode;
  final String currency;

  RecipientModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.phone,
    required this.countryCode,
    required this.currency,
  });

  factory RecipientModel.fromJson(Map<String, dynamic> json) {
    return RecipientModel(
      id: json['id'] as int,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
      countryCode: json['country_code'] as String,
      currency: json['currency'] as String,
    );
  }
}

class TransferModel {
  final int id;
  final String reference;
  final double amountSent;
  final double amountReceived;
  final double fee;
  final double rate;
  final String senderCurrency;
  final String recipientCurrency;
  final String senderOperator;
  final String recipientOperator;
  final String destinationCountry;
  final String status;
  final String? receiptUrl;
  final String? createdAt;
  final String direction;
  final String? senderName;
  final String? recipientName;
  final String? recipientPhone;

  TransferModel({
    required this.id,
    required this.reference,
    required this.amountSent,
    required this.amountReceived,
    required this.fee,
    required this.rate,
    required this.senderCurrency,
    required this.recipientCurrency,
    required this.senderOperator,
    required this.recipientOperator,
    required this.destinationCountry,
    required this.status,
    this.receiptUrl,
    this.createdAt,
    required this.direction,
    this.senderName,
    this.recipientName,
    this.recipientPhone,
  });

  factory TransferModel.fromJson(Map<String, dynamic> json) {
    return TransferModel(
      id: json['id'] as int,
      reference: json['reference'] as String,
      amountSent: (json['amount_sent'] as num).toDouble(),
      amountReceived: (json['amount_received'] as num).toDouble(),
      fee: (json['fee'] as num).toDouble(),
      rate: (json['rate'] as num).toDouble(),
      senderCurrency: json['sender_currency'] as String,
      recipientCurrency: json['recipient_currency'] as String,
      senderOperator: json['sender_operator'] as String,
      recipientOperator: json['recipient_operator'] as String,
      destinationCountry: json['destination_country'] as String,
      status: json['status'] as String,
      receiptUrl: json['receipt_url'] as String?,
      createdAt: json['created_at'] as String?,
      direction: json['direction'] as String? ?? 'sent',
      senderName: (json['sender'] as Map?)?['full_name'] as String?,
      recipientName: (json['recipient'] as Map?)?['full_name'] as String?,
      recipientPhone: (json['recipient'] as Map?)?['phone'] as String?,
    );
  }
}

class WithdrawalModel {
  final int id;
  final String reference;
  final double amount;
  final String currency;
  final String operatorCode;
  final String phone;
  final String status;
  final String? createdAt;

  WithdrawalModel({
    required this.id,
    required this.reference,
    required this.amount,
    required this.currency,
    required this.operatorCode,
    required this.phone,
    required this.status,
    this.createdAt,
  });

  factory WithdrawalModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalModel(
      id: json['id'] as int,
      reference: json['reference'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      operatorCode: json['operator_code'] as String,
      phone: json['phone'] as String,
      status: json['status'] as String,
      createdAt: json['created_at'] as String?,
    );
  }
}

class BillerModel {
  final String code;
  final String name;
  final String category;
  final String? countryCode;
  final String referenceLabel;

  BillerModel({
    required this.code,
    required this.name,
    required this.category,
    this.countryCode,
    required this.referenceLabel,
  });

  factory BillerModel.fromJson(Map<String, dynamic> json) {
    return BillerModel(
      code: json['code'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      countryCode: json['country_code'] as String?,
      referenceLabel: json['reference_label'] as String,
    );
  }
}

class BillPaymentModel {
  final int id;
  final String reference;
  final String billerCode;
  final String billerName;
  final String customerReference;
  final double amount;
  final String currency;
  final String status;
  final String? createdAt;

  BillPaymentModel({
    required this.id,
    required this.reference,
    required this.billerCode,
    required this.billerName,
    required this.customerReference,
    required this.amount,
    required this.currency,
    required this.status,
    this.createdAt,
  });

  factory BillPaymentModel.fromJson(Map<String, dynamic> json) {
    return BillPaymentModel(
      id: json['id'] as int,
      reference: json['reference'] as String,
      billerCode: json['biller_code'] as String,
      billerName: json['biller_name'] as String,
      customerReference: json['customer_reference'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      createdAt: json['created_at'] as String?,
    );
  }
}

class ExchangeRateModel {
  final String currency;
  final double rate;

  ExchangeRateModel({required this.currency, required this.rate});

  factory ExchangeRateModel.fromJson(Map<String, dynamic> json) {
    return ExchangeRateModel(
      currency: json['currency'] as String,
      rate: (json['rate'] as num).toDouble(),
    );
  }
}

class DepositModel {
  final int id;
  final String reference;
  final double amount;
  final String currency;
  final String operatorCode;
  final String phone;
  final String status;
  final String? createdAt;

  DepositModel({
    required this.id,
    required this.reference,
    required this.amount,
    required this.currency,
    required this.operatorCode,
    required this.phone,
    required this.status,
    this.createdAt,
  });

  factory DepositModel.fromJson(Map<String, dynamic> json) {
    return DepositModel(
      id: json['id'] as int,
      reference: json['reference'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      operatorCode: json['operator_code'] as String,
      phone: json['phone'] as String,
      status: json['status'] as String,
      createdAt: json['created_at'] as String?,
    );
  }
}
