import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:proptrack/features/properties/domain/entities/property_entity.dart';
import 'package:proptrack/features/properties/domain/repositories/property_repository.dart';
import 'package:proptrack/features/properties/presentation/providers/property_providers.dart';

const Color _navyBlue = Color(0xFF1A2B4A);
const Color _bgGrey = Color(0xFFF5F6FA);

class PropertiesPage extends ConsumerStatefulWidget {
  const PropertiesPage({super.key});

  @override
  ConsumerState<PropertiesPage> createState() => _PropertiesPageState();
}

class _PropertiesPageState extends ConsumerState<PropertiesPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final propertiesAsync = ref.watch(propertyNotifierProvider);

    return Scaffold(
      backgroundColor: _bgGrey,
      appBar: AppBar(
        backgroundColor: _navyBlue,
        elevation: 0,
        title: const Text(
          'Properties',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Could open a full-screen search page
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(propertyNotifierProvider),
          ),
        ],
      ),
      body: propertiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(propertyNotifierProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (properties) {
          if (properties.isEmpty) {
            return _buildEmptyState(context);
          }

          final filteredProperties = properties
              .where((p) =>
                  p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  (p.developer?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
                  (p.location?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false))
              .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search properties...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),
              if (filteredProperties.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No properties found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: filteredProperties.length,
                    itemBuilder: (context, index) {
                      final property = filteredProperties[index];
                      return _PropertyCard(property: property);
                    },
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _navyBlue,
        shape: const CircleBorder(),
        onPressed: () => _showAddPropertySheet(context),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.domain, size: 50, color: Color(0xFF1976D2)),
          ),
          const SizedBox(height: 24),
          Text(
            'No properties yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _navyBlue,
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
          SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              onPressed: () => _showAddPropertySheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Property'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _navyBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPropertySheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddPropertySheet(onPropertyAdded: () {
        Navigator.pop(context);
      }),
    );
  }
}

class _PropertyCard extends ConsumerWidget {
  final PropertyEntity property;

  const _PropertyCard({required this.property,});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = property.totalInstallments > 0
        ? property.paidInstallments / property.totalInstallments
        : 0.0;

    String getStatusText() {
      if (property.totalInstallments == 0) return 'Not Started';
      if (property.paidInstallments >= property.totalInstallments) {
        return 'Completed';
      }

      final handoverDate = property.handoverDate;
      if (handoverDate != null) {
        final daysUntilHandover = handoverDate.difference(DateTime.now()).inDays;
        if (daysUntilHandover < 0) return 'Overdue';
        if (daysUntilHandover < 30) return 'Due Soon';
      }
      return 'On Track';
    }

    Color getStatusColor() {
      final status = getStatusText();
      if (status == 'Completed') return const Color(0xFF059669);
      if (status == 'Overdue') return const Color(0xFFD32F2F);
      if (status == 'Due Soon') return const Color(0xFFF97316);
      if (status == 'Paying') return const Color(0xFF2E86AB);
      return const Color(0xFF2E86AB);
    }

    Color getProgressColor() => getStatusColor();

    final formattedPrice = NumberFormat('#,##0.00').format(property.totalPrice);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/properties/${property.id}'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left border accent
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 4,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _navyBlue,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Property Name and Status Badge
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  property.name,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: _navyBlue,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: getStatusColor().withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  getStatusText(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: getStatusColor(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Developer and Location
                          if (property.developer != null || property.location != null)
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    [property.developer, property.location]
                                        .whereType<String>()
                                        .join(' • '),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Price Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${property.currency} $formattedPrice',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _navyBlue,
                            fontSize: 16,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Progress Section with Grey Background
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      // Label and percentage
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Installments',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            '${property.paidInstallments}/${property.totalInstallments} paid',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Progress bar with percentage on right
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  getProgressColor(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _navyBlue,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Handover Date
                if (property.handoverDate != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Handover: ${DateFormat('MMM yyyy').format(property.handoverDate!)}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddPropertySheet extends ConsumerStatefulWidget {
  final VoidCallback onPropertyAdded;

  const _AddPropertySheet({required this.onPropertyAdded});

  @override
  ConsumerState<_AddPropertySheet> createState() => _AddPropertySheetState();
}

class _AddPropertySheetState extends ConsumerState<_AddPropertySheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _developerController;
  late TextEditingController _locationController;
  late TextEditingController _totalPriceController;
  late TextEditingController _downPaymentController;
  late TextEditingController _installmentsController;

  String _selectedCurrency = 'AED';
  DateTime? _selectedHandoverDate;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _developerController = TextEditingController();
    _locationController = TextEditingController();
    _totalPriceController = TextEditingController();
    _downPaymentController = TextEditingController();
    _installmentsController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _developerController.dispose();
    _locationController.dispose();
    _totalPriceController.dispose();
    _downPaymentController.dispose();
    _installmentsController.dispose();
    super.dispose();
  }

  Future<void> _selectHandoverDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => _selectedHandoverDate = picked);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedHandoverDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a handover date')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final params = CreatePropertyParams(
        name: _nameController.text.trim(),
        developer: _developerController.text.trim().isEmpty
            ? null
            : _developerController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        totalPrice: double.parse(_totalPriceController.text),
        currency: _selectedCurrency,
        handoverDate: _selectedHandoverDate,
      );

      final notifier = ref.read(propertyNotifierProvider.notifier);
      final success = await notifier.create(params);

      if (!mounted) return;

      if (success) {
        widget.onPropertyAdded();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Property added successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add property')),
        );
      }
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Add New Property',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),

                // Property Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Property Name *',
                    hintText: 'e.g., Downtown Tower Apartment',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Developer
                TextFormField(
                  controller: _developerController,
                  decoration: InputDecoration(
                    labelText: 'Developer',
                    hintText: 'e.g., Emaar Properties',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Location
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    hintText: 'e.g., Downtown Dubai',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Total Price
                TextFormField(
                  controller: _totalPriceController,
                  decoration: InputDecoration(
                    labelText: 'Total Price *',
                    hintText: '0.00',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v?.trim().isEmpty ?? true) return 'Required';
                    if (double.tryParse(v!) == null) return 'Invalid number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Currency Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedCurrency,
                  decoration: InputDecoration(
                    labelText: 'Currency *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: ['AED', 'USD', 'EUR', 'SAR', 'EGP']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCurrency = v ?? 'AED'),
                ),
                const SizedBox(height: 16),

                // Handover Date
                InkWell(
                  onTap: _selectHandoverDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Handover Date *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _selectedHandoverDate == null
                          ? 'Select date'
                          : DateFormat('MMM d, yyyy').format(_selectedHandoverDate!),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Down Payment
                TextFormField(
                  controller: _downPaymentController,
                  decoration: InputDecoration(
                    labelText: 'Down Payment',
                    hintText: '0.00',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v?.isEmpty ?? true) return null;
                    if (double.tryParse(v!) == null) return 'Invalid number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Number of Installments
                TextFormField(
                  controller: _installmentsController,
                  decoration: InputDecoration(
                    labelText: 'Number of Installments',
                    hintText: '12',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v?.isEmpty ?? true) return null;
                    if (int.tryParse(v!) == null) return 'Invalid number';
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _navyBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Save Property',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
