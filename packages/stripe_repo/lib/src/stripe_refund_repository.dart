import 'package:core/core.dart';

import 'model/model.dart';

class StripeRefundException implements Exception {
  final ErrorModel error;

  StripeRefundException(this.error);

  @override
  String toString() => error.message;
}

class StripeRefundRepository {
  static StripeRefundRepository? _instance;

  static StripeRefundRepository get instance =>
      _instance ??= StripeRefundRepository._internal();

  StripeRefundRepository._internal();

  Future<StripeRefundResponse> refundDestinationCharge(
      StripeRefundRequest request) async {
    try {
      final data = await HttpApiClient.instance.post(
          'payment/stripeConnect/refundDestinationCharge',
          data: request.toJson());
      return StripeRefundResponse.fromJson(data);
    } on HttpApiException catch (error) {
      throw StripeRefundException(error.error);
    } catch (error) {
      rethrow;
    }
  }
}
