import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:proptrack/features/dashboard/domain/entities/dashboard_metrics.dart';
import 'package:proptrack/features/dashboard/domain/entities/upcoming_installment.dart';
import 'package:proptrack/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:proptrack/features/dashboard/presentation/widgets/monthly_payments_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

String _formatEgpCompact(double amount) {
  final formatter = NumberFormat.compactCurrency(
    locale: 'en_US',
    symbol: 'E£ ',
    decimalDigits: amount >= 1e6 ? 2 : 0,
  );
  return formatter.format(amount);
}

String _formatEgp(double amount) {
  final formatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: 'E£ ',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  // Design system tokens (per DESIGN_DASGBOARD.md)
  static const _surface = Color(0xFFF7F9FB);
  static const _surfaceLowest = Colors.white;
  static const _surfaceContainer = Color(0xFFECEEF0);
  static const _surfaceContainerLow = Color(0xFFF2F4F6);
  static const _surfaceVariant = Color(0xFFE0E3E5);
  static const _outlineVariant = Color(0xFFC5C6CE);
  static const _onSurface = Color(0xFF191C1E);
  static const _onSurfaceVariant = Color(0xFF44474D);
  static const _onBackground = Color(0xFF191C1E);
  static const _navy = Color(0xFF0A1A33);

  // Status accents
  static const _emerald = Color(0xFF006C49);
  static const _emeraldContainer = Color(0xFF6CF8BB);
  static const _onEmeraldContainer = Color(0xFF00714D);
  static const _electricBlue = Color(0xFF3B82F6);
  static const _tertiaryContainer = Color(0xFF001A42);
  static const _onTertiaryContainer = Color(0xFF3980F4);
  static const _danger = Color(0xFFBA1A1A);
  static const _dangerContainer = Color(0xFFFFDAD6);
  static const _onDangerContainer = Color(0xFF93000A);
  static const _secondaryFixedDim = Color(0xFF4EDEA3);
  static const _onSecondaryFixed = Color(0xFF002113);

  static const _level2Shadow = [
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ColoredBox(
      color: _surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 1024;
          return isWide ? const _DesktopDashboard() : const _NarrowDashboard();
        },
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
// Desktop layout (>= 1024px)
// ═════════════════════════════════════════════════════════════════════════

class _DesktopDashboard extends StatelessWidget {
  const _DesktopDashboard();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                _Hero(),
                SizedBox(height: 32),
                _MetricsGridDesktop(),
                SizedBox(height: 32),
                MonthlyPaymentsChart(),
                SizedBox(height: 32),
                _ContentGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final fullName = user?.userMetadata?['full_name'] as String? ??
        user?.userMetadata?['name'] as String? ??
        'User';
    final firstName = fullName.split(' ').first;
    final initial = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U';
    final greeting = _greetingForNow();
    final dateText = DateFormat('EEEE, MMM d, y').format(DateTime.now());

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, $firstName',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: DashboardPage._onBackground,
                  letterSpacing: -0.64,
                  height: 1.25,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                dateText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: DashboardPage._onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {},
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              child: const Icon(
                Icons.notifications_outlined,
                size: 26,
                color: DashboardPage._onSurfaceVariant,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: DashboardPage._navy,
            shape: BoxShape.circle,
            boxShadow: DashboardPage._level2Shadow,
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _greetingForNow() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Metrics grid — desktop
// ─────────────────────────────────────────────────────────────────────────

class _MetricsGridDesktop extends ConsumerWidget {
  const _MetricsGridDesktop();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(dashboardMetricsProvider);

    return metricsAsync.when(
      data: (m) => _buildGrid(_metricsFor(m)),
      loading: () => _buildGrid(_placeholders, isLoading: true),
      error: (e, _) => _ErrorCard(
        title: 'Couldn’t load metrics',
        message: e.toString(),
        onRetry: () => ref.invalidate(dashboardMetricsProvider),
      ),
    );
  }

  static const _placeholders = <_MetricData>[
    _MetricData(
      label: 'Total Properties',
      value: '—',
      icon: Icons.apartment_outlined,
      iconColor: DashboardPage._onTertiaryContainer,
      bgColor: Color(0x1A001A42),
    ),
    _MetricData(
      label: 'Total Invested',
      value: '—',
      icon: Icons.account_balance_wallet_outlined,
      iconColor: DashboardPage._emerald,
      bgColor: Color(0x336CF8BB),
    ),
    _MetricData(
      label: 'Paid This Month',
      value: '—',
      icon: Icons.payments_outlined,
      iconColor: DashboardPage._tertiaryContainer,
      bgColor: Color(0x1A0C1B34),
    ),
    _MetricData(
      label: 'Upcoming',
      value: '—',
      icon: Icons.schedule,
      iconColor: DashboardPage._onSurfaceVariant,
      bgColor: DashboardPage._surfaceVariant,
    ),
  ];

  List<_MetricData> _metricsFor(DashboardMetrics m) => [
        _MetricData(
          label: 'Total Properties',
          value: m.totalProperties.toString(),
          icon: Icons.apartment_outlined,
          iconColor: DashboardPage._onTertiaryContainer,
          bgColor: const Color(0x1A001A42),
        ),
        _MetricData(
          label: 'Total Invested',
          value: _formatEgpCompact(m.totalInvested),
          icon: Icons.account_balance_wallet_outlined,
          iconColor: DashboardPage._emerald,
          bgColor: const Color(0x336CF8BB),
        ),
        _MetricData(
          label: 'Overdue',
          value: _formatEgpCompact(m.overduePaymentsAmount),
          icon: Icons.payments_outlined,
          iconColor: DashboardPage._danger,
          bgColor: const Color(0x33FFDAD6),
        ),
        _MetricData(
          label: 'Upcoming',
          value: _formatEgpCompact(m.upcomingPaymentsAmount),
          icon: Icons.schedule,
          iconColor: DashboardPage._onSurfaceVariant,
          bgColor: DashboardPage._surfaceVariant,
        ),
      ];

  Widget _buildGrid(List<_MetricData> metrics, {bool isLoading = false}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 24.0;
        final itemWidth = (constraints.maxWidth - spacing * 3) / 4;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final m in metrics)
              SizedBox(
                width: itemWidth,
                child: _MetricCardDesktop(data: m, isLoading: isLoading),
              ),
          ],
        );
      },
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
}

