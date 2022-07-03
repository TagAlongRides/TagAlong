import 'package:core/core.dart';

import 'model/model.dart';

class StripeAccountException implements Exception {
  final ErrorModel error;

  StripeAccountException(this.error);

  @override
  String toString() => error.message;
}

class StripeAccountRepository {
  static StripeAccountRepository? _instance;

  static StripeAccountRepository get instance =>
      _instance ??= StripeAccountRepository._internal();

  StripeAccountRepository._internal();

  Future<StripeAccountCreateResponse> createAccount(
      StripeAccountCreateRequest request) async {
    try {
      final data = await HttpApiClient.instance
          .post('payment/stripeConnect/account/', data: request.toJson());
      return StripeAccountCreateResponse.fromJson(data);
    } on HttpApiException catch (error) {
      throw StripeAccountException(error.error);
    } catch (error) {
      rethrow;
    }
  }

  Future<StripePaymentMethodResponse> getAccount(String id) async {
    try {
      final data =
          await HttpApiClient.instance.get('payment/stripeConnect/account/$id');
      return StripePaymentMethodResponse.fromJson(data);
    } on HttpApiException catch (error) {
      throw StripeAccountException(error.error);
    } catch (error) {
      rethrow;
    }
  }
}
