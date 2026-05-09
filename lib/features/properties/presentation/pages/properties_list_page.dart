import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:proptrack/core/router/route_names.dart';
import 'package:proptrack/features/properties/presentation/providers/property_providers.dart';
import 'package:proptrack/features/properties/presentation/widgets/property_card.dart';
import 'package:shimmer/shimmer.dart';

class PropertiesListPage extends ConsumerWidget {
  const PropertiesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final properties = ref.watch(propertyNotifierProvider);
    final notifier = ref.read(propertyNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Properties'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(AppRoutes.newProperty),
          ),
        ],
      ),
      body: properties.when(
        loading: () => _buildShimmerLoader(),
        error: (error, stack) => _buildErrorView(
          context,
          error.toString(),
          () => ref.refresh(propertyNotifierProvider),
        ),
        data: (propertyList) {
          if (propertyList.isEmpty) {
            return _buildEmptyState(context);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: propertyList.length,
            itemBuilder: (context, index) {
              final property = propertyList[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PropertyCard(
                  property: property,
                  onEdit: () => context.push(
                    '/properties/${property.id}/edit',
                  ),
                  onDelete: () => _showDeleteConfirmation(
                    context,
                    property.name,
                    () => _deleteProperty(context, property.id, notifier),
                  ),
                ),
              );
            },
          );
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
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(12),
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
          Icon(Icons.home_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No properties yet'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push(AppRoutes.newProperty),
            icon: const Icon(Icons.add),
            label: const Text('Add your first property'),
          ),
        ],
      ),
    );
  }

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
    String propertyId,
    dynamic notifier,
  ) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Deleting property...')),
    );
    final success = (await notifier.delete(propertyId)) as bool?;
    if ((success ?? false) && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property deleted')),
      );
    } else if (context.mounted && !(success ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete property')),
      );
    }
  }
}
