import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:proptrack/features/properties/domain/entities/property_entity.dart';
import 'package:proptrack/features/properties/domain/repositories/property_repository.dart';
import 'package:proptrack/features/properties/presentation/providers/property_providers.dart';

// ─────────────────────────────────────────────────────────────────────────
// Design tokens (per DESIGN_properties.md)
// ─────────────────────────────────────────────────────────────────────────

const _surface = Color(0xFFF7F9FB);
const _surfaceLowest = Colors.white;
const _surfaceContainer = Color(0xFFECEEF0);
const _surfaceContainerLow = Color(0xFFF2F4F6);
const _surfaceContainerHigh = Color(0xFFE6E8EA);
const _surfaceContainerHighest = Color(0xFFE0E3E5);
const _outlineVariant = Color(0xFFC5C6CE);
const _outline = Color(0xFF75777E);
const _onSurface = Color(0xFF191C1E);
const _onSurfaceVariant = Color(0xFF44474D);
const _onBackground = Color(0xFF191C1E);
const _navy = Color(0xFF0A1A33);
const _primaryContainer = Color(0xFF0C1B34);
const _onPrimary = Colors.white;
const _emerald = Color(0xFF006C49);
const _secondaryContainer = Color(0xFF6CF8BB);
const _onSecondaryContainer = Color(0xFF00714D);
const _secondaryFixedDim = Color(0xFF4EDEA3);
const _tertiaryFixed = Color(0xFFD8E2FF);
const _onTertiaryContainer = Color(0xFF3980F4);
const _onTertiaryFixed = Color(0xFF001A42);
const _danger = Color(0xFFBA1A1A);
const _dangerContainer = Color(0xFFFFDAD6);
const _onDangerContainer = Color(0xFF93000A);

const _level2Shadow = [
  BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 6,
    offset: Offset(0, 4),
    spreadRadius: -1,
  ),
  BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 4,
    offset: Offset(0, 2),
    spreadRadius: -2,
  ),
];

// ─────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────

class PropertiesPage extends ConsumerStatefulWidget {
  const PropertiesPage({super.key});

  @override
  ConsumerState<PropertiesPage> createState() => _PropertiesPageState();
}

class _PropertiesPageState extends ConsumerState<PropertiesPage> {
  final _searchController = TextEditingController();
  String _searchText = '';
  String _selectedFilter = 'all';

