import 'package:core/core.dart';
import 'package:stripe_repo/stripe_repo.dart';

class StripeCustomerException implements Exception {
  final ErrorModel error;

  StripeCustomerException(this.error);

  @override
  String toString() => error.message;
}

class StripeCustomerRepository {
  static StripeCustomerRepository? _instance;

  static StripeCustomerRepository get instance => _instance ??= StripeCustomerRepository._internal();

  StripeCustomerRepository._internal();

  Future<StripeCustomerCreateResponse> createCustomer(StripeCustomerCreateRequest request) async {
    try {
      final data = await HttpApiClient.instance.post('payment/customer/', data: request.toJson());
      return StripeCustomerCreateResponse.fromJson(data);
    } on HttpApiException catch (error) {
      throw StripeCustomerException(error.error);
    } catch (error) {
      rethrow;
    }
  }

  Future<StripeCustomerCreateResponse> getCustomer(String id) async {
    try {
      final data = await HttpApiClient.instance.get('payment/customer/$id');
      return StripeCustomerCreateResponse.fromJson(data);
    } on HttpApiException catch (error) {
      throw StripeCustomerException(error.error);
    } catch (error) {
      rethrow;
    }
  }

  Future<StripePaymentMethodResponse> getPaymentMethod(String customerId) async {
    try {
      final data = await HttpApiClient.instance.get('payment/getPaymentMethods/$customerId');
      return StripePaymentMethodResponse.fromJson(data);
    } on HttpApiException catch (error) {
      throw StripeCustomerException(error.error);
    } catch (error) {
      rethrow;
    }
  }

  // The signed-in user's own cards. These routes find the Stripe customer from
  // the user's Firebase sign-in, so nothing here passes a customer id.

  /// The user's saved cards, with [StripePaymentMethodResponse.data]'s
  /// `defaultPaymentMethod` naming their default card, if they have one.
  Future<StripePaymentMethodResponse> getMyPaymentMethods() async {
    try {
      final data = await HttpApiClient.instance.get('payment/me/paymentMethods');
      return StripePaymentMethodResponse.fromJson(data);
    } on HttpApiException catch (error) {
      throw StripeCustomerException(error.error);
    }
  }

  /// Starts saving a card. Returns the SetupIntent's client secret, which the
  /// card form confirms with `Stripe.instance.confirmSetupIntent`.
  Future<String> createSetupIntent() async {
    try {
      final data = await HttpApiClient.instance.post('payment/me/setupIntent');
      return data['data']['client_secret'] as String;
    } on HttpApiException catch (error) {
      throw StripeCustomerException(error.error);
    }
  }

  /// Makes [paymentMethodId], one of the user's own cards, their default.
  Future<void> setDefaultPaymentMethod(String paymentMethodId) async {
    try {
      await HttpApiClient.instance.post('payment/me/paymentMethods/$paymentMethodId/default');
    } on HttpApiException catch (error) {
      throw StripeCustomerException(error.error);
    }
  }

  /// Removes [paymentMethodId], one of the user's own cards.
  Future<void> removePaymentMethod(String paymentMethodId) async {
    try {
      await HttpApiClient.instance.delete('payment/me/paymentMethods/$paymentMethodId');
    } on HttpApiException catch (error) {
      throw StripeCustomerException(error.error);
    }
  }
}
