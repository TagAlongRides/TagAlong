import 'package:core/core.dart';

import 'model/model.dart';

class StripeException implements Exception {
  final ErrorModel error;

  StripeException(this.error);

  @override
  String toString() => error.message;
}

class StripeRepository {
  static StripeRepository? _instance;

  static StripeRepository get instance =>
      _instance ??= StripeRepository._internal();

  StripeRepository._internal();

  ///Test API
  Future getUsers() async {
    try {
      final data = await HttpApiClient.instance.get('users');
    } on HttpApiException catch (error) {
      throw StripeException(error.error);
    } catch (error) {
      //Rethrow the error from API Core
      rethrow;
    }
  }

  Future<StripeConnectResponse> getStripeConnectLink(
      StripeConnectRequest request) async {
    try {
      final data = await HttpApiClient.instance
          .post('payment/stripeConnect/', data: request.toJson());
      return StripeConnectResponse.fromJson(data);
    } on HttpApiException catch (error) {
      throw StripeException(error.error);
    } catch (error) {
      rethrow;
    }
  }

  Future<StripeConnectResponse> createPayemntIntent(
      StripeConnectRequest request) async {
    try {
      final data = await HttpApiClient.instance
          .post('payment/stripeConnect/', data: request.toJson());
      return StripeConnectResponse.fromJson(data);
    } on HttpApiException catch (error) {
      throw StripeException(error.error);
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
      throw StripeException(error.error);
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