  static const _filters = <(String, String)>[
    ('all', 'All Properties'),
    ('residential', 'Residential'),
    ('commercial', 'Commercial'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // PropertyEntity has no `type` field yet — once the schema exposes it,
  // derive here so filters become meaningful.
  String _typeOf(PropertyEntity property) => 'residential';

  List<PropertyEntity> _filtered(List<PropertyEntity> properties) {
    final query = _searchText.trim().toLowerCase();
    return properties.where((p) {
      final type = _typeOf(p);
      final matchesChip = _selectedFilter == 'all' || type == _selectedFilter;
      final matchesSearch = query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          (p.location?.toLowerCase().contains(query) ?? false);
      return matchesChip && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(propertyNotifierProvider);

    return ColoredBox(
      color: _surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 1024;
          return isWide ? _buildDesktop(state) : _buildMobile(state);
        },
      ),
    );
  }

  // ─────────────────────── Desktop layout ───────────────────────

  Widget _buildDesktop(AsyncValue<List<PropertyEntity>> state) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDesktopHeader(),
                const SizedBox(height: 32),
                _buildDesktopFilters(),
                const SizedBox(height: 32),
                _buildList(state, isWide: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'My Properties',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w600,
                  color: _onBackground,
                  letterSpacing: -0.96,
                  height: 1.17,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Manage and track your real estate portfolio.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: _onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        ElevatedButton.icon(
          onPressed: _showAddSheet,
          icon: const Icon(Icons.add, size: 18),
          label: const Text(
            'Add Property',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _navy,
            foregroundColor: _onPrimary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
            minimumSize: const Size(0, 48),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopFilters() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final (id, label) in _filters) ...[
                  _FilterPill(
                    label: label,
                    selected: _selectedFilter == id,
                    onTap: () => setState(() => _selectedFilter = id),
                  ),
                  const SizedBox(width: 12),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        _FilterPill(
          label: 'More Filters',
          selected: false,
          icon: Icons.filter_list,
          onTap: () {},
        ),
      ],
    );
  }

  // ─────────────────────── Mobile layout ───────────────────────

  Widget _buildMobile(AsyncValue<List<PropertyEntity>> state) {
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMobileHeader(),
                  const SizedBox(height: 24),
                  _buildMobileSearch(),
                  const SizedBox(height: 20),
                  _buildMobileFilters(),
                  const SizedBox(height: 24),
                  _buildList(state, isWide: false),
                ],
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              heroTag: 'properties_fab',
              backgroundColor: _primaryContainer,
              foregroundColor: _onPrimary,
              onPressed: _showAddSheet,
              child: const Icon(Icons.add, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader() {
    return const Center(
      child: Text(
        'My Properties',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _navy,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildMobileSearch() {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchText = v),
        style: const TextStyle(color: _onSurface, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Search by name, location or ID...',
          hintStyle: const TextStyle(color: _outline, fontSize: 16),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 16, right: 12),
            child: Icon(Icons.search, color: _outline, size: 22),
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 0, minHeight: 0),
          filled: true,
          fillColor: _surfaceLowest,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9999),
            borderSide: const BorderSide(color: _outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9999),
            borderSide: const BorderSide(color: _outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9999),
            borderSide:
                const BorderSide(color: _onTertiaryContainer, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (id, label) in _filters) ...[
            _FilterPill(
              label: id == 'all' ? 'All' : label,
              selected: _selectedFilter == id,
              onTap: () => setState(() => _selectedFilter = id),
            ),
            const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }

  // ─────────────────────── Shared list ───────────────────────

  Widget _buildList(
    AsyncValue<List<PropertyEntity>> state, {
    required bool isWide,
  }) {
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
            style: const TextStyle(color: _onSurfaceVariant),
          ),
        ),
      ),
      data: (properties) {
        final filtered = _filtered(properties);
        if (filtered.isEmpty) return _buildEmptyState();
        return isWide
            ? _buildDesktopGrid(filtered)
            : _buildMobileColumn(filtered);
      },
    );
  }

