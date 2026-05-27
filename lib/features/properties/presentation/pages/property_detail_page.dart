import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:proptrack/features/installments/domain/entities/installment_entity.dart';
import 'package:proptrack/features/installments/presentation/providers/installment_providers.dart';
import 'package:proptrack/features/properties/domain/entities/property_entity.dart';
import 'package:proptrack/features/properties/presentation/providers/property_providers.dart';

// ─────────────────────────────────────────────────────────────────────────
// Design tokens (per DESIGN_properties.md & DESIGN_DASGBOARD.md)
// ─────────────────────────────────────────────────────────────────────────

const _surface = Color(0xFFF7F9FB);
const _surfaceLowest = Colors.white;
const _surfaceContainer = Color(0xFFECEEF0);
const _surfaceContainerHigh = Color(0xFFE6E8EA);
const _outlineVariant = Color(0xFFC5C6CE);
const _onSurface = Color(0xFF191C1E);
const _onSurfaceVariant = Color(0xFF44474D);
const _onBackground = Color(0xFF191C1E);
const _navy = Color(0xFF0A1A33);
const _primaryContainer = Color(0xFF0C1B34);
const _onPrimary = Colors.white;
const _emerald = Color(0xFF006C49);
const _secondaryContainer = Color(0xFF6CF8BB);
const _onSecondaryContainer = Color(0xFF00714D);
const _warning = Color(0xFFD97706);
const _warningContainer = Color(0xFFFEF3C7);
const _warningDot = Color(0xFFF59E0B);
const _danger = Color(0xFFBA1A1A);

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

enum _InstallmentStatus { paid, pending, upcoming, overdue }

class _StatusInfo {
  const _StatusInfo(this.status, this.label, this.bg, this.fg, this.dot);
  final _InstallmentStatus status;
  final String label;
  final Color bg;
  final Color fg;
  final Color dot;
}

_StatusInfo _statusFor(InstallmentEntity inst) {
  if (inst.isPaid) {
    return const _StatusInfo(
      _InstallmentStatus.paid,
      'PAID',
      _secondaryContainer,
      _onSecondaryContainer,
      _emerald,
    );
  }
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final due = DateTime(inst.dueDate.year, inst.dueDate.month, inst.dueDate.day);
  final diffDays = due.difference(today).inDays;
  if (diffDays < 0) {
    return const _StatusInfo(
      _InstallmentStatus.overdue,
      'OVERDUE',
      Color(0xFFFFDAD6),
      Color(0xFF93000A),
      _danger,
    );
  }
  if (diffDays <= 7) {
    return const _StatusInfo(
      _InstallmentStatus.pending,
      'PENDING',
      Color(0xFFD8E2FF),
      Color(0xFF001A42),
      _warningDot,
    );
  }
  return const _StatusInfo(
    _InstallmentStatus.upcoming,
    'UPCOMING',
    _surfaceContainerHigh,
    _onSurfaceVariant,
    _outlineVariant,
  );
}

String _formatDueLabel(InstallmentEntity inst) {
  if (inst.isPaid) {
    return DateFormat('MMM d, yyyy').format(inst.paidAt ?? inst.dueDate);
  }
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final due = DateTime(inst.dueDate.year, inst.dueDate.month, inst.dueDate.day);
  final diffDays = due.difference(today).inDays;
  if (diffDays < 0) {
    return 'Overdue by ${-diffDays}d';
  }
  if (diffDays == 0) {
    return 'Due today';
  }
  if (diffDays <= 7) {
    return 'Due in $diffDays day${diffDays == 1 ? '' : 's'}';
  }
  return DateFormat('MMM d, yyyy').format(inst.dueDate);
}

String _formatCurrency(double amount, String currency) {
  final symbol = switch (currency.toUpperCase()) {
    'USD' => r'$',
    'EUR' => '€',
    'GBP' => '£',
    'EGP' => 'E£ ',
    'AED' => 'AED ',
    _ => '$currency ',
  };
  final value = NumberFormat('#,##0').format(amount);
  return '$symbol$value';
}

enum _TypeFilter { all, monthly, quarterly, yearly }

// ─────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────