class _MetricCardDesktop extends StatelessWidget {
  const _MetricCardDesktop({required this.data, this.isLoading = false});

  final _MetricData data;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final valueColor = isLoading
        ? DashboardPage._onSurfaceVariant.withValues(alpha: 0.4)
        : DashboardPage._onBackground;

    return Container(
      decoration: BoxDecoration(
        color: DashboardPage._surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DashboardPage._outlineVariant),
        boxShadow: DashboardPage._level2Shadow,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: data.bgColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(data.icon, color: data.iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  data.label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: DashboardPage._onSurfaceVariant,
                    letterSpacing: 0.6,
                    height: 1.33,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              data.value,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w600,
                color: valueColor,
                letterSpacing: -0.72,
                height: 1.17,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Content grid (table + promo)
// ─────────────────────────────────────────────────────────────────────────

class _ContentGrid extends StatelessWidget {
  const _ContentGrid();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Expanded(flex: 8, child: _InstallmentsSection()),
        SizedBox(width: 24),
        Expanded(flex: 4, child: _PromoCardDesktop()),
      ],
    );
  }
}

class _InstallmentsSection extends ConsumerWidget {
  const _InstallmentsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(nextInstallmentsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Text(
                'Upcoming Installments',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: DashboardPage._onBackground,
                  height: 1.4,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {},
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: DashboardPage._navy,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        asyncList.when(
          data: (list) {
            if (list.isEmpty) return const _EmptyInstallments();
            return _InstallmentsTable(items: list.map(_toRow).toList());
          },
          loading: () => const _TableSkeleton(),
          error: (e, _) => _ErrorCard(
            title: 'Couldn’t load installments',
            message: e.toString(),
            onRetry: () => ref.invalidate(nextInstallmentsProvider),
          ),
        ),
      ],
    );
  }

  _InstallmentRow _toRow(UpcomingInstallment i) {
    final now = DateTime.now();
    final daysUntil = i.dueDate.difference(now).inDays;
    final _InstallmentStatus status;
    if (i.isOverdue) {
      status = _InstallmentStatus.overdue;
    } else if (daysUntil <= 7) {
      status = _InstallmentStatus.dueSoon;
    } else {
      status = _InstallmentStatus.onTrack;
    }

    return _InstallmentRow(
      propertyName: i.propertyName,
      detail: '—',
      amount: _formatEgp(i.amount),
      dueDate: DateFormat('MMM d, y').format(i.dueDate),
      status: status,
      icon: Icons.apartment_outlined,
    );
  }
}

enum _InstallmentStatus { overdue, dueSoon, onTrack }

