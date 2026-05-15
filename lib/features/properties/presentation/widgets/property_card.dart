import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:proptrack/features/properties/domain/entities/property_entity.dart';

class PropertyCard extends StatelessWidget {
  const PropertyCard({
    required this.property,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final PropertyEntity property;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final progressValue = property.totalPrice > 0
        ? (property.paidAmount / property.totalPrice).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      child: InkWell(
        onTap: () => context.push('/properties/${property.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      property.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<int>(
                    itemBuilder: (context) => [
                      const PopupMenuItem<int>(
                        value: 0,
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem<int>(
                        value: 1,
                        child: Text('Delete'),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 0) {
                        onEdit();
                      } else {
                        onDelete();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (property.developer != null || property.location != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    [
                      if (property.developer != null) property.developer,
                      if (property.location != null) property.location,
                    ].join(' • '),
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '${property.currency} ${NumberFormat('#,##0.00').format(property.totalPrice)}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              LinearProgressIndicator(
                value: progressValue,
                minHeight: 6,
              ),
              const SizedBox(height: 8),
              Text(
                '${property.paidInstallments}/${property.totalInstallments} installments paid',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