class PropertyDetailPage extends ConsumerStatefulWidget {
  const PropertyDetailPage({required this.propertyId, super.key});

  final String propertyId;

  @override
  ConsumerState<PropertyDetailPage> createState() =>
      _PropertyDetailPageState();
}

class _PropertyDetailPageState extends ConsumerState<PropertyDetailPage> {
  _TypeFilter _filter = _TypeFilter.all;

  List<InstallmentEntity> _applyFilter(List<InstallmentEntity> all) {
    if (_filter == _TypeFilter.all) return all;
    final keyword = switch (_filter) {
      _TypeFilter.monthly => 'monthly',
      _TypeFilter.quarterly => 'quarterly',
      _TypeFilter.yearly => 'yearly',
      _TypeFilter.all => '',
    };
    return all.where((i) {
      final label = (i.label ?? '').toLowerCase();
      return label.contains(keyword);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final propertiesState = ref.watch(propertyNotifierProvider);

    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: propertiesState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorView(
            message: 'Failed to load property: $error',
            onBack: () => context.pop(),
          ),
          data: (properties) {
            PropertyEntity? property;
            for (final p in properties) {
              if (p.id == widget.propertyId) {
                property = p;
                break;
              }
            }
            if (property == null) {
              return _ErrorView(
                message: 'Property not found.',
                onBack: () => context.pop(),
              );
            }
            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 1024;
                return isWide
                    ? _buildDesktop(property!)
                    : _buildMobile(property!);
              },
            );
          },
        ),
      ),
    );
  }

  // ─────────────────────── Desktop layout ───────────────────────

  Widget _buildDesktop(PropertyEntity property) {
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
                _buildDesktopHeader(property),
                const SizedBox(height: 32),
                _buildHeroCard(property, isWide: true),
                const SizedBox(height: 32),
                _buildActionButtons(isWide: true),
                const SizedBox(height: 32),
                _buildInstallmentsSection(isWide: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopHeader(PropertyEntity property) {
    return Row(
      children: [
        _IconButtonCircle(
          icon: Icons.arrow_back,
          onTap: () => context.pop(),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            property.name,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: _onBackground,
              letterSpacing: -0.64,
              height: 1.25,
            ),
          ),
        ),
        const SizedBox(width: 16),
        _IconButtonCircle(
          icon: Icons.more_vert,
          onTap: () {},
        ),
      ],
    );
  }

  // ─────────────────────── Mobile layout ───────────────────────

  Widget _buildMobile(PropertyEntity property) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMobileHeader(property),
            const SizedBox(height: 16),
            _buildHeroCard(property, isWide: false),
            const SizedBox(height: 16),
            _buildActionButtons(isWide: false),
            const SizedBox(height: 16),
            _buildInstallmentsSection(isWide: false),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileHeader(PropertyEntity property) {
    return Row(
      children: [
        _IconButtonCircle(
          icon: Icons.arrow_back,
          onTap: () => context.pop(),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 40),
              child: Text(
                property.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: _navy,
                  height: 1.4,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────── Hero card ───────────────────────

  Widget _buildHeroCard(PropertyEntity property, {required bool isWide}) {
    final remaining = property.totalPrice - property.paidAmount;
    final progress = property.totalPrice <= 0
        ? 0.0
        : (property.paidAmount / property.totalPrice).clamp(0.0, 1.0);
    final progressPct = (progress * 100).round();
    final paidCount = property.paidInstallments;
    final totalCount = property.totalInstallments;

    return Container(
      decoration: BoxDecoration(
        color: _surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: _level2Shadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Decorative background corner
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: _secondaryContainer.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isWide ? 32 : 24),
              child: isWide
                  ? _buildHeroDesktop(property, remaining, progress,
                      progressPct, paidCount, totalCount)
                  : _buildHeroMobile(property, remaining, progress,
                      progressPct, paidCount, totalCount),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroDesktop(
    PropertyEntity property,
    double remaining,
    double progress,
    int progressPct,
    int paidCount,
    int totalCount,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: developer + location + status badge
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if ((property.developer ?? '').isNotEmpty) ...[
                _labelText('DEVELOPER'),
                const SizedBox(height: 4),
                Text(
                  property.developer!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: _primaryContainer,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if ((property.location ?? '').isNotEmpty) ...[
                _labelText('LOCATION'),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 20, color: _onSurfaceVariant),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        property.location!,
                        style: const TextStyle(
                          fontSize: 18,
                          color: _onSurface,
                          height: 1.55,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
              _onTrackBadge(progress),
            ],
          ),
        ),
        const SizedBox(width: 32),
        // Right: financial summary card
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _outlineVariant),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _labelText('TOTAL PRICE'),
                const SizedBox(height: 4),
                Text(
                  _formatCurrency(property.totalPrice, property.currency),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                    color: _primaryContainer,
                    letterSpacing: -0.8,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: _outlineVariant, height: 1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _labelText('PAID'),
                          const SizedBox(height: 4),
                          Text(
                            _formatCurrency(
                                property.paidAmount, property.currency),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: _emerald,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _labelText('REMAINING'),
                          const SizedBox(height: 4),
                          Text(
                            _formatCurrency(remaining, property.currency),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: _onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _progressBar(progress, progressPct, paidCount, totalCount,
                    showFootnote: false),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroMobile(
    PropertyEntity property,
    double remaining,
    double progress,
    int progressPct,
    int paidCount,
    int totalCount,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          property.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: _primaryContainer,
            letterSpacing: -0.24,
            height: 1.33,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if ((property.developer ?? '').isNotEmpty)
              Flexible(
                child: Text(
                  property.developer!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: _onSurfaceVariant,
                    height: 1.43,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if ((property.developer ?? '').isNotEmpty &&
                (property.location ?? '').isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: _outlineVariant,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
            ],
            if ((property.location ?? '').isNotEmpty) ...[
              const Icon(Icons.location_on_outlined,
                  size: 14, color: _onSurfaceVariant),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  property.location!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: _onSurfaceVariant,
                    height: 1.43,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 24),
        const Divider(color: _surfaceContainerHigh, height: 1),
        const SizedBox(height: 16),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _statCell(
                  'TOTAL PRICE',
                  _formatCurrency(property.totalPrice, property.currency),
                  _primaryContainer,
                ),
              ),
              const VerticalDivider(
                  color: _surfaceContainerHigh, thickness: 1, width: 16),
              Expanded(
                child: _statCell(
                  'PAID',
                  _formatCurrency(property.paidAmount, property.currency),
                  _emerald,
                ),
              ),
              const VerticalDivider(
                  color: _surfaceContainerHigh, thickness: 1, width: 16),
              Expanded(
                child: _statCell(
                  'REMAINING',
                  _formatCurrency(remaining, property.currency),
                  _onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Divider(color: _surfaceContainerHigh, height: 1),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress ($progressPct%)',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _onSurfaceVariant,
                letterSpacing: 0.6,
                height: 1.33,
              ),
            ),
            _onTrackBadge(progress),
          ],
        ),
        const SizedBox(height: 8),
        _progressBarTrack(progress),
        if (totalCount > 0) ...[
          const SizedBox(height: 8),
          Text(
            '$paidCount of $totalCount installments paid',
            style: const TextStyle(
              fontSize: 14,
              color: _onSurfaceVariant,
              height: 1.43,
            ),
          ),
        ],
      ],
    );
  }

  Widget _statCell(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelText(label),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor,
            height: 1.43,
          ),
        ),
      ],
    );
  }

  Widget _progressBar(
    double progress,
    int progressPct,
    int paidCount,
    int totalCount, {
    required bool showFootnote,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Payment Progress',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _onSurfaceVariant,
                letterSpacing: 0.6,
                height: 1.33,
              ),
            ),
            Text(
              '$progressPct%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _primaryContainer,
                letterSpacing: 0.6,
                height: 1.33,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _progressBarTrack(progress),
        if (showFootnote && totalCount > 0) ...[
          const SizedBox(height: 8),
          Text(
            '$paidCount of $totalCount installments paid',
            style: const TextStyle(
              fontSize: 14,
              color: _onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _progressBarTrack(double progress) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 8,
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: _surfaceContainerHigh,
          valueColor: const AlwaysStoppedAnimation<Color>(_emerald),
        ),
      ),
    );
  }

  Widget _onTrackBadge(double progress) {
    final onTrack = progress > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: onTrack
            ? _secondaryContainer.withValues(alpha: 0.55)
            : _surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            onTrack ? Icons.check_circle : Icons.schedule,
            size: 14,
            color: onTrack ? _onSecondaryContainer : _onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            onTrack ? 'On Track' : 'Not Started',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: onTrack ? _onSecondaryContainer : _onSurfaceVariant,
              letterSpacing: 0.6,
              height: 1.33,
            ),
          ),
        ],
      ),
    );
  }

  Widget _labelText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _onSurfaceVariant,
        letterSpacing: 0.6,
        height: 1.33,
      ),
    );
  }

  // ─────────────────────── Action buttons ───────────────────────

  Widget _buildActionButtons({required bool isWide}) {
    final buttons = <Widget>[
      _PrimaryActionButton(
        icon: isWide ? Icons.visibility_outlined : Icons.add,
        label: isWide ? 'View Plan' : 'Add Installment',
        onTap: () {},
      ),
      _SecondaryActionButton(
        icon: Icons.auto_awesome_outlined,
        label: 'Auto-Detect',
        onTap: () {},
      ),
      _SecondaryActionButton(
        icon: Icons.account_balance_wallet_outlined,
        label: 'Payment Plan',
        onTap: () {},
      ),
    ];

    if (isWide) {
      return Row(
        children: [
          for (var i = 0; i < buttons.length; i++) ...[
            if (i > 0) const SizedBox(width: 16),
            buttons[i],
          ],
        ],
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < buttons.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            buttons[i],
          ],
        ],
      ),
    );
  }

  // ─────────────────────── Installments section ───────────────────────

  Widget _buildInstallmentsSection({required bool isWide}) {
    return Consumer(
      builder: (context, ref, _) {
        final state =
            ref.watch(installmentNotifierProvider(widget.propertyId));

        return state.when(
          loading: () => Container(
            padding: const EdgeInsets.symmetric(vertical: 60),
            decoration: BoxDecoration(
              color: _surfaceLowest,
              borderRadius: BorderRadius.circular(12),
              boxShadow: _level2Shadow,
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _surfaceLowest,
              borderRadius: BorderRadius.circular(12),
              boxShadow: _level2Shadow,
            ),
            child: Text(
              'Error loading installments: $error',
              style: const TextStyle(color: _danger),
            ),
          ),
          data: (all) {
            final filtered = _applyFilter(all);
            return isWide
                ? _installmentsDesktop(all, filtered)
                : _installmentsMobile(all, filtered);
          },
        );
      },
    );
  }

  Widget _installmentsDesktop(
    List<InstallmentEntity> all,
    List<InstallmentEntity> filtered,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _outlineVariant),
        boxShadow: _level2Shadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Row(
                children: [
                  Text(
                    'Installments (${all.length})',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: _primaryContainer,
                      height: 1.4,
                    ),
                  ),
                  const Spacer(),
                  _filterPillGroup(),
                ],
              ),
            ),
            const Divider(color: _outlineVariant, height: 1),
            if (filtered.isEmpty)
              _emptyState()
            else
              _DesktopInstallmentsTable(
                installments: filtered,
                propertyCurrency:
                    ref.read(selectedPropertyProvider(widget.propertyId))
                            ?.currency ??
                        'USD',
                onMarkPaid: _toggleMarkPaid,
              ),
          ],
        ),
      ),
    );
  }

  Widget _installmentsMobile(
    List<InstallmentEntity> all,
    List<InstallmentEntity> filtered,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _filterPillGroup(),
        ),
        const SizedBox(height: 16),
        Text(
          'Installments (${all.length})',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: _primaryContainer,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          _emptyState()
        else
          Column(
            children: [
              for (final inst in filtered) ...[
                _MobileInstallmentCard(
                  installment: inst,
                  currency:
                      ref.read(selectedPropertyProvider(widget.propertyId))
                              ?.currency ??
                          'USD',
                  onMarkPaid: () => _toggleMarkPaid(inst),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
      ],
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(Icons.calendar_today_outlined,
              size: 48, color: _outlineVariant),
          const SizedBox(height: 12),
          const Text(
            'No installments yet',
            style: TextStyle(
              fontSize: 14,
              color: _onSurfaceVariant,
              height: 1.43,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterPillGroup() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _segmentedPill('All', _TypeFilter.all),
          _segmentedPill('Monthly', _TypeFilter.monthly),
          _segmentedPill('Quarterly', _TypeFilter.quarterly),
          _segmentedPill('Yearly', _TypeFilter.yearly),
        ],
      ),
    );
  }

  Widget _segmentedPill(String label, _TypeFilter value) {
    final selected = _filter == value;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => setState(() => _filter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? _surfaceLowest : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? _primaryContainer : _onSurfaceVariant,
            letterSpacing: 0.6,
            height: 1.33,
          ),
        ),
      ),
    );
  }

  Future<void> _toggleMarkPaid(InstallmentEntity inst) async {
    await ref
        .read(installmentNotifierProvider(widget.propertyId).notifier)
        .togglePaid(inst.id, !inst.isPaid);
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Buttons
// ─────────────────────────────────────────────────────────────────────────

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryContainer,
        foregroundColor: _onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        minimumSize: const Size(0, 48),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: _onSurfaceVariant),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _onSurfaceVariant,
          letterSpacing: 0.6,
        ),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: _surfaceLowest,
        side: const BorderSide(color: _outlineVariant),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        minimumSize: const Size(0, 48),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _IconButtonCircle extends StatelessWidget {
  const _IconButtonCircle({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(icon, color: _onSurface, size: 22),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Desktop installments table
// ─────────────────────────────────────────────────────────────────────────

class _DesktopInstallmentsTable extends StatelessWidget {
  const _DesktopInstallmentsTable({
    required this.installments,
    required this.propertyCurrency,
    required this.onMarkPaid,
  });

  final List<InstallmentEntity> installments;
  final String propertyCurrency;
  final Future<void> Function(InstallmentEntity) onMarkPaid;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: _surfaceLowest,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: const Row(
            children: [
              Expanded(flex: 3, child: _Th('NAME')),
              Expanded(flex: 2, child: _Th('TYPE')),
              Expanded(flex: 2, child: _Th('AMOUNT', alignRight: true)),
              Expanded(flex: 3, child: _Th('STATUS / DUE DATE')),
              SizedBox(width: 160, child: _Th('ACTIONS', alignRight: true)),
            ],
          ),
        ),
        const Divider(color: _surfaceContainerHigh, height: 1),
        for (var i = 0; i < installments.length; i++) ...[
          _DesktopInstallmentRow(
            installment: installments[i],
            currency: propertyCurrency,
            onMarkPaid: () => onMarkPaid(installments[i]),
          ),
          if (i < installments.length - 1)
            const Divider(color: _surfaceContainer, height: 1),
        ],
      ],
    );
  }
}

