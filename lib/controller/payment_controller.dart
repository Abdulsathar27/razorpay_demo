import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:razorpaydemo/services/razorpay_service.dart';
import 'package:razorpaydemo/views/success_screen.dart';



class PaymentController extends ChangeNotifier {

  final RazorpayService _razorpayService =
  RazorpayService();

  bool isLoading = false;
   bool isSuccess = false;

  void paymentSuccess() {
    isSuccess = true;
    notifyListeners();
  }

  PaymentController() {

    _initializeRazorpay();
  }

  void _initializeRazorpay() {

    _razorpayService.initialize(

      onSuccess: _handlePaymentSuccess,

      onError: _handlePaymentError,

      onWallet: _handleExternalWallet,
    );
  }

  late BuildContext _context;

  void openPayment({
    required BuildContext context,
  }) {

    _context = context;

    isLoading = true;

    notifyListeners();

    _razorpayService.openPayment();
  }

  void _handlePaymentSuccess(
      PaymentSuccessResponse response) {

    isLoading = false;

    notifyListeners();

    Navigator.pushReplacement(

      _context,

      MaterialPageRoute(
        builder: (_) => const SuccessScreen(),
      ),
    );
  }

  void _handlePaymentError(
      PaymentFailureResponse response) {

    isLoading = false;

    notifyListeners();

    ScaffoldMessenger.of(_context).showSnackBar(

      SnackBar(
        content: Text(
          response.message ?? "Payment Failed",
        ),
      ),
    );
  }

  void _handleExternalWallet(
      ExternalWalletResponse response) {}

  @override
  void dispose() {

    _razorpayService.dispose();

    super.dispose();
  }
}