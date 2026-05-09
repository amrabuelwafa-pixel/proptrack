import 'package:equatable/equatable.dart';

class UpcomingInstallment extends Equatable {
  final String id;
  final String propertyName;
  final DateTime dueDate;
  final double amount;
  final bool isOverdue;

  const UpcomingInstallment({
    required this.id,
    required this.propertyName,
    required this.dueDate,
    required this.amount,
    required this.isOverdue,
  });

  @override
  List<Object?> get props => [id, propertyName, dueDate, amount, isOverdue];
}