class _Th extends StatelessWidget {
  const _Th(this.text, {this.alignRight = false});
  final String text;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: alignRight ? TextAlign.right : TextAlign.left,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _onSurfaceVariant,
        letterSpacing: 0.6,
        height: 1.33,
      ),
    );
  }
}

class _DesktopInstallmentRow extends StatelessWidget {
  const _DesktopInstallmentRow({
    required this.installment,
    required this.currency,
    required this.onMarkPaid,
  });

  final InstallmentEntity installment;
  final String currency;
  final VoidCallback onMarkPaid;

  @override
  Widget build(BuildContext context) {
    final status = _statusFor(installment);
    final dueLabel = _formatDueLabel(installment);
    final isOverdueOrPending =
        status.status == _InstallmentStatus.overdue ||
            status.status == _InstallmentStatus.pending;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              installment.label ?? 'Installment',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _primaryContainer,
                height: 1.43,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _typeOf(installment),
              style: const TextStyle(
                fontSize: 14,
                color: _onSurface,
                height: 1.43,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatCurrency(installment.amount, currency),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _onSurface,
                height: 1.43,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                _StatusBadge(status: status),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    dueLabel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isOverdueOrPending ? FontWeight.w600 : FontWeight.w400,
                      color: status.status == _InstallmentStatus.overdue
                          ? _danger
                          : (status.status == _InstallmentStatus.pending
                              ? _danger
                              : _onSurfaceVariant),
                      height: 1.43,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 160,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _IconAction(
                  icon: Icons.visibility_outlined,
                  tooltip: 'View',
                  onTap: () {},
                ),
                if (!installment.isPaid)
                  _IconAction(
                    icon: Icons.check_circle_outline,
                    tooltip: 'Mark paid',
                    onTap: onMarkPaid,
                  ),
                _IconAction(
                  icon: Icons.edit_outlined,
                  tooltip: 'Edit',
                  onTap: () {},
                ),
                _IconAction(
                  icon: Icons.delete_outline,
                  tooltip: 'Delete',
                  iconColor: _danger,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            icon,
            size: 18,
            color: iconColor ?? _onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final _StatusInfo status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: status.bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: status.fg,
          letterSpacing: 0.4,
          height: 1.45,
        ),
      ),
    );
  }
}

