import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:proptrack/core/theme/app_theme.dart';
import 'package:proptrack/features/properties/domain/entities/property_entity.dart';
import 'package:proptrack/features/properties/domain/repositories/property_repository.dart';
import 'package:proptrack/features/properties/presentation/providers/property_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PropertiesPage extends ConsumerStatefulWidget {
  const PropertiesPage({super.key});

  @override
  ConsumerState<PropertiesPage> createState() => _PropertiesPageState();
}

class _PropertiesPageState extends ConsumerState<PropertiesPage> {
  final _searchController = TextEditingController();
  String _searchText = '';
  String _selectedFilter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // PropertyEntity has no `type` field yet. Once the data layer exposes it,
  // derive the type here so chips/filters become meaningful.
  String _typeOf(PropertyEntity property) => 'residential';

  String _initialsFor(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'U';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final userName = user?.userMetadata?['full_name'] as String? ?? 'User';
    final initials = _initialsFor(userName);
    final state = ref.watch(propertyNotifierProvider);

    return Material(
      color: Colors.transparent,
      child: DefaultTextStyle.merge(
        style: const TextStyle(decoration: TextDecoration.none),
        child: ColoredBox(
          color: AppColors.background,
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(initials),
                    _buildSearch(),
                    _buildFilterChips(),
                    const SizedBox(height: 4),
                    _buildList(state),
                    const SizedBox(height: 96),
                  ],
                ),
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton(
                  heroTag: 'properties_fab',
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  onPressed: _showAddSheet,
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String initials) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.containerPadding,
        AppSpacing.cardGap,
        AppSpacing.containerPadding,
        0,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'My Properties',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.cardGap,
        12,
        AppSpacing.cardGap,
        0,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchText = v),
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search property name or city...',
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          prefixIcon: const Icon(
            Icons.search_outlined,
            color: AppColors.textMuted,
            size: 20,
          ),
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    const filters = <(String, String)>[
      ('all', 'All'),
      ('residential', 'Residential'),
      ('commercial', 'Commercial'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.cardGap,
        AppSpacing.base,
        AppSpacing.cardGap,
        0,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final (id, label) in filters)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _FilterChip(
                  label: label,
                  selected: _selectedFilter == id,
                  onTap: () => setState(() => _selectedFilter = id),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(AsyncValue<List<PropertyEntity>> state) {
    return state.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 64),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'Unable to load properties\n$e',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted),
          ),
        ),
      ),
      data: (properties) {
        final query = _searchText.trim().toLowerCase();
        final filtered = properties.where((p) {
          final type = _typeOf(p);
          final matchesChip =
              _selectedFilter == 'all' || type == _selectedFilter;
          final matchesSearch = query.isEmpty ||
              p.name.toLowerCase().contains(query) ||
              (p.location?.toLowerCase().contains(query) ?? false);
          return matchesChip && matchesSearch;
        }).toList();

        if (filtered.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            for (final p in filtered)
              _PropertyCard(
                property: p,
                type: _typeOf(p),
                onView: () => context.push('/properties/${p.id}'),
                onEdit: () => context.push('/properties/${p.id}/edit'),
                onDelete: () => _showDeleteDialog(p),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(64),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.home_work_outlined,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            const Text(
              'No properties yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap + to add your first property',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSheet() {
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

  void _showDeleteDialog(PropertyEntity property) {
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
              await ref
                  .read(propertyNotifierProvider.notifier)
                  .delete(property.id);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.chip),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.chip),
            border: selected
                ? null
                : Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  const _PropertyCard({
    required this.property,
    required this.type,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final PropertyEntity property;
  final String type;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static const _residentialBg = Color(0xFFDCFCE7);
  static const _residentialIcon = Color(0xFF16A34A);
  static const _residentialChipText = Color(0xFF065F46);
  static const _commercialBg = Color(0xFFDBEAFE);
  static const _commercialIcon = Color(0xFF2563EB);
  static const _commercialChipText = Color(0xFF1D4ED8);
  static const _outline = Color(0xFFE2E8F0);
  static const _progressGreen = Color(0xFF16A34A);
  static const _progressAmber = Color(0xFFD97706);
  static const _progressRed = Color(0xFFDC2626);

  @override
  Widget build(BuildContext context) {
    final isResidential = type == 'residential';
    final iconBg = isResidential ? _residentialBg : _commercialBg;
    final iconColor = isResidential ? _residentialIcon : _commercialIcon;
    final chipBg = isResidential ? _residentialBg : _commercialBg;
    final chipText = isResidential ? _residentialChipText : _commercialChipText;
    final chipLabel = isResidential ? 'Residential' : 'Commercial';

    final progress = property.totalPrice > 0
        ? (property.paidAmount / property.totalPrice).clamp(0.0, 1.0)
        : 0.0;
    final progressColor = progress > 0.7
        ? _progressGreen
        : progress > 0.4
            ? _progressAmber
            : _progressRed;
    final currency = NumberFormat.currency(symbol: 'SAR ', decimalDigits: 0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: _outline),
        boxShadow: AppShadows.card,
      ),
      padding: const EdgeInsets.all(AppSpacing.innerPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(AppRadius.icon),
                ),
                child: Icon(
                  isResidential ? Icons.home_outlined : Icons.business_outlined,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if ((property.location ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              property.location!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: chipBg,
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                child: Text(
                  chipLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: chipText,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 1, color: _outline),
          ),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Installment Progress',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: _outline,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 1, color: _outline),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PAID TO DATE',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currency.format(property.paidAmount),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'TOTAL VALUE',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currency.format(property.totalPrice),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 1, color: _outline),
          ),
          Row(
            children: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                color: AppColors.textMuted,
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 18),
                color: AppColors.danger,
                visualDensity: VisualDensity.compact,
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: onView,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: AppColors.primary,
                ),
                child: const Text(
                  'VIEW PROPERTY',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddPropertySheet extends ConsumerStatefulWidget {
  const _AddPropertySheet({required this.onSaved});

  final Future<void> Function(CreatePropertyParams) onSaved;

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
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Property',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Property Name *'),
                maxLines: 1,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _developer,
                decoration: const InputDecoration(labelText: 'Developer'),
                maxLines: 1,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _location,
                decoration: const InputDecoration(labelText: 'Location'),
                maxLines: 1,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _price,
                      decoration:
                          const InputDecoration(labelText: 'Total Price *'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _currency,
                      items: const [
                        DropdownMenuItem(value: 'EGP', child: Text('EGP')),
                        DropdownMenuItem(value: 'USD', child: Text('USD')),
                        DropdownMenuItem(value: 'AED', child: Text('AED')),
                      ],
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
                      developer:
                          _developer.text.isEmpty ? null : _developer.text,
                      location: _location.text.isEmpty ? null : _location.text,
                      totalPrice: price,
                      currency: _currency,
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
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
