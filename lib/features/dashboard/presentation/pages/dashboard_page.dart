import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:proptrack/core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = Supabase.instance.client.auth.currentUser;
    final userName =
        user?.userMetadata?['full_name'] as String? ?? 'User';
    final dateText = DateFormat('EEEE, MMM d, y').format(DateTime.now());
    final greeting = _greetingForNow();
    final initials = _initialsFor(userName);

    return ColoredBox(
      color: AppColors.background,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(greeting, userName, dateText, initials),
            _buildStatsGrid(),
            _buildUpcomingSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    String greeting,
    String userName,
    String dateText,
    String initials,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.containerPadding,
        AppSpacing.cardGap,
        AppSpacing.containerPadding,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, $userName',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  dateText,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
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

  Widget _buildStatsGrid() {
    final cards = <_StatCardData>[
      _StatCardData(
        label: 'Total Properties',
        value: '8',
        icon: Icons.home_outlined,
        accent: AppColors.primaryLight,
      ),
      _StatCardData(
        label: 'Total Invested',
        value: 'SAR 2.4M',
        icon: Icons.trending_up,
        accent: AppColors.success,
      ),
      _StatCardData(
        label: 'Paid This Month',
        value: 'SAR 42,800',
        icon: Icons.calendar_today_outlined,
        accent: AppColors.chartBlue,
      ),
      _StatCardData(
        label: 'Upcoming Payments',
        value: 'SAR 15,200',
        icon: Icons.notifications_outlined,
        accent: AppColors.warningText,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.cardGap,
        12,
        AppSpacing.cardGap,
        0,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cards.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.6,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) => _StatCard(data: cards[index]),
      ),
    );
  }

  Widget _buildUpcomingSection() {
    const items = <_InstallmentRowData>[
      _InstallmentRowData(
        propertyName: 'Skyline Towers - Unit 402',
        info: 'Milestone 4 · Structural',
        amount: 'SAR 8,500',
        status: _InstallmentStatus.overdue,
      ),
      _InstallmentRowData(
        propertyName: 'Azure Bay Villas - Villa B',
        info: 'Installment #12 of 24',
        amount: 'SAR 4,200',
        status: _InstallmentStatus.dueSoon,
      ),
      _InstallmentRowData(
        propertyName: 'The Oak Residency',
        info: 'Installment #08 of 18',
        amount: 'SAR 2,500',
        status: _InstallmentStatus.onTrack,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.cardGap,
        AppSpacing.containerPadding,
        AppSpacing.cardGap,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Upcoming Installments',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryLight,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (final item in items) _InstallmentRow(data: item),
        ],
      ),
    );
  }

  String _greetingForNow() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

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
}

class _StatCardData {
  const _StatCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});

  final _StatCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.innerPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(data.icon, size: 20, color: data.accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          data.value,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data.label,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: data.accent,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(2),
                bottomRight: Radius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _InstallmentStatus { overdue, dueSoon, onTrack }

class _InstallmentRowData {
  const _InstallmentRowData({
    required this.propertyName,
    required this.info,
    required this.amount,
    required this.status,
  });

  final String propertyName;
  final String info;
  final String amount;
  final _InstallmentStatus status;
}

class _InstallmentRow extends StatelessWidget {
  const _InstallmentRow({required this.data});

  final _InstallmentRowData data;

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor(data.status);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.card,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: accent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.propertyName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data.info,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          data.amount,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _StatusChip(status: data.status),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Color _accentColor(_InstallmentStatus status) {
    switch (status) {
      case _InstallmentStatus.overdue:
        return AppColors.danger;
      case _InstallmentStatus.dueSoon:
        return AppColors.warningText;
      case _InstallmentStatus.onTrack:
        return AppColors.success;
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final _InstallmentStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg) = _styleFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  (String, Color, Color) _styleFor(_InstallmentStatus status) {
    switch (status) {
      case _InstallmentStatus.overdue:
        return ('Overdue', AppColors.danger, AppColors.dangerBg);
      case _InstallmentStatus.dueSoon:
        return ('Due Soon', AppColors.warningText, AppColors.warningBg);
      case _InstallmentStatus.onTrack:
        return ('On Track', AppColors.success, AppColors.successBg);
    }
  }
}
