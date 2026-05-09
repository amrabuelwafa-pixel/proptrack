import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proptrack/features/installments/domain/entities/installment_entity.dart';

class InstallmentTile extends StatelessWidget {
  const InstallmentTile({
    required this.installment,
    required this.currency,
    required this.onToggle,
    super.key,
  });

  final InstallmentEntity installment;
  final String currency;
  final Future<bool> Function(bool) onToggle;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: installment.isPaid,
      onChanged: (value) => onToggle(value ?? false),
      title: Text(
        installment.label ?? 'Installment',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          decoration: installment.isPaid ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text(
        DateFormat('d MMM yyyy').format(installment.dueDate),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      secondary: Text(
        '$currency ${installment.amount.toStringAsFixed(2)}',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