class _InstallmentRow {
  const _InstallmentRow({
    required this.propertyName,
    required this.detail,
    required this.amount,
    required this.dueDate,
    required this.status,
    required this.icon,
  });

  final String propertyName;
  final String detail;
  final String amount;
  final String dueDate;
  final _InstallmentStatus status;
  final IconData icon;
}

class _InstallmentsTable extends StatelessWidget {
  const _InstallmentsTable({required this.items});

  final List<_InstallmentRow> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DashboardPage._surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DashboardPage._outlineVariant),
        boxShadow: DashboardPage._level2Shadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row
          Container(
            color: DashboardPage._surface,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: const [
                _Cell(flex: 3, child: _ColumnLabel('Property')),
                _Cell(flex: 3, child: _ColumnLabel('Detail')),
                _Cell(
                  flex: 2,
                  child: _ColumnLabel('Amount', align: TextAlign.right),
                ),
                _Cell(flex: 2, child: _ColumnLabel('Due Date')),
                _Cell(flex: 2, child: _ColumnLabel('Status')),
              ],
            ),
          ),
          // Body
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                thickness: 1,
                color: DashboardPage._outlineVariant,
              ),
            _TableBodyRow(item: items[i]),
          ],
        ],
      ),
    );
  }
}

class _ColumnLabel extends StatelessWidget {
  const _ColumnLabel(this.text, {this.align = TextAlign.left});

  final String text;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: DashboardPage._onSurfaceVariant,
        letterSpacing: 0.6,
        height: 1.33,
      ),
    );
  }
}

class _TableBodyRow extends StatefulWidget {
  const _TableBodyRow({required this.item});

  final _InstallmentRow item;

  @override
  State<_TableBodyRow> createState() => _TableBodyRowState();
}

class _TableBodyRowState extends State<_TableBodyRow> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Container(
        color:
            _hovering ? DashboardPage._surfaceContainerLow : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _Cell(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: DashboardPage._surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      widget.item.icon,
                      size: 22,
                      color: DashboardPage._onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.item.propertyName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: DashboardPage._onBackground,
                        height: 1.43,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            _Cell(
              flex: 3,
              child: Text(
                widget.item.detail,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: DashboardPage._onSurfaceVariant,
                  height: 1.43,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _Cell(
              flex: 2,
              child: Text(
                widget.item.amount,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: DashboardPage._onBackground,
                  height: 1.43,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            _Cell(
              flex: 2,
              child: Text(
                widget.item.dueDate,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: DashboardPage._onSurfaceVariant,
                  height: 1.43,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _Cell(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _StatusChip(status: widget.item.status),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.flex, required this.child});

  final int flex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: child,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final _InstallmentStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg) = _styleFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
          letterSpacing: 0.5,
          height: 1.6,
        ),
      ),
    );
  }

  (String, Color, Color) _styleFor(_InstallmentStatus status) {
    switch (status) {
      case _InstallmentStatus.overdue:
        return (
          'OVERDUE',
          DashboardPage._onDangerContainer,
          DashboardPage._dangerContainer,
        );
      case _InstallmentStatus.dueSoon:
        return (
          'DUE SOON',
          DashboardPage._onSurface,
          DashboardPage._surfaceContainer,
        );
      case _InstallmentStatus.onTrack:
        return (
          'ON TRACK',
          DashboardPage._onEmeraldContainer,
          DashboardPage._emeraldContainer.withValues(alpha: 0.4),
        );
    }
  }
}

class _TableSkeleton extends StatelessWidget {
  const _TableSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: DashboardPage._surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DashboardPage._outlineVariant),
        boxShadow: DashboardPage._level2Shadow,
      ),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class _EmptyInstallments extends StatelessWidget {
  const _EmptyInstallments();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DashboardPage._surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DashboardPage._outlineVariant),
        boxShadow: DashboardPage._level2Shadow,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: DashboardPage._surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.event_available_outlined,
              size: 28,
              color: DashboardPage._onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No upcoming installments',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: DashboardPage._onBackground,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'You’re all caught up.',
            style: TextStyle(
              fontSize: 14,
              color: DashboardPage._onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: DashboardPage._surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DashboardPage._outlineVariant),
        boxShadow: DashboardPage._level2Shadow,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: DashboardPage._danger,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: DashboardPage._onBackground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              color: DashboardPage._onSurfaceVariant,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: DashboardPage._navy,
              padding: EdgeInsets.zero,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Promo card — desktop
// ─────────────────────────────────────────────────────────────────────────

