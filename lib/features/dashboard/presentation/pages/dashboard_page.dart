import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:proptrack/core/theme/app_colors.dart';
import 'package:proptrack/features/dashboard/domain/entities/dashboard_metrics.dart';
import 'package:proptrack/features/dashboard/domain/entities/upcoming_installment.dart';
import 'package:proptrack/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:proptrack/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:proptrack/features/dashboard/presentation/widgets/metric_card.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(dashboardMetricsProvider);
    final installmentsAsync = ref.watch(nextInstallmentsProvider);
    final user = Supabase.instance.client.auth.currentUser;
    final userName = user?.userMetadata?['name'] as String? ?? 'User';
    final userEmail = user?.email ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            DashboardHeader(
              userName: userName,
              userEmail: userEmail,
            ),
            // Metrics and Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  // Metrics Grid
                  metricsAsync.when(
                    loading: () => _buildMetricsShimmer(),
                    error: (e, st) => _buildMetricsError(),
                    data: (metrics) => _buildMetricsGrid(context, metrics),
                  ),
                  const SizedBox(height: 32),

                  // Upcoming Payments Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Upcoming Payments',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                'See all',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: installmentsAsync.when(
                            loading: () => _buildInstallmentsShimmer(),
                            error: (e, st) => _buildInstallmentsError(),
                            data: (installments) =>
                                _buildInstallmentsList(context, installments),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context, DashboardMetrics metrics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'Total Properties',
                value: metrics.totalProperties.toString(),
                icon: Icons.apartment,
                accentColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                title: 'Total Invested',
                value: NumberFormat('#,##0').format(metrics.totalInvested),
                subtitle: 'EGP',
                icon: Icons.trending_up,
                accentColor: const Color(0xFF15803D),
                currencySymbol: 'E£',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'Upcoming',
                value: metrics.upcomingPaymentsCount.toString(),
                subtitle:
                    '${NumberFormat('#,##0').format(metrics.upcomingPaymentsAmount)} EGP',
                icon: Icons.calendar_today,
                accentColor: const Color(0xFFB45309),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                title: 'Overdue',
                value: metrics.overduePaymentsCount.toString(),
                subtitle:
                    '${NumberFormat('#,##0').format(metrics.overduePaymentsAmount)} EGP',
                icon: Icons.warning,
                accentColor: const Color(0xFFB91C1C),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricsShimmer() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _shimmerCard()),
            const SizedBox(width: 12),
            Expanded(child: _shimmerCard()),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _shimmerCard()),
            const SizedBox(width: 12),
            Expanded(child: _shimmerCard()),
          ],
        ),
      ],
    );
  }

  Widget _shimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildMetricsError() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Unable to load metrics',
        style: TextStyle(color: Colors.red[700]),
      ),
    );
  }

  Widget _buildInstallmentsList(
    BuildContext context,
    List<UpcomingInstallment> installments,
  ) {
    if (installments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.check_circle, size: 56, color: Colors.green[400]),
              const SizedBox(height: 16),
              Text(
                "You're all caught up!",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'No payments due in the next 30 days',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: installments.length,
      separatorBuilder: (_, __) => Divider(
        color: Colors.grey[200],
        height: 1,
        thickness: 1,
      ),
      itemBuilder: (context, index) {
        final inst = installments[index];
        final daysUntilDue = inst.dueDate.difference(DateTime.now()).inDays;
        final indicatorColor =
            inst.isOverdue ? const Color(0xFFB91C1C) : const Color(0xFFB45309);

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inst.propertyName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      DateFormat('MMM d, yyyy').format(inst.dueDate),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${NumberFormat('#,##0.00').format(inst.amount)} EGP',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    inst.isOverdue
                        ? 'Overdue by ${daysUntilDue.abs()} days'
                        : 'Due in $daysUntilDue days',
                    style: TextStyle(
                      fontSize: 12,
                      color: inst.isOverdue
                          ? const Color(0xFFB91C1C)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInstallmentsShimmer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (_, __) => Divider(
          color: Colors.grey[200],
          height: 1,
          thickness: 1,
        ),
        itemBuilder: (_, __) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[200]!,
            highlightColor: Colors.grey[50]!,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 14,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 12,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInstallmentsError() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Unable to load payments',
        style: TextStyle(color: Colors.red[700]),
      ),
    );
  }
}
