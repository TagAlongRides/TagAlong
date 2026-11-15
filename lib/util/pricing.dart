import 'package:intl/intl.dart';

/// Single source of truth for how a ride's price is broken down for a
/// passenger.
///
/// Total price = driver's price + service fee + taxes (Milestone 3, §2.1.3).
/// The tax rate is the 5% proxy called out in the requirements and is expected
/// to be replaced once a real rate is determined.
class Pricing {
  /// Share of the driver's price that TagAlong keeps to run the platform.
  static const double serviceFeeRate = 0.20;

  /// Proxy tax rate. Applied to the driver's price.
  static const double taxRate = 0.05;

  static final NumberFormat _currency = NumberFormat.currency(locale: 'en_US', symbol: '\$');

  /// What the driver charges per passenger.
  static double subtotal(int driverPrice) => driverPrice.toDouble();

  /// TagAlong's cut, [serviceFeeRate] of the driver's price.
  static double serviceFee(int driverPrice) => driverPrice * serviceFeeRate;

  /// Taxes owed on the ride, [taxRate] of the driver's price.
  static double tax(int driverPrice) => driverPrice * taxRate;

  /// What the passenger actually pays.
  static double total(int driverPrice) =>
      subtotal(driverPrice) + serviceFee(driverPrice) + tax(driverPrice);

  /// [total] expressed in cents, which is what Stripe expects.
  static String totalInCents(int driverPrice) => (total(driverPrice) * 100).toStringAsFixed(0);

  /// The portion of the charge TagAlong keeps — everything the driver isn't
  /// paid — expressed in cents for Stripe's `application_fee_amount`.
  static String applicationFeeInCents(int driverPrice) =>
      ((serviceFee(driverPrice) + tax(driverPrice)) * 100).toStringAsFixed(0);

  /// Formats an amount as US currency, e.g. `$24.00`.
  static String format(double amount) => _currency.format(amount);
}