class _PromoCardDesktop extends StatelessWidget {
  const _PromoCardDesktop();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Spacer to align with the left column header
        const SizedBox(height: 28),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: DashboardPage._surfaceLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: DashboardPage._outlineVariant),
            boxShadow: DashboardPage._level2Shadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hero image with gradient + title overlay
              SizedBox(
                height: 192,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const _PromoArtwork(),
                    // Gradient overlay
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: const Text(
                        'Optimize Your Portfolio',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Body
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Discover high-yield commercial assets carefully '
                      'vetted by our institutional analysts to diversify '
                      'your holdings.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: DashboardPage._onSurfaceVariant,
                        height: 1.43,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DashboardPage._navy,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Explore Assets',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.6,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Native-painted skyscraper artwork — avoids external image dependencies.
class _PromoArtwork extends StatelessWidget {
  const _PromoArtwork();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0C1B34), Color(0xFF1A2B4A), Color(0xFF2E4A7C)],
        ),
      ),
      child: CustomPaint(painter: _PromoArtworkPainter()),
    );
  }
}

class _PromoArtworkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final building = Paint()..color = const Color(0xFF1F345C);
    final windowsLit = Paint()
      ..color = const Color(0xFFFFC56C).withValues(alpha: 0.85);
    final windowsDim = Paint()
      ..color = const Color(0xFFB8C7E8).withValues(alpha: 0.35);

    final left = Rect.fromLTWH(
      size.width * 0.15,
      size.height * 0.25,
      size.width * 0.30,
      size.height * 0.75,
    );
    final right = Rect.fromLTWH(
      size.width * 0.50,
      size.height * 0.12,
      size.width * 0.35,
      size.height * 0.88,
    );
    canvas.drawRect(left, building);
    canvas.drawRect(right, building);

    void drawWindows(Rect r, int cols, int rows) {
      final wCell = r.width / cols;
      final hCell = r.height / rows;
      for (var i = 0; i < cols; i++) {
        for (var j = 0; j < rows; j++) {
          final lit = ((i * 7 + j * 3) % 5) < 2;
          final w = wCell * 0.55;
          final h = hCell * 0.4;
          final x = r.left + i * wCell + (wCell - w) / 2;
          final y = r.top + j * hCell + (hCell - h) / 2;
          canvas.drawRect(
            Rect.fromLTWH(x, y, w, h),
            lit ? windowsLit : windowsDim,
          );
        }
      }
    }

    drawWindows(left, 4, 8);
    drawWindows(right, 5, 11);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═════════════════════════════════════════════════════════════════════════
// Narrow layout (< 1024px) — keeps the prior mobile design
// ═════════════════════════════════════════════════════════════════════════

class _NarrowDashboard extends StatelessWidget {
  const _NarrowDashboard();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            _MobileHeader(),
            SizedBox(height: 24),
            _MetricsGridMobile(),
            SizedBox(height: 32),
            MonthlyPaymentsChart(),
            SizedBox(height: 32),
            _UpcomingInstallmentsMobile(),
            SizedBox(height: 32),
            _PromoCardMobile(),
          ],
        ),
      ),
    );
  }
}

class _MobileHeader extends StatelessWidget {
  const _MobileHeader();

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final fullName = user?.userMetadata?['full_name'] as String? ??
        user?.userMetadata?['name'] as String? ??
        'User';
    final firstName = fullName.split(' ').first;
    final initial = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U';
    final greeting = _greetingForNow();
    final dateText = DateFormat('EEEE, MMMM d, y').format(DateTime.now());

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, $firstName',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: DashboardPage._navy,
                  letterSpacing: -0.24,
                  height: 1.33,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                dateText,
                style: const TextStyle(
                  fontSize: 14,
                  color: DashboardPage._onSurfaceVariant,
                  height: 1.43,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFF1A2B4A),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _greetingForNow() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }
}

