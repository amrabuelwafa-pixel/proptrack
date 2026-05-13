import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proptrack/core/theme/app_colors.dart';
import 'package:proptrack/features/properties/domain/entities/property_entity.dart';
import 'package:proptrack/features/properties/domain/repositories/property_repository.dart';
import 'package:proptrack/features/properties/presentation/providers/property_providers.dart';
import 'package:proptrack/features/properties/presentation/widgets/property_card_widget.dart';
import 'package:proptrack/features/properties/presentation/widgets/property_form_bottom_sheet.dart';
import 'package:shimmer/shimmer.dart';

class PropertiesShellPage extends ConsumerWidget {
  const PropertiesShellPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertiesAsync = ref.watch(propertyNotifierProvider);
    final notifier = ref.read(propertyNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Properties'),
        centerTitle: false,
        elevation: 0,
      ),
      body: propertiesAsync.when(
        loading: () => _buildShimmerLoader(),
        error: (error, stack) => _buildErrorView(
          context,
          error.toString(),
          () => ref.refresh(propertyNotifierProvider),
        ),
        data: (properties) {
          if (properties.isEmpty) {
            return _buildEmptyState(context);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final property = properties[index];
              return PropertyCardWidget(
                property: property,
                onTap: () {
                  // Navigate to property detail
                },
                onEdit: () {
                  _showPropertyForm(context, ref, notifier, property: property);
                },
                onDelete: () async {
                  final success = await notifier.delete(property.id);
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Property deleted')),
                    );
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showPropertyForm(context, ref, notifier);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showPropertyForm(
    BuildContext context,
    WidgetRef ref,
    Object notifier, {
    Object? property,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => PropertyFormBottomSheet(
        property: property as PropertyEntity?,
        onSubmit: (String name, String? developer, String? location, double price, String currency, DateTime? handoverDate, String? notes) async {
          final notifierObj = notifier as dynamic;
          final propertyObj = property as PropertyEntity?;

          final success = propertyObj != null
              ? await notifierObj.update(
                  UpdatePropertyParams(
                    id: propertyObj.id,
                    name: name,
                    developer: developer,
                    location: location,
                    totalPrice: price,
                    currency: currency,
                    handoverDate: handoverDate,
                    notes: notes,
                  ),
                ) as bool? ?? false
              : await notifierObj.create(
                  CreatePropertyParams(
                    name: name,
                    developer: developer,
                    location: location,
                    totalPrice: price,
                    currency: currency,
                    handoverDate: handoverDate,
                    notes: notes,
                  ),
                ) as bool? ?? false;

          if (!context.mounted) return;

          if (success == true) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  propertyObj != null
                      ? 'Property updated'
                      : 'Property created',
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(
    BuildContext context,
    String error,
    VoidCallback onRetry,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          const Text('Failed to load properties'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.apartment,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No properties yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first property to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Will be handled by FAB
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Property'),
          ),
        ],
      ),
    );
  }
}
