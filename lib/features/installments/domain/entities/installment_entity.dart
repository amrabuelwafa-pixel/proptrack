import 'package:equatable/equatable.dart';

class InstallmentEntity extends Equatable {
  final String id;
  final String propertyId;
  final String userId;
  final DateTime dueDate;
  final double amount;
  final bool isPaid;
  final DateTime? paidAt;
  final String? label;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InstallmentEntity({
    required this.id,
    required this.propertyId,
    required this.userId,
    required this.dueDate,
    required this.amount,
    required this.isPaid,
    this.paidAt,
    this.label,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        propertyId,
        userId,
        dueDate,
        amount,
        isPaid,
        paidAt,
        label,
        notes,
        createdAt,
        updatedAt,
      ];
}
