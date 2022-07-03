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

  static StripeCustomerRepository get instance =>
      _instance ??= StripeCustomerRepository._internal();

  StripeCustomerRepository._internal();

  Future<StripeCustomerCreateResponse> createCustomer(
      StripeCustomerCreateRequest request) async {
    try {
      final data = await HttpApiClient.instance
          .post('payment/customer/', data: request.toJson());
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

  Future<StripePaymentMethodResponse> getPaymentMethod(
      String customerId) async {
    try {
      final data = await HttpApiClient.instance
          .get('payment/getPaymentMethods/$customerId');
      return StripePaymentMethodResponse.fromJson(data);
    } on HttpApiException catch (error) {
      throw StripeCustomerException(error.error);
    } catch (error) {
      rethrow;
    }
  }
}
