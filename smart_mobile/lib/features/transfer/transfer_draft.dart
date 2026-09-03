import 'package:flutter/foundation.dart';
import 'package:smart_money/core/models/models.dart';

class TransferDraft extends ChangeNotifier {
  CountryModel? destination;
  OperatorModel? senderOperator;
  OperatorModel? recipientOperator;
  RecipientModel? recipient;
  String recipientPhone = '';
  double amount = 0;

  void setDestination(CountryModel country) {
    destination = country;
    recipientOperator = null;
    notifyListeners();
  }

  void setSenderOperator(OperatorModel op) {
    senderOperator = op;
    notifyListeners();
  }

  void setRecipientOperator(OperatorModel op) {
    recipientOperator = op;
    notifyListeners();
  }

  void setRecipient(RecipientModel? value, {String? phone}) {
    recipient = value;
    if (phone != null) recipientPhone = phone;
    notifyListeners();
  }

  void setAmount(double value) {
    amount = value;
    notifyListeners();
  }

  void reset() {
    destination = null;
    senderOperator = null;
    recipientOperator = null;
    recipient = null;
    recipientPhone = '';
    amount = 0;
    notifyListeners();
  }

  Map<String, dynamic> toPayload() {
    return {
      'recipient_phone': recipientPhone,
      'amount': amount,
      'sender_operator': senderOperator!.code,
      'recipient_operator': recipientOperator!.code,
      'destination_country': destination!.code,
    };
  }
}
