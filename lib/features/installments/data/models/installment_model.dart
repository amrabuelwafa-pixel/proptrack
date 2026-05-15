import 'package:proptrack/features/installments/domain/entities/installment_entity.dart';

class InstallmentModel extends InstallmentEntity {
  const InstallmentModel({
    required super.id,
    required super.propertyId,
    required super.userId,
    required super.dueDate,
    required super.amount,
    required super.isPaid,
    super.paidAt,
    super.label,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
  });

  factory InstallmentModel.fromJson(Map<String, dynamic> json) {
    return InstallmentModel(
      id: json['id'] as String,
      propertyId: json['property_id'] as String,
      userId: json['user_id'] as String,
      dueDate: DateTime.parse(json['due_date'] as String),
      amount: (json['amount'] as num).toDouble(),
      isPaid: json['is_paid'] as bool,
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : null,
      label: json['label'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'property_id': propertyId,
        'user_id': userId,
        'due_date': dueDate.toIso8601String(),
        'amount': amount,
        'is_paid': isPaid,
        'paid_at': paidAt?.toIso8601String(),
        'label': label,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  InstallmentEntity toEntity() => InstallmentEntity(
        id: id,
        propertyId: propertyId,
        userId: userId,
        dueDate: dueDate,
        amount: amount,
        isPaid: isPaid,
        paidAt: paidAt,
        label: label,
        notes: notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
