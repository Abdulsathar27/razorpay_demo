# Razorpay Flutter Demo

This project demonstrates a Flutter ticket checkout using `razorpay_flutter`.

## Run

Use your own Razorpay key while running the app:

```bash
flutter run --dart-define=RAZORPAY_KEY=rzp_test_your_key_here
```

If `RAZORPAY_KEY` is missing or invalid, app now shows a one-time setup dialog, saves the key locally, and continues checkout.

## Why "No appropriate payment method found" happens

This error is usually not a Flutter UI bug. It is most often caused by account setup:

1. Wrong key mode (`rzp_test_` vs `rzp_live_`).
2. Payment methods not enabled for the active Razorpay account.
3. Currency or account setup mismatch.

Check in Razorpay Dashboard:

1. `Account & Settings -> API Keys`
2. `Account & Settings -> Payment Methods`

## Smooth production flow (recommended)

1. Create an `order_id` from your backend for every payment.
2. Pass that `order_id` to checkout options.
3. Verify payment signature on backend.
4. Mark booking as confirmed only after backend verification/capture status.

Without backend order + verification, successful UI callback alone is not enough for a reliable production flow.