  Widget _buildDesktopGrid(List<PropertyEntity> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 1280 ? 3 : 2;
        const spacing = 24.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (crossAxisCount - 1)) /
                crossAxisCount;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final p in items)
              SizedBox(
                width: itemWidth,
                child: _DesktopPropertyCard(
                  property: p,
                  onEdit: () => context.push('/properties/${p.id}/edit'),
                  onDetails: () => context.push('/properties/${p.id}'),
                  onDelete: () => _showDeleteDialog(p),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMobileColumn(List<PropertyEntity> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          _MobilePropertyCard(
            property: items[i],
            onView: () => context.push('/properties/${items[i].id}'),
            onEdit: () => context.push('/properties/${items[i].id}/edit'),
            onDelete: () => _showDeleteDialog(items[i]),
          ),
          if (i < items.length - 1) const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(64),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.home_work_outlined, size: 64, color: _outline),
            SizedBox(height: 16),
            Text(
              'No properties yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _onSurface,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap + to add your first property',
              style: TextStyle(fontSize: 14, color: _onSurfaceVariant),
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
        onSaved: (params, files) async {
          Navigator.pop(context);
          await ref
              .read(propertyNotifierProvider.notifier)
              .createWithFiles(params, files);
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
              style: TextStyle(color: _danger),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Filter pill
// ─────────────────────────────────────────────────────────────────────────

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? _navy : _surfaceContainer;
    final fg = selected ? _onPrimary : _onSurface;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: fg),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: fg,
                    letterSpacing: 0.6,
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

// ─────────────────────────────────────────────────────────────────────────
// Status (derived from progress)
// ─────────────────────────────────────────────────────────────────────────

enum _PropertyStatus { onTrack, dueSoon, behind }

_PropertyStatus _statusFor(double progress) {
  if (progress >= 0.5) return _PropertyStatus.onTrack;
  if (progress >= 0.25) return _PropertyStatus.dueSoon;
  return _PropertyStatus.behind;
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final _PropertyStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg, icon) = _styleFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ] else ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
              letterSpacing: 0.6,
              height: 1.33,
            ),
          ),
        ],
      ),
    );
  }

  (String, Color, Color, IconData?) _styleFor(_PropertyStatus status) {
    switch (status) {
      case _PropertyStatus.onTrack:
        return (
          'On Track',
          _onSecondaryContainer,
          _secondaryContainer.withValues(alpha: 0.4),
          null,
        );
      case _PropertyStatus.dueSoon:
        return (
          'Due Soon',
          _onTertiaryFixed,
          _tertiaryFixed,
          Icons.schedule,
        );
      case _PropertyStatus.behind:
        return (
          'Overdue',
          _danger,
          _dangerContainer.withValues(alpha: 0.5),
          Icons.warning_amber_outlined,
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Desktop property card
// ─────────────────────────────────────────────────────────────────────────

class _DesktopPropertyCard extends StatefulWidget {
  const _DesktopPropertyCard({
    required this.property,
    required this.onEdit,
    required this.onDetails,
    required this.onDelete,
  });

  final PropertyEntity property;
  final VoidCallback onEdit;
  final VoidCallback onDetails;
  final VoidCallback onDelete;

  @override
  State<_DesktopPropertyCard> createState() => _DesktopPropertyCardState();
}

class _DesktopPropertyCardState extends State<_DesktopPropertyCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    final progress =
        p.totalPrice > 0 ? (p.paidAmount / p.totalPrice).clamp(0.0, 1.0) : 0.0;
    final status = _statusFor(progress);
    final progressColor = switch (status) {
      _PropertyStatus.onTrack => _emerald,
      _PropertyStatus.dueSoon => _onTertiaryContainer,
      _PropertyStatus.behind => _danger,
    };
    final percentColor = status == _PropertyStatus.behind ? _danger : _navy;
    final currency = _currencyFor(p.currency);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _surfaceLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _surfaceContainer),
          boxShadow: _hovering
              ? const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 25,
                    offset: Offset(0, 20),
                    spreadRadius: -5,
                  ),
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 10,
                    offset: Offset(0, 10),
                    spreadRadius: -5,
                  ),
                ]
              : _level2Shadow,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title + status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        p.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: _onSurface,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if ((p.location ?? '').isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: _onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                p.location!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: _onSurfaceVariant,
                                  height: 1.43,
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
                _StatusChip(status: status),
              ],
            ),
            const SizedBox(height: 24),

            // Progress
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Installment Progress',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _onSurfaceVariant,
                      letterSpacing: 0.6,
                      height: 1.33,
                    ),
                  ),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: percentColor,
                    letterSpacing: 0.6,
                    height: 1.33,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(9999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: _surfaceContainer,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            const SizedBox(height: 24),

            // Paid / Total
            Row(
              children: [
                Expanded(
                  child: _DataBlock(
                    label: 'Paid to Date',
                    value: currency.format(p.paidAmount),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _DataBlock(
                    label: 'Total Value',
                    value: currency.format(p.totalPrice),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(
              height: 1,
              thickness: 1,
              color: _surfaceContainerHighest,
            ),
            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                Expanded(
                  child: _OutlinedActionButton(
                    label: 'Edit',
                    onTap: widget.onEdit,
                    filled: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _OutlinedActionButton(
                    label: 'Details',
                    onTap: widget.onDetails,
                  ),
                ),
                const SizedBox(width: 8),
                _IconActionButton(
                  icon: Icons.delete_outline,
                  onTap: widget.onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DataBlock extends StatelessWidget {
  const _DataBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _onSurfaceVariant,
            letterSpacing: 0.6,
            height: 1.33,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _onSurface,
              height: 1.43,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

class _OutlinedActionButton extends StatelessWidget {
  const _OutlinedActionButton({
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: filled
          ? ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: _surfaceContainerLow,
                foregroundColor: _onSurface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                backgroundColor: _surfaceLowest,
                foregroundColor: _onSurface,
                side: const BorderSide(color: _outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
            ),
    );
  }
}

class _IconActionButton extends StatefulWidget {
  const _IconActionButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_IconActionButton> createState() => _IconActionButtonState();
}

class _IconActionButtonState extends State<_IconActionButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: SizedBox(
        height: 40,
        width: 44,
        child: Material(
          color: _hovering ? _dangerContainer : _surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(8),
            child: Icon(
              widget.icon,
              size: 18,
              color: _hovering ? _danger : _onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Mobile property card
// ─────────────────────────────────────────────────────────────────────────

class _MobilePropertyCard extends StatelessWidget {
  const _MobilePropertyCard({
    required this.property,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final PropertyEntity property;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final p = property;
    final progress =
        p.totalPrice > 0 ? (p.paidAmount / p.totalPrice).clamp(0.0, 1.0) : 0.0;
    final status = _statusFor(progress);
    final progressColor = switch (status) {
      _PropertyStatus.onTrack => _emerald,
      _PropertyStatus.dueSoon => _onTertiaryContainer,
      _PropertyStatus.behind => _danger,
    };
    final accentColor = switch (status) {
      _PropertyStatus.onTrack => _emerald,
      _PropertyStatus.dueSoon => _onTertiaryContainer,
      _PropertyStatus.behind => _danger,
    };
    final currency = _currencyFor(p.currency);

    return Container(
      decoration: BoxDecoration(
        color: _surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: _level2Shadow,
        border: Border.all(color: _outlineVariant.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title + status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  p.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: _onSurface,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              _MobileStatusChip(status: status),
            ],
          ),
          const SizedBox(height: 16),

          // Progress
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Installment Progress',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _onSurfaceVariant,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _onSurface,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: _surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 20),

          // Paid / Total
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Paid to Date',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _onSurfaceVariant,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        currency.format(p.paidAmount),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _onSurface,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Value',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _onSurfaceVariant,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        currency.format(p.totalPrice),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _onSurface,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(
            height: 1,
            thickness: 1,
            color: _surfaceContainerHigh,
          ),
          const SizedBox(height: 12),

          // Actions
          Row(
            children: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 22),
                color: _onSurfaceVariant,
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 22),
                color: _danger,
                visualDensity: VisualDensity.compact,
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: onView,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: accentColor, width: 2),
                  foregroundColor: accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'VIEW PROPERTY',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                    letterSpacing: 0.6,
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

/// Pill-shaped status chip used on mobile (matches screen.png).
class _MobileStatusChip extends StatelessWidget {
  const _MobileStatusChip({required this.status});

  final _PropertyStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg) = _styleFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
          letterSpacing: 0.6,
          height: 1.33,
        ),
      ),
    );
  }

  (String, Color, Color) _styleFor(_PropertyStatus status) {
    switch (status) {
      case _PropertyStatus.onTrack:
        return ('On Track', _onSecondaryContainer, _secondaryFixedDim);
      case _PropertyStatus.dueSoon:
        return ('Due Soon', _onTertiaryFixed, _tertiaryFixed);
      case _PropertyStatus.behind:
        return ('Behind', _onDangerContainer, _dangerContainer);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────

NumberFormat _currencyFor(String currency) {
  final symbol = switch (currency) {
    'EGP' => 'E£ ',
    'USD' => r'$ ',
    'AED' => 'AED ',
    'EUR' => '€ ',
    'GBP' => '£ ',
    'SAR' => 'SAR ',
    _ => '$currency ',
  };
  return NumberFormat.currency(
    locale: 'en_US',
    symbol: symbol,
    decimalDigits: 0,
  );
}

// ─────────────────────────────────────────────────────────────────────────
// Add Property bottom sheet (preserved from prior implementation)
// ─────────────────────────────────────────────────────────────────────────

class _AddPropertySheet extends ConsumerStatefulWidget {
  const _AddPropertySheet({required this.onSaved});

  final Future<void> Function(CreatePropertyParams, List<XFile>) onSaved;

  @override
  ConsumerState<_AddPropertySheet> createState() => _AddPropertySheetState();
}

class _AddPropertySheetState extends ConsumerState<_AddPropertySheet> {
  static const _maxFiles = 10;

  final _name = TextEditingController();
  final _developer = TextEditingController();
  final _location = TextEditingController();
  final _price = TextEditingController();
  String _currency = 'EGP';
  final List<XFile> _files = [];
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _developer.dispose();
    _location.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: const [
        'pdf',
        'jpg',
        'jpeg',
        'png',
        'webp',
        'xls',
        'xlsx',
      ],
    );
    if (result == null) return;

    final picked = <XFile>[];
    for (final f in result.files) {
      if (f.path != null) {
        picked.add(XFile(f.path!, name: f.name, bytes: f.bytes));
      } else if (f.bytes != null) {
        picked.add(XFile.fromData(f.bytes!, name: f.name));
      }
    }

    setState(() {
      final remaining = _maxFiles - _files.length;
      _files.addAll(picked.take(remaining));
    });
  }

  void _removeFile(int index) {
    setState(() => _files.removeAt(index));
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
                  fontWeight: FontWeight.w600,
                  color: _onSurface,
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
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
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
                      decoration: const InputDecoration(
                        labelText: 'Currency',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Payment Plan (optional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _onSurface,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Upload PDF, images or Excel files (max 10)',
                style: TextStyle(
                  fontSize: 12,
                  color: _onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              _UploadDropZone(
                enabled: _files.length < _maxFiles,
                onTap: _pickFiles,
              ),
              if (_files.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < _files.length; i++)
                      _FileChip(
                        name: _files[i].name,
                        onRemove: () => _removeFile(i),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saving
                      ? null
                      : () async {
                          if (_name.text.isEmpty || _price.text.isEmpty) return;
                          final price = double.tryParse(_price.text);
                          if (price == null || price <= 0) return;
                          setState(() => _saving = true);
                          await widget.onSaved(
                            CreatePropertyParams(
                              name: _name.text,
                              developer: _developer.text.isEmpty
                                  ? null
                                  : _developer.text,
                              location: _location.text.isEmpty
                                  ? null
                                  : _location.text,
                              totalPrice: price,
                              currency: _currency,
                            ),
                            List<XFile>.from(_files),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _navy,
                    foregroundColor: _onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(_onPrimary),
                          ),
                        )
                      : const Text(
                          'Add Property',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.6,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UploadDropZone extends StatelessWidget {
  const _UploadDropZone({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: DottedBorderBox(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.upload_file_outlined,
                size: 28,
                color: enabled ? _onSurfaceVariant : _outlineVariant,
              ),
              const SizedBox(height: 8),
              Text(
                enabled ? 'Tap to upload' : 'Maximum files reached',
                style: TextStyle(
                  fontSize: 14,
                  color: enabled ? _onSurfaceVariant : _outlineVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Container with a dashed outline drawn via CustomPaint (no extra deps).
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: SizedBox(
        width: double.infinity,
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  static const _radius = 8.0;
  static const _dash = 6.0;
  static const _gap = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _outlineVariant
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(_radius),
    );
    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + _dash;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FileChip extends StatelessWidget {
  const _FileChip({required this.name, required this.onRemove});

  final String name;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 4, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: _surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.insert_drive_file_outlined,
            size: 16,
            color: _onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: _onSurface,
              ),
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 16),
            color: _onSurfaceVariant,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }
}
