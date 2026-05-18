import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:razorpaydemo/services/razorpay_service.dart';
import 'package:razorpaydemo/views/success_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentController extends ChangeNotifier {
  PaymentController() {
    _initializeRazorpay();
  }

  final RazorpayService _razorpayService = RazorpayService();
  static const String _fallbackTestKey = 'rzp_test_SqlT2TDhdrDtGH';
  static const String _razorpayKey = String.fromEnvironment(
    'RAZORPAY_KEY',
    defaultValue: _fallbackTestKey,
  );
  static const String _savedKeyPref = 'razorpay_key_id';
  static const String _noMethodErrorText =
      'no appropriate payment method found';

  bool isLoading = false;
  bool isSuccess = false;
  Timer? _checkoutSafetyTimer;
  BuildContext? _context;
  String? _cachedStoredKey;

  void _initializeRazorpay() {
    _razorpayService.initialize(
      onSuccess: _handlePaymentSuccess,
      onError: _handlePaymentError,
      onWallet: _handleExternalWallet,
    );
  }

  void paymentSuccess() {
    isSuccess = true;
    notifyListeners();
  }

  Future<void> openPayment({
    required BuildContext context,
    required int amountInRupees,
    required String itemName,
    String? orderId,
  }) async {
    _context = context;
    if (isLoading) return;

    final isSupportedPlatform =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);

    if (!isSupportedPlatform) {
      final platformName = kIsWeb ? 'Web' : defaultTargetPlatform.name;
      _showMessage(
        'Razorpay checkout works only on Android/iOS in this app. Current platform: $platformName.',
      );
      return;
    }

    final key = await _resolveRazorpayKey(context);
    if (key == null) {
      _showMessage(
        'Razorpay key setup cancelled. Add a valid Key ID to continue.',
      );
      return;
    }

    if (amountInRupees <= 0) {
      _showMessage('Invalid amount. Amount must be greater than 0.');
      return;
    }

    if (kReleaseMode && key.startsWith('rzp_test_')) {
      _showMessage(
        'Release build is using a TEST key. Use a LIVE key before go-live.',
      );
      return;
    }

    final amountInSubunits = amountInRupees * 100;
    final description = '$itemName ticket';
    // For production, create an order on your backend and pass order_id in options.
    final options = <String, dynamic>{
      'key': key,
      'amount': amountInSubunits,
      'currency': 'INR',
      'name': 'Ticket Booking',
      'description': description,
      'timeout': 300,
      'retry': {'enabled': true, 'max_count': 4},
      'send_sms_hash': true,
      'theme': {'color': '#146B41'},
      'config': {
        'display': {'language': 'en'},
      },
      'notes': {'module': 'ticket_checkout', 'item': itemName},
      'prefill': {'contact': '+919876543210', 'email': 'test@razorpay.com'},
    };
    final normalizedOrderId = orderId?.trim() ?? '';
    if (normalizedOrderId.isNotEmpty) {
      options['order_id'] = normalizedOrderId;
    }
    isLoading = true;
    notifyListeners();

    try {
      _startCheckoutSafetyTimer();
      _razorpayService.openPayment(options);
    } catch (e) {
      _stopCheckoutSafetyTimer();
      isLoading = false;
      notifyListeners();
      _showMessage('Unable to open Razorpay checkout: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _stopCheckoutSafetyTimer();
    isLoading = false;
    isSuccess = true;
    notifyListeners();

    final context = _context;
    if (context == null || !context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SuccessScreen()),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _stopCheckoutSafetyTimer();
    isLoading = false;

    notifyListeners();
    final message =
        response.message?.trim().isNotEmpty == true
            ? response.message!
            : 'Payment failed';
    final normalizedMessage = message.toLowerCase();

    if (normalizedMessage.contains(_noMethodErrorText)) {
      _showMessage(
        'No payment methods available for this key/mode. In Razorpay Dashboard, check Account & Settings -> Payment Methods, use the correct Test/Live key, and pass an Order ID from backend for capture.',
      );
      return;
    }

    _showMessage('Payment failed (${response.code ?? 'unknown'}): $message');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _stopCheckoutSafetyTimer();
    isLoading = false;
    notifyListeners();
    _showMessage(
      'External wallet selected: ${response.walletName ?? 'Unknown'}',
    );
  }

  void _showMessage(String message) {
    final context = _context;
    if (context == null || !context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _isRazorpayKeyValid(String key) {
    return key.startsWith('rzp_test_') || key.startsWith('rzp_live_');
  }

  Future<String?> _resolveRazorpayKey(BuildContext context) async {
    final envKey = _razorpayKey.trim();
    if (_isRazorpayKeyValid(envKey)) {
      return envKey;
    }

    final cachedKey = _cachedStoredKey?.trim() ?? '';
    if (_isRazorpayKeyValid(cachedKey)) {
      return cachedKey;
    }

    final prefs = await SharedPreferences.getInstance();
    final storedKey = prefs.getString(_savedKeyPref)?.trim() ?? '';
    if (_isRazorpayKeyValid(storedKey)) {
      _cachedStoredKey = storedKey;
      return storedKey;
    }

    if (!context.mounted) return null;
    final enteredKey = await _promptForRazorpayKey(context);
    if (!_isRazorpayKeyValid(enteredKey ?? '')) {
      return null;
    }

    final normalizedKey = enteredKey!.trim();
    _cachedStoredKey = normalizedKey;
    await prefs.setString(_savedKeyPref, normalizedKey);
    return normalizedKey;
  }

  Future<String?> _promptForRazorpayKey(BuildContext context) async {
    final controller = TextEditingController();
    String? validationMessage;
    final enteredValue = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              title: const Text('Setup Razorpay Key'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Enter Razorpay Key ID (starts with rzp_test_ or rzp_live_).',
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      hintText: 'rzp_test_xxxxxxxx',
                      errorText: validationMessage,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final value = controller.text.trim();
                    if (!_isRazorpayKeyValid(value)) {
                      setState(() {
                        validationMessage =
                            'Please enter a valid Razorpay Key ID.';
                      });
                      return;
                    }
                    Navigator.of(dialogContext).pop(value);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
    controller.dispose();
    return enteredValue;
  }

  void _startCheckoutSafetyTimer() {
    _checkoutSafetyTimer?.cancel();
    _checkoutSafetyTimer = Timer(const Duration(seconds: 15), () {
      if (!isLoading) return;
      isLoading = false;
      notifyListeners();
      _showMessage(
        'Checkout is taking too long. Check internet, disable VPN/private DNS, and update Android System WebView/Chrome.',
      );
    });
  }

  void _stopCheckoutSafetyTimer() {
    _checkoutSafetyTimer?.cancel();
    _checkoutSafetyTimer = null;
  }

  @override
  void dispose() {
    _stopCheckoutSafetyTimer();
    _razorpayService.dispose();
    super.dispose();
  }
}
