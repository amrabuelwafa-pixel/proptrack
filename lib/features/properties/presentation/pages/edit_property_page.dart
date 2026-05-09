import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:proptrack/features/properties/domain/repositories/property_repository.dart';
import 'package:proptrack/features/properties/presentation/providers/property_providers.dart';
import 'package:proptrack/features/properties/presentation/widgets/property_form.dart';

class EditPropertyPage extends ConsumerWidget {
  const EditPropertyPage({required this.propertyId, super.key});

  final String propertyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final property = ref.watch(selectedPropertyProvider(propertyId));

    if (property == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Property')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Property')),
      body: PropertyForm(
        initialName: property.name,
        initialDeveloper: property.developer,
        initialLocation: property.location,
        initialPrice: property.totalPrice,
        initialCurrency: property.currency,
        initialHandoverDate: property.handoverDate,
        initialNotes: property.notes,
        submitLabel: 'Update Property',
        onSubmit: (name, developer, location, price, currency, handoverDate, notes) async {
          final notifier = ref.read(propertyNotifierProvider.notifier);
          final params = UpdatePropertyParams(
            id: propertyId,
            name: name,
            developer: developer,
            location: location,
            totalPrice: price,
            currency: currency,
            handoverDate: handoverDate,
            notes: notes,
          );
          final success = await notifier.update(params);
          if (success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Property updated')),
            );
            context.pop();
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to update property')),
            );
          }
        },
      ),
    );
  }
}
