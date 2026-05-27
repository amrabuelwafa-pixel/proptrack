import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:proptrack/features/dashboard/domain/entities/monthly_payments.dart';
import 'package:proptrack/features/dashboard/presentation/providers/dashboard_providers.dart';

// ─────────────────────────────────────────────────────────────────────────
// Design tokens (mirrors dashboard_page.dart)
// ─────────────────────────────────────────────────────────────────────────

const _surfaceLowest = Colors.white;
const _surfaceContainer = Color(0xFFECEEF0);
const _outlineVariant = Color(0xFFC5C6CE);
const _onBackground = Color(0xFF191C1E);
const _onSurfaceVariant = Color(0xFF44474D);
const _navy = Color(0xFF0A1A33);
const _emerald = Color(0xFF10B981);
const _electricBlue = Color(0xFF3B82F6);
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

// ─────────────────────────────────────────────────────────────────────────
// Chart card
// ─────────────────────────────────────────────────────────────────────────

class MonthlyPaymentsChart extends ConsumerWidget {
  const MonthlyPaymentsChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBuckets = ref.watch(monthlyPaymentsProvider);

    return Container(
      decoration: BoxDecoration(
        color: _surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _outlineVariant),
        boxShadow: _level2Shadow,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header — title + subtitle, legend wraps below when narrow
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: const [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Payments Trend',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: _onBackground,
                      height: 1.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Last 6 months — paid vs. due',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: _onSurfaceVariant,
                      height: 1.43,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              _Legend(),
            ],
          ),
          const SizedBox(height: 24),

          // Chart body
          SizedBox(
            height: 220,
            child: asyncBuckets.when(
              data: (buckets) {
                final hasAny = buckets.any((b) => b.paid > 0 || b.due > 0);
                if (!hasAny) return const _EmptyState();
                return _Chart(buckets: buckets);
              },
              loading: () => const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (e, _) => _ErrorState(
                message: e.toString(),
                onRetry: () => ref.invalidate(monthlyPaymentsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        _LegendDot(color: _emerald, label: 'Paid'),
        SizedBox(width: 16),
        _LegendDot(color: _electricBlue, label: 'Due'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _onSurfaceVariant,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bar_chart, size: 36, color: _outlineVariant),
          SizedBox(height: 12),
          Text(
            'No payment data yet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _onBackground,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Add installments to see trends here.',
            style: TextStyle(fontSize: 13, color: _onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 28, color: _danger),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: _onSurfaceVariant,
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: _navy,
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
// Bar chart
// ─────────────────────────────────────────────────────────────────────────

class _Chart extends StatelessWidget {
  const _Chart({required this.buckets});

  final List<MonthlyPaymentBucket> buckets;

  @override
  Widget build(BuildContext context) {
    final maxValue = _maxValue(buckets);
    // Round up to a clean upper bound so the gridlines look intentional.
    final upperBound = _niceCeiling(maxValue);
    final interval = upperBound > 0 ? upperBound / 4 : 1.0;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: upperBound,
        minY: 0,
        groupsSpace: 16,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => _navy,
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            getTooltipItem: (group, _, rod, rodIndex) {
              final bucket = buckets[group.x];
              final label = rodIndex == 0 ? 'Paid' : 'Due';
              return BarTooltipItem(
                '$label\n${_formatEgp(rod.toY)}\n'
                '${DateFormat('MMM y').format(bucket.month)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  height: 1.4,
                ),
              );
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: _surfaceContainer,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 56,
              interval: interval,
              getTitlesWidget: (value, _) {
                if (value == 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    _formatEgpCompact(value),
                    style: const TextStyle(
                      fontSize: 11,
                      color: _onSurfaceVariant,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i < 0 || i >= buckets.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('MMM').format(buckets[i].month),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _onSurfaceVariant,
                      letterSpacing: 0.6,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < buckets.length; i++)
            BarChartGroupData(
              x: i,
              barsSpace: 6,
              barRods: [
                BarChartRodData(
                  toY: buckets[i].paid,
                  color: _emerald,
                  width: 12,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                BarChartRodData(
                  toY: buckets[i].due,
                  color: _electricBlue,
                  width: 12,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  double _maxValue(List<MonthlyPaymentBucket> buckets) {
    var max = 0.0;
    for (final b in buckets) {
      if (b.paid > max) max = b.paid;
      if (b.due > max) max = b.due;
    }
    return max;
  }

  /// Round a max value up to a clean ceiling so axis labels look nice.
  double _niceCeiling(double maxValue) {
    if (maxValue <= 0) return 4;
    final magnitude =
        _pow10((maxValue.toString().split('.').first.length - 1).toDouble());
    final scaled = maxValue / magnitude;
    final ceil = scaled <= 1
        ? 1
        : scaled <= 2
            ? 2
            : scaled <= 5
                ? 5
                : 10;
    return ceil * magnitude;
  }

  double _pow10(double exp) {
    var v = 1.0;
    for (var i = 0; i < exp; i++) {
      v *= 10;
    }
    return v;
  }
}

String _formatEgp(double amount) {
  final formatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: 'E£ ',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

String _formatEgpCompact(double amount) {
  if (amount == 0) return 'E£ 0';
  return NumberFormat.compactCurrency(
    locale: 'en_US',
    symbol: 'E£ ',
    decimalDigits: amount >= 1e6 ? 1 : 0,
  ).format(amount);
}