class _MetricsGridMobile extends ConsumerWidget {
  const _MetricsGridMobile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(dashboardMetricsProvider);
    return metricsAsync.when(
      data: (m) => _grid([
        _MobileMetric(
          label: 'Total Properties',
          value: m.totalProperties.toString(),
          accent: DashboardPage._emerald,
        ),
        _MobileMetric(
          label: 'Total Invested',
          value: _formatEgpCompact(m.totalInvested),
          accent: DashboardPage._electricBlue,
        ),
        _MobileMetric(
          label: 'Overdue',
          value: _formatEgpCompact(m.overduePaymentsAmount),
          accent: DashboardPage._danger,
        ),
        _MobileMetric(
          label: 'Upcoming',
          value: _formatEgpCompact(m.upcomingPaymentsAmount),
          accent: DashboardPage._electricBlue,
        ),
      ]),
      loading: () => _grid([
        const _MobileMetric(
          label: 'Total Properties',
          value: '—',
          accent: DashboardPage._emerald,
        ),
        const _MobileMetric(
          label: 'Total Invested',
          value: '—',
          accent: DashboardPage._electricBlue,
        ),
        const _MobileMetric(
          label: 'Overdue',
          value: '—',
          accent: DashboardPage._danger,
        ),
        const _MobileMetric(
          label: 'Upcoming',
          value: '—',
          accent: DashboardPage._electricBlue,
        ),
      ]),
      error: (e, _) => _ErrorCard(
        title: 'Couldn’t load metrics',
        message: e.toString(),
        onRetry: () => ref.invalidate(dashboardMetricsProvider),
      ),
    );
  }

  Widget _grid(List<_MobileMetric> metrics) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 16.0;
        final itemWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final m in metrics)
              SizedBox(width: itemWidth, child: _MobileMetricCard(data: m)),
          ],
        );
      },
    );
  }
}

class _MobileMetric {
  const _MobileMetric({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;
}

class _MobileMetricCard extends StatelessWidget {
  const _MobileMetricCard({required this.data});

  final _MobileMetric data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DashboardPage._surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: DashboardPage._level2Shadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: DashboardPage._onSurfaceVariant,
                    letterSpacing: 0.6,
                    height: 1.33,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    data.value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: DashboardPage._navy,
                      letterSpacing: -0.24,
                      height: 1.33,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(height: 4, color: data.accent),
          ),
        ],
      ),
    );
  }
}

class _UpcomingInstallmentsMobile extends ConsumerWidget {
  const _UpcomingInstallmentsMobile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(nextInstallmentsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Upcoming Installments',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: DashboardPage._navy,
                  height: 1.4,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {},
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: DashboardPage._emerald,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        asyncList.when(
          data: (list) {
            if (list.isEmpty) return const _EmptyInstallments();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < list.length; i++) ...[
                  _MobileInstallmentRow(item: list[i]),
                  if (i < list.length - 1) const SizedBox(height: 16),
                ],
              ],
            );
          },
          loading: () => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < 3; i++) ...[
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: DashboardPage._surfaceLowest,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: DashboardPage._level2Shadow,
                  ),
                ),
                if (i < 2) const SizedBox(height: 16),
              ],
            ],
          ),
          error: (e, _) => _ErrorCard(
            title: 'Couldn’t load installments',
            message: e.toString(),
            onRetry: () => ref.invalidate(nextInstallmentsProvider),
          ),
        ),
      ],
    );
  }
}

class _MobileInstallmentRow extends StatelessWidget {
  const _MobileInstallmentRow({required this.item});

  final UpcomingInstallment item;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysUntil = item.dueDate.difference(now).inDays;
    final _InstallmentStatus status;
    if (item.isOverdue) {
      status = _InstallmentStatus.overdue;
    } else if (daysUntil <= 7) {
      status = _InstallmentStatus.dueSoon;
    } else {
      status = _InstallmentStatus.onTrack;
    }

    final accent = switch (status) {
      _InstallmentStatus.overdue => DashboardPage._danger,
      _InstallmentStatus.dueSoon => DashboardPage._electricBlue,
      _InstallmentStatus.onTrack => DashboardPage._emerald,
    };

    return Container(
      decoration: BoxDecoration(
        color: DashboardPage._surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: DashboardPage._level2Shadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: DashboardPage._surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.apartment_outlined,
                        size: 24,
                        color: accent,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.propertyName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: DashboardPage._onSurface,
                              height: 1.33,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMM d, y').format(item.dueDate),
                            style: const TextStyle(
                              fontSize: 14,
                              color: DashboardPage._onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatEgp(item.amount),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: DashboardPage._onSurface,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(height: 6),
                        _StatusChip(status: status),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoCardMobile extends StatelessWidget {
  const _PromoCardMobile();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DashboardPage._navy,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Optimize Your Portfolio',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.17,
                letterSpacing: -0.24,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Unlock personalized analytics and market insights to '
              'maximize your property ROI.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xCCFFFFFF),
                height: 1.57,
              ),
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: DashboardPage._secondaryFixedDim,
                  foregroundColor: DashboardPage._onSecondaryFixed,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'EXPLORE ASSETS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: const AspectRatio(
                aspectRatio: 16 / 10,
                child: _PromoArtwork(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
