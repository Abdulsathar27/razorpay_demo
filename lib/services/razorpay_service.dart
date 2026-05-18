import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  late Razorpay razorpay;

  void initialize({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onError,
    required Function(ExternalWalletResponse) onWallet,
  }) {
    razorpay = Razorpay();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);

    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onError);

    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onWallet);
  }

  void openPayment(Map<String, dynamic> options) {
    razorpay.open(options);
  }

  void dispose() {
    razorpay.clear();
  }
}
