import 'package:core/core.dart';

import 'model/model.dart';

class StripeConnectException implements Exception {
  final ErrorModel error;

  StripeConnectException(this.error);

  @override
  String toString() => error.message;
}

class StripeConnectRepository {
  static StripeConnectRepository? _instance;

  static StripeConnectRepository get instance =>
      _instance ??= StripeConnectRepository._internal();

  StripeConnectRepository._internal();

  // ///Test API
  // Future getUsers() async {
  //   try {
  //     final data = await HttpApiClient.instance.get('users');
  //   } on HttpApiException catch (error) {
  //     throw StripeConnectException(error.error);
  //   } catch (error) {
  //     //Rethrow the error from API Core
  //     rethrow;
  //   }
  // }

  Future<StripeConnectResponse> getStripeConnectLink(
      StripeConnectRequest request) async {
    try {
      final data = await HttpApiClient.instance
          .post('payment/stripeConnect/', data: request.toJson());
      return StripeConnectResponse.fromJson(data);
    } on HttpApiException catch (error) {
      throw StripeConnectException(error.error);
    } catch (error) {
      rethrow;
    }
  }

  Future<StripePaymentIntentCreateResponse> createDestinationPayemntIntent(
      StripePaymentIntentRequest request) async {
    try {
      final data = await HttpApiClient.instance.post(
          'payment/stripeConnect/charge/destination/paymentintent',
          data: request.toJson());
      return StripePaymentIntentCreateResponse.fromJson(data);
    } on HttpApiException catch (error) {
      throw StripeConnectException(error.error);
    } catch (error) {
      rethrow;
    }
  }

  Future<StripePaymentIntentCreateResponse> createSeparatePayemntIntent(
      StripePaymentIntentRequest request) async {
    try {
      final data = await HttpApiClient.instance.post(
          'payment/stripeConnect/charge/separate/paymentintent',
          data: request.toJson());
      return StripePaymentIntentCreateResponse.fromJson(data);
    } on HttpApiException catch (error) {
      throw StripeConnectException(error.error);
    } catch (error) {
      rethrow;
    }
  }

  Future<StripeConnectResponse> getPayemntIntent(
      StripeConnectRequest request) async {
    try {
      final data = await HttpApiClient.instance
          .post('payment/stripeConnect/', data: request.toJson());
      return StripeConnectResponse.fromJson(data);
    } on HttpApiException catch (error) {
      throw StripeConnectException(error.error);
    } catch (error) {
      rethrow;
    }
  }

  // Future<PostModel> getPost(String postHash) async {
  //   try {
  //     final data = await HttpApiClient.instance.get('post/$postHash');
  //     return PostModel.fromJson(data);
  //   } on HttpApiException catch (error) {
  //     throw PostException(error.error);
  //   } catch (error) {
  //     //Rethrow the error from API Core
  //     rethrow;
  //   }
  // }
}
