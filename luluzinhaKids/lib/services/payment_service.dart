import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class PaymentService {
  final _functions = FirebaseFunctions.instance;

  // CRIA O PAYMENT NO STRIPE
  Future<Map<String, dynamic>> createPaymentIntent() async {
    final callable = _functions.httpsCallable("createPaymentIntent");

    final result = await callable();

    return {
      "clientSecret": result.data["clientSecret"],
      "paymentIntentId": result.data["paymentIntentId"],
      "items": result.data["items"],
      "total": result.data["total"],
    };
  }

  // APRESENTA O PAGAMENTO VIA STRIPE
  Future<void> presentPaymentSheet({
    required String clientSecret,
    String? customerName,
  }) async {
    final billingDetails = BillingDetails(name: customerName);
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: "Luluzinha Kids",
        billingDetails: billingDetails,
        style: ThemeMode.light,
      ),
    );

    await Stripe.instance.presentPaymentSheet();
  }

  // CRIA O PEDIDO "PENDING"
  Future<String> createOrder({
    required List items,
    required double total,
    required String paymentIntentId,
  }) async {
    final callable = _functions.httpsCallable("createOrder");

    final result = await callable({
      "items": items,
      "total": total,
      "paymentIntentId": paymentIntentId,
    });

    return result.data["orderId"];
  }

  // CONFIRMA O PAGAMENTO E ATUALIZA ESTOQUE
  Future<void> confirmOrderPayment({
    required String orderId,
    required String paymentMethod,
    required double amount,
    required String transactionId,
    bool saveCard = false,
  }) async {
    final callable = _functions.httpsCallable("confirmOrderPayment");

    await callable({
      "orderId": orderId,
      "paymentMethod": paymentMethod,
      "amount": amount,
      "transactionId": transactionId,
      "saveCard": saveCard,
    });
  }

  Future<String> createAndConfirmWithSavedCard({
    required String paymentMethodId,
    required double total,
  }) async {
    final callable = _functions.httpsCallable("processSavedCardPayment");
    final result = await callable.call({
      "paymentMethodId": paymentMethodId,
      "total": total,
    });
    return result.data["orderId"];
  }

  //EXECUTA O FLUXO AUTOMATICAMENTE
  Future<String> processPayment({bool saveCard = false}) async {
    final intent = await createPaymentIntent();

    final clientSecret = intent["clientSecret"];
    final paymentIntentId = intent["paymentIntentId"];
    final items = intent["items"];
    final total = intent["total"];

    try {
      await presentPaymentSheet(clientSecret: clientSecret);
    } on Exception catch (e) {
      // 🚨 NOVO: Se o PaymentSheet for fechado ou falhar, a exceção é lançada AQUI.
      print('Erro/Cancelamento após presentPaymentSheet: $e');
      // Você deve lidar com este erro (ex: notificar o usuário)
      rethrow; // Re-lança para notificar a tela de pagamento
    }

    final orderId = await createOrder(
      items: items,
      total: total,
      paymentIntentId: paymentIntentId,
    );

    await confirmOrderPayment(
      orderId: orderId,
      paymentMethod: "card",
      amount: total,
      transactionId: paymentIntentId,
      saveCard: saveCard,
    );

    return orderId;
  }
}
