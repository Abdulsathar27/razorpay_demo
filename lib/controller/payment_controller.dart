import 'package:flutter/material.dart';

class PaymentProvider extends ChangeNotifier {

  bool isSuccess = false;

  void paymentSuccess() {
    isSuccess = true;
    notifyListeners();
  }
}