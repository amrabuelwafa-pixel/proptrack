import 'package:hive_flutter/hive_flutter.dart';
import 'package:proptrack/features/properties/domain/entities/property_entity.dart';

class PropertyModel extends PropertyEntity {
  const PropertyModel({
    required super.id,
    required super.userId,
    required super.name,
    super.developer,
    super.location,
    required super.totalPrice,
    required super.currency,
    super.handoverDate,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
    super.paidAmount = 0,
    super.totalInstallments = 0,
    super.paidInstallments = 0,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    final installments = json['installments'] as List<dynamic>? ?? [];

    double paidAmount = 0;
    int paidInstallments = 0;

    for (final inst in installments) {
      final instMap = inst as Map<String, dynamic>;
      final isPaid = instMap['is_paid'] as bool? ?? false;
      if (isPaid) {
        paidAmount += (instMap['amount'] as num?)?.toDouble() ?? 0;
        paidInstallments++;
      }
    }

    return PropertyModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      developer: json['developer'] as String?,
      location: json['location'] as String?,
      totalPrice: (json['total_price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'EGP',
      handoverDate: json['handover_date'] != null
          ? DateTime.parse(json['handover_date'] as String)
          : null,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      paidAmount: paidAmount,
      totalInstallments: installments.length,
      paidInstallments: paidInstallments,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'name': name,
    'developer': developer,
    'location': location,
    'total_price': totalPrice,
    'currency': currency,
    'handover_date': handoverDate?.toIso8601String(),
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  PropertyEntity toEntity() => PropertyEntity(
    id: id,
    userId: userId,
    name: name,
    developer: developer,
    location: location,
    totalPrice: totalPrice,
    currency: currency,
    handoverDate: handoverDate,
    notes: notes,
    createdAt: createdAt,
    updatedAt: updatedAt,
    paidAmount: paidAmount,
    totalInstallments: totalInstallments,
    paidInstallments: paidInstallments,
  );
}

class PropertyModelAdapter extends TypeAdapter<PropertyModel> {
  @override
  final int typeId = 0;

  @override
  PropertyModel read(BinaryReader reader) {
    return PropertyModel(
      id: reader.readString(),
      userId: reader.readString(),
      name: reader.readString(),
      developer: reader.read() as String?,
      location: reader.read() as String?,
      totalPrice: reader.readDouble(),
      currency: reader.readString(),
      handoverDate: reader.read() as DateTime?,
      notes: reader.read() as String?,
      createdAt: reader.read() as DateTime,
      updatedAt: reader.read() as DateTime,
      paidAmount: reader.readDouble(),
      totalInstallments: reader.readInt(),
      paidInstallments: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, PropertyModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.userId);
    writer.writeString(obj.name);
    writer.write(obj.developer);
    writer.write(obj.location);
    writer.writeDouble(obj.totalPrice);
    writer.writeString(obj.currency);
    writer.write(obj.handoverDate);
    writer.write(obj.notes);
    writer.write(obj.createdAt);
    writer.write(obj.updatedAt);
    writer.writeDouble(obj.paidAmount);
    writer.writeInt(obj.totalInstallments);
    writer.writeInt(obj.paidInstallments);
  }
}
