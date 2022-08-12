// import 'package:stripe_payment/stripe_payment.dart';

import 'package:tagalong/data/remote/api_client.dart';
import 'package:tagalong/util/constants.dart';

class StripeService {
  ///
  ///
  ///
  ///Api to create customer
  Future<dynamic?> createCustomer(String email, dynamic paymentMethod) async {
    try {
      var resp = await ApiClient.getClient()
          .post(Constants.CREATE_STRIPE_CUSTOMER, data: {
        "description": "email",
        "email": "email",
        "name": "name",
        "phone": "phone",
        "payment_method": "method"
      });
      Map<String, dynamic> responseData = resp.data;

      return responseData;
    } catch (e) {
      print(e);
      print("error in StripeService.createCustomer()");
      return null;
    }
  }

  ///
  ///
  ///Api to create payment intent
  Future<Map<String, dynamic>> createPaymentIntent(
      String amount, String currency, dynamic method) async {
    try {
      var postData = {
        'amount': double.parse(amount
            .trim()), // amount charged will be specified when the method is called
        'currency': currency, // the currency
        "payment_method": method.id,
        "customer": "stripeCustomerInfo?.id",
        'payment_method_types[]': 'card' //card
      };

      var response = await ApiClient.getClient()
          .post(Constants.STRIPE_PAYMENT, data: postData);

      return response.data; //decode the response to json
    } catch (error) {
      print('Error occured : ${error.toString()}');
    }
    return {};
  }

  ///
  ///
  ///
  ///get avaiable cards
  Future<dynamic> getCards(String customerId) async {
    try {
      var resp = await ApiClient.getClient().get(Constants.STRIPE_GET_CARDS,
          queryParameters: {"type": "card", "customer": customerId});
      Map<String, dynamic> responseData = resp.data;

      return responseData;
    } catch (e) {
      throw (e);
    }
  }

  ///
  ///
  ///
  ///aapi to attach payment method to customer
  Future attachPaymentMethodToCustomer(String paymentMethodId) async {
    var resp = await ApiClient.getClient().post(
        Constants.STRIPE_ATTACH_PAYMENT_METHOD_TO_CUSTOMER
            .replaceAll("pay_id", paymentMethodId),
        data: {"customer": "stripeCustomerInfo!.id"});
    return resp.data;
  }

  ///
  ///
  ///
  ///aapi to attach payment method to customer
  Future detachPaymentMethodToCustomer(String paymentMethodId) async {
    var resp = await ApiClient.getClient().post(
      Constants.STRIPE_DETACH_PAYMENT_METHOD_TO_CUSTOMER
          .replaceAll("pay_id", paymentMethodId),
    );
    return resp.data;
  }

  ///
  ///
  ///
  ///Api to add new card
  Future<dynamic> addNewCard(dynamic creditCard) async {
    try {
      var cardData = creditCard.toJson();

      cardData.addAll({"object": "card"});
      final Map<String, Object> map = {
        'type': 'card',
        'card': {
          'number': "card.number",
          'cvc': "card.cvc",
          'exp_month': "card.expMonth",
          'exp_year': "card.expYear",
        },
        'billing_details': {
          'address': {'postal_code': ""}
        },
        "metadata": {"name": "card.name"}
      };
      var resp = await ApiClient.getClient()
          .post(Constants.STRIPE_ADD_CARDS_WITH_PAYMENT_METHODS, data: map);
      Map<String, dynamic> responseData = resp.data;

      return responseData;
    } catch (e) {
      throw (e);
    }
  }

  ///
  ///
  ///
  ///Api to confirm payment intent
  Future<dynamic> confirmPaymentIntent(dynamic method, String intentId) async {
    try {
      final Map<String, Object> map = {'payment_method': method.id ?? ""};
      var resp = await ApiClient.getClient().post(
          Constants.STRIPE_CONFIRM_PAYMENT_INTENT
              .replaceAll("pay_id", intentId),
          data: map);
      Map<String, dynamic> responseData = resp.data;

      return responseData;
    } catch (e) {
      throw (e);
    }
  }

  ///
  ///
  ///
  ///Api to confirm payment intent
  Future<dynamic> getCoupons() async {
    try {
      var resp = await ApiClient.getClient().get(
        Constants.STRIPE_FETCH_ALL_COUPONS_URL,
      );
      Map<String, dynamic> responseData = resp.data;

      return responseData;
    } catch (e) {
      return null;
    }
  }

  ///
  ///
  ///
  ///
}
