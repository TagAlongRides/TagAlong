class Constants {
  static const BASE_URL = "";
  //Tets Credit card details
  static const String CARD_NUMBER = "4242424242424242";
  static const String CARD_CVV = "123";
  static const String CARD_EXPIRY = "12/23";
  static const String CARD_HOLDER_NAME = "Rohit Kumar Mishra";

  static const String CREATE_STRIPE_CUSTOMER = "v1/customers";
  static const String CREATE_STRIPE_PAYMENT_INTENT = "";
  static const String STRIPE_CUSTOMER_UPDATE = "";
  static const String STRIPE_CUSTOMER_RETRIEVE = "";
  static const String STRIPE_PAYMENT = "v1/payment_intents";
  static const String STRIPE_GET_CARDS = "v1/payment_methods";
  static const String STRIPE_ATTACH_PAYMENT_METHOD_TO_CUSTOMER =
      "v1/payment_methods/pay_id/attach";
  static const String STRIPE_DETACH_PAYMENT_METHOD_TO_CUSTOMER =
      "v1/payment_methods/pay_id/detach";
  static const String STRIPE_ADD_CARDS_WITH_PAYMENT_METHODS =
      "v1/payment_methods";
  static const String STRIPE_ADD_CARD = "v1/customers/cust_id/sources";
  static const String STRIPE_CONFIRM_PAYMENT_INTENT =
      "v1/payment_intents/pay_id/confirm";
  static const String STRIPE_FETCH_ALL_COUPONS_URL = "v1/coupons";
}
