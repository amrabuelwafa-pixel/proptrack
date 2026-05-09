import 'package:equatable/equatable.dart';

class PropertyEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? developer;
  final String? location;
  final double totalPrice;
  final String currency;
  final DateTime? handoverDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double paidAmount;
  final int totalInstallments;
  final int paidInstallments;

  const PropertyEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.developer,
    this.location,
    required this.totalPrice,
    required this.currency,
    this.handoverDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.paidAmount = 0,
    this.totalInstallments = 0,
    this.paidInstallments = 0,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    developer,
    location,
    totalPrice,
    currency,
    handoverDate,
    notes,
    createdAt,
    updatedAt,
    paidAmount,
    totalInstallments,
    paidInstallments,
  ];
}
