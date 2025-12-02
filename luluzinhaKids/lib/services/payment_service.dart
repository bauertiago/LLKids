import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class PaymentService {
  final _functions = FirebaseFunctions.instance;

  Future<void> payWithStripe() async {
    final callable = _functions.httpsCallable("createPaymentIntent");

    final result = await callable();

    final clientSecret = result.data["clientSecret"];

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: "Luluzinha Kids",
      ),
    );

    await Stripe.instance.presentPaymentSheet();
  }
}
