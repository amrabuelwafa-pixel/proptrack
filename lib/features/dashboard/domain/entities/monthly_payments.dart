import 'package:equatable/equatable.dart';

class MonthlyPaymentBucket extends Equatable {
  const MonthlyPaymentBucket({
    required this.month,
    required this.paid,
    required this.due,
  });

  /// First day of the month this bucket represents.
  final DateTime month;

  /// Sum of `amount` for installments paid in this month (paid_at).
  final double paid;

  /// Sum of `amount` for installments scheduled in this month (due_date).
  final double due;

  @override
  List<Object?> get props => [month, paid, due];
}
