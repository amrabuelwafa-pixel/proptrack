import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:proptrack/features/properties/domain/repositories/property_repository.dart';
import 'package:proptrack/features/properties/presentation/providers/property_providers.dart';
import 'package:proptrack/features/properties/presentation/widgets/property_form.dart';

class AddPropertyPage extends ConsumerWidget {
  const AddPropertyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Property')),
      body: PropertyForm(
        submitLabel: 'Save Property',
        onSubmit: (name, developer, location, price, currency, handoverDate, notes) async {
          final notifier = ref.read(propertyNotifierProvider.notifier);
          final params = CreatePropertyParams(
            name: name,
            developer: developer,
            location: location,
            totalPrice: price,
            currency: currency,
            handoverDate: handoverDate,
            notes: notes,
          );
          final success = await notifier.create(params);
          if (success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Property created')),
            );
            context.pop();
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to create property')),
            );
          }
        },
      ),
    );
  }
}