String _typeOf(InstallmentEntity inst) {
  final label = (inst.label ?? '').toLowerCase();
  if (label.contains('monthly')) return 'Monthly';
  if (label.contains('quarter') || label.startsWith('q')) return 'Quarterly';
  if (label.contains('year')) return 'Yearly';
  if (label.contains('one') || label.contains('down')) return 'One-Time';
  return 'Manual';
}

// ─────────────────────────────────────────────────────────────────────────
// Mobile installment card
// ─────────────────────────────────────────────────────────────────────────

class _MobileInstallmentCard extends StatelessWidget {
  const _MobileInstallmentCard({
    required this.installment,
    required this.currency,
    required this.onMarkPaid,
  });

  final InstallmentEntity installment;
  final String currency;
  final VoidCallback onMarkPaid;

  @override
  Widget build(BuildContext context) {
    final status = _statusFor(installment);
    final isPending = status.status == _InstallmentStatus.pending ||
        status.status == _InstallmentStatus.overdue;

    return Container(
      decoration: BoxDecoration(
        color: _surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _surfaceContainerHigh),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  color: status.dot,
                  shape: BoxShape.circle,
                  boxShadow: status.status == _InstallmentStatus.paid
                      ? [
                          BoxShadow(
                            color: _emerald.withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      installment.label ?? 'Installment',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _onSurface,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _typeOf(installment),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _onSurfaceVariant,
                        letterSpacing: 0.6,
                        height: 1.33,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatCurrency(installment.amount, currency),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _onSurface,
                          height: 1.43,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (isPending)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _warningContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _formatDueLabel(installment),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _warning,
                              height: 1.43,
                            ),
                          ),
                        )
                      else
                        Text(
                          _formatDueLabel(installment),
                          style: TextStyle(
                            fontSize: 14,
                            color: installment.isPaid
                                ? _emerald
                                : _onSurfaceVariant,
                            height: 1.43,
                          ),
                        ),
                    ],
                  ),
                ),
                _IconAction(
                  icon: Icons.visibility_outlined,
                  tooltip: 'View',
                  onTap: () {},
                ),
                if (installment.isPaid)
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: _emerald,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 18,
                      color: Colors.white,
                    ),
                  )
                else
                  _IconAction(
                    icon: Icons.check_circle_outline,
                    tooltip: 'Mark paid',
                    onTap: onMarkPaid,
                  ),
                _IconAction(
                  icon: Icons.edit_outlined,
                  tooltip: 'Edit',
                  onTap: () {},
                ),
                _IconAction(
                  icon: Icons.delete_outline,
                  tooltip: 'Delete',
                  iconColor: _danger,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Error / not-found view
// ─────────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onBack});

  final String message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _IconButtonCircle(icon: Icons.arrow_back, onTap: onBack),
            ],
          ),
          const Spacer(),
          const Icon(
            Icons.error_outline,
            size: 64,
            color: _onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: _onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: _PrimaryActionButton(
              icon: Icons.arrow_back,
              label: 'Go Back',
              onTap: onBack,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
