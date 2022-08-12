import 'package:core/core.dart';

import 'model/model.dart';

class StripePayoutException implements Exception {
  final ErrorModel error;

  StripePayoutException(this.error);

  @override
  String toString() => error.message;
}

class StripePayoutRepository {
  static StripePayoutRepository? _instance;

  static StripePayoutRepository get instance =>
      _instance ??= StripePayoutRepository._internal();

  StripePayoutRepository._internal();

  Future<StripePayoutResponse> payout(StripePayoutRequest request) async {
    try {
      final data = await HttpApiClient.instance
          .post('payment/stripeConnect/payout', data: request.toJson());
      return StripePayoutResponse.fromJson(data);
    } on HttpApiException catch (error) {
      throw StripePayoutException(error.error);
    } catch (error) {
      rethrow;
    }
  }
}
