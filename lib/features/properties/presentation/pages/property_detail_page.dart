import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:proptrack/core/router/route_names.dart';
import 'package:proptrack/features/installments/presentation/providers/installment_providers.dart';
import 'package:proptrack/features/installments/presentation/widgets/installment_tile.dart';
import 'package:proptrack/features/properties/presentation/providers/property_providers.dart';

class PropertyDetailPage extends ConsumerWidget {
  const PropertyDetailPage({required this.propertyId, super.key});

  final String propertyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final property = ref.watch(selectedPropertyProvider(propertyId));
    final notifier = ref.read(propertyNotifierProvider.notifier);

    if (property == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Property Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final progressValue = property.totalPrice > 0
        ? (property.paidAmount / property.totalPrice).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(property.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/properties/${property.id}/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context, property.name, () {
              _deleteProperty(context, propertyId, notifier);
            }),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Developer', property.developer ?? 'N/A'),
                    _buildInfoRow('Location', property.location ?? 'N/A'),
                    _buildInfoRow(
                      'Total Price',
                      '${property.currency} ${NumberFormat('#,##0.00').format(property.totalPrice)}',
                    ),
                    if (property.handoverDate != null)
                      _buildInfoRow(
                        'Handover Date',
                        DateFormat('d MMM yyyy').format(property.handoverDate!),
                      ),
                    if (property.notes != null)
                      _buildInfoRow('Notes', property.notes!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Payment Progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progressValue,
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              '${property.paidInstallments}/${property.totalInstallments} installments paid',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            Text(
              'Installments',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Consumer(
              builder: (context, ref, _) {
                final installments = ref.watch(installmentNotifierProvider(propertyId));
                final installmentNotifier = ref.read(installmentNotifierProvider(propertyId).notifier);

                return installments.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text(
                    'Error loading installments',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                    ),
                  ),
                  data: (installmentsList) {
                    if (installmentsList.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No installments yet',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: installmentsList
                          .map(
                            (inst) => InstallmentTile(
                              installment: inst,
                              currency: property.currency,
                              onToggle: (isPaid) =>
                                  installmentNotifier.togglePaid(inst.id, isPaid),
                            ),
                          )
                          .toList(),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    ),
  );

  void _showDeleteConfirmation(
    BuildContext context,
    String propertyName,
    VoidCallback onConfirm,
  ) =>
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Property'),
          content: Text(
            'Are you sure you want to delete "$propertyName"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

  Future<void> _deleteProperty(
    BuildContext context,
    String id,
    Object notifier,
  ) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Deleting property...')),
    );
    final success = await (notifier as dynamic).delete(id) as bool;
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property deleted')),
      );
      context.go(AppRoutes.properties);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete property')),
      );
    }
  }
}
