import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:proptrack/features/properties/domain/entities/property_entity.dart';
import 'package:proptrack/features/properties/domain/repositories/property_repository.dart';
import 'package:proptrack/features/properties/presentation/providers/property_providers.dart';

const Color _navy = Color(0xFF1A2B4A);
const Color _bg = Color(0xFFF5F6FA);

class PropertiesPage extends ConsumerWidget {
  const PropertiesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(propertyNotifierProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _navy,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.apartment_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Properties',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
            ),
          ],
        ),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 12),
              Text('$e', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(propertyNotifierProvider),
                style: ElevatedButton.styleFrom(backgroundColor: _navy, foregroundColor: Colors.white),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (properties) => properties.isEmpty
            ? _EmptyState(onAdd: () => _showAddSheet(context, ref))
            : _PropertyGrid(
                properties: properties,
                onAdd: () => _showAddSheet(context, ref),
                ref: ref,
              ),
      ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddPropertySheet(
        onSaved: (params) async {
          Navigator.pop(context);
          await ref.read(propertyNotifierProvider.notifier).create(params);
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.home_work_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text('No properties yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _navy)),
          const SizedBox(height: 8),
          Text('Add your first property to get started', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add Property'),
              style: ElevatedButton.styleFrom(backgroundColor: _navy, foregroundColor: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertyGrid extends StatelessWidget {
  final List<PropertyEntity> properties;
  final VoidCallback onAdd;
  final WidgetRef ref;
  const _PropertyGrid({required this.properties, required this.onAdd, required this.ref});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 600;
    return Column(
      children: [
        if (!isWide)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Property'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _navy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWide ? 2 : 1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 170,
            ),
            itemCount: properties.length,
            itemBuilder: (context, i) => _PropertyCard(
              property: properties[i],
              onView: () => context.push('/properties/${properties[i].id}'),
              onEdit: () => context.push('/properties/${properties[i].id}/edit'),
              onDelete: () => _showDeleteDialog(context, ref, properties[i]),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, PropertyEntity property) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Property'),
        content: Text('Are you sure you want to delete "${property.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(propertyNotifierProvider.notifier).delete(property.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  final PropertyEntity property;
  final VoidCallback onView, onEdit, onDelete;
  const _PropertyCard({
    required this.property,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final progress = property.totalPrice > 0 ? property.paidAmount / property.totalPrice : 0.0;
    final status = _getStatus(progress);
    final statusColor = _getStatusColor(status);
    final (statusBg, statusText) = _getStatusStyle(status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(property.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _navy), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          if (property.location?.isNotEmpty ?? false)
            Text(property.location!, style: TextStyle(fontSize: 12, color: Colors.grey.shade500), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation(statusColor),
            ),
          ),
          const SizedBox(height: 4),
          Text('${(progress * 100).toStringAsFixed(0)}% paid', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${property.currency} ${NumberFormat('#,##0').format(property.paidAmount)} / ${NumberFormat('#,##0').format(property.totalPrice)}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _navy),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(4)),
                child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusText)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.visibility_outlined, size: 18), onPressed: onView, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
              IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: onEdit, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
              IconButton(icon: const Icon(Icons.delete_outlined, size: 18, color: Colors.red), onPressed: onDelete, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
            ],
          ),
        ],
      ),
    );
  }

  String _getStatus(double progress) => progress < 0.3 ? 'Behind' : progress < 0.7 ? 'Due Soon' : 'On Track';

  Color _getStatusColor(String status) => status == 'On Track' ? const Color(0xFF2ECC71) : status == 'Due Soon' ? const Color(0xFFFFCC33) : const Color(0xFFEF4444);

  (Color, Color) _getStatusStyle(String status) => status == 'On Track'
      ? (const Color(0xFFE8F8F0), const Color(0xFF2ECC71))
      : status == 'Due Soon'
          ? (const Color(0xFFFFF8E1), const Color(0xFFFFCC33))
          : (const Color(0xFFFFEBEE), const Color(0xFFEF4444));
}

class _AddPropertySheet extends ConsumerStatefulWidget {
  final Future<void> Function(CreatePropertyParams) onSaved;
  const _AddPropertySheet({required this.onSaved});

  @override
  ConsumerState<_AddPropertySheet> createState() => _AddPropertySheetState();
}

class _AddPropertySheetState extends ConsumerState<_AddPropertySheet> {
  final _name = TextEditingController();
  final _developer = TextEditingController();
  final _location = TextEditingController();
  final _price = TextEditingController();
  String _currency = 'EGP';

  @override
  void dispose() {
    _name.dispose();
    _developer.dispose();
    _location.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Property', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _navy)),
              const SizedBox(height: 20),
              TextField(controller: _name, decoration: const InputDecoration(labelText: 'Property Name *'), maxLines: 1),
              const SizedBox(height: 12),
              TextField(controller: _developer, decoration: const InputDecoration(labelText: 'Developer'), maxLines: 1),
              const SizedBox(height: 12),
              TextField(controller: _location, decoration: const InputDecoration(labelText: 'Location'), maxLines: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _price,
                      decoration: const InputDecoration(labelText: 'Total Price *'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _currency,
                      items: const [DropdownMenuItem(value: 'EGP', child: Text('EGP')), DropdownMenuItem(value: 'USD', child: Text('USD')), DropdownMenuItem(value: 'AED', child: Text('AED'))],
                      onChanged: (v) => setState(() => _currency = v ?? 'EGP'),
                      decoration: const InputDecoration(labelText: 'Currency'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_name.text.isEmpty || _price.text.isEmpty) return;
                    final price = double.tryParse(_price.text);
                    if (price == null || price <= 0) return;
                    await widget.onSaved(CreatePropertyParams(
                      name: _name.text,
                      developer: _developer.text.isEmpty ? null : _developer.text,
                      location: _location.text.isEmpty ? null : _location.text,
                      totalPrice: price,
                      currency: _currency,
                    ));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: _navy, foregroundColor: Colors.white),
                  child: const Text('Add Property'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
