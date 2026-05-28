import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:proptrack/features/dashboard/domain/entities/dashboard_metrics.dart';
import 'package:proptrack/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────
// Design tokens
// ─────────────────────────────────────────────────────────────────────────

const _surface = Color(0xFFF7F9FB);
const _surfaceLowest = Colors.white;
const _surfaceContainerLow = Color(0xFFF2F4F6);
const _surfaceContainerHighest = Color(0xFFE0E3E5);
const _outlineVariant = Color(0xFFC5C6CE);
const _outline = Color(0xFF75777E);
const _onSurface = Color(0xFF191C1E);
const _onSurfaceVariant = Color(0xFF44474D);
const _onBackground = Color(0xFF191C1E);
const _navy = Color(0xFF0A1A33);
const _onPrimary = Colors.white;
const _emerald = Color(0xFF006C49);
const _onDangerContainer = Color(0xFF93000A);
const _dangerContainer = Color(0xFFFFDAD6);
const _danger = Color(0xFFBA1A1A);
const _bannerNavy = Color(0xFF1A2B4A);

const _level2Shadow = [
  BoxShadow(
    color: Color(0x14000000),
    blurRadius: 3,
    offset: Offset(0, 1),
  ),
];

String _formatEgpCompact(double amount) {
  return NumberFormat.compactCurrency(
    locale: 'en_US',
    symbol: 'E£ ',
    decimalDigits: amount >= 1e6 ? 2 : 0,
  ).format(amount);
}

// ─────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ColoredBox(
      color: _surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 1024;
          return SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1024),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 48 : 16,
                      vertical: isWide ? 48 : 32,
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Mobile title (desktop uses topbar)
                        _MobileTitleHeader(),
                        _ProfileHeader(),
                        SizedBox(height: 32),
                        _MetricsRow(),
                        SizedBox(height: 32),
                        _AccountDetailsCard(),
                        SizedBox(height: 32),
                        _SupportBanner(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MobileTitleHeader extends StatelessWidget {
  const _MobileTitleHeader();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 1024;
    if (isWide) return const SizedBox.shrink();
    return const Padding(
      padding: EdgeInsets.only(bottom: 24),
      child: Center(
        child: Text(
          'Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: _onBackground,
            letterSpacing: -0.24,
            height: 1.33,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Profile header (avatar + name + email)
// ─────────────────────────────────────────────────────────────────────────

class _ProfileHeader extends ConsumerStatefulWidget {
  const _ProfileHeader();

  @override
  ConsumerState<_ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends ConsumerState<_ProfileHeader> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = Supabase.instance.client.auth.currentUser;
  }

  String get _fullName =>
      _user?.userMetadata?['full_name'] as String? ??
      _user?.userMetadata?['name'] as String? ??
      'User';

  String get _email => _user?.email ?? '—';

  String get _initial =>
      _fullName.trim().isNotEmpty ? _fullName.trim()[0].toUpperCase() : 'U';

  Future<void> _openEdit() async {
    final updated = await showModalBottomSheet<User?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surfaceLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EditProfileSheet(initialName: _fullName),
    );
    if (updated != null && mounted) {
      setState(() => _user = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 1024;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar with edit badge
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: _navy,
                shape: BoxShape.circle,
                boxShadow: [
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
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                _initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),
            // Edit badge
            Positioned(
              right: 0,
              bottom: 4,
              child: GestureDetector(
                onTap: _openEdit,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isWide ? _surfaceLowest : _emerald,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isWide ? _outlineVariant : _surface,
                      width: isWide ? 1 : 3,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: isWide ? _navy : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          _fullName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isWide ? 32 : 24,
            fontWeight: FontWeight.w600,
            color: _onBackground,
            letterSpacing: isWide ? -0.64 : -0.24,
            height: 1.25,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          _email,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: _onSurfaceVariant,
            height: 1.5,
          ),
        ),
        if (!isWide) ...[
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: _openEdit,
            style: OutlinedButton.styleFrom(
              foregroundColor: _navy,
              side: const BorderSide(color: _outlineVariant),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              minimumSize: const Size(0, 40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Metrics row (Portfolio Value, Properties, Pending Dues)
// ─────────────────────────────────────────────────────────────────────────

class _MetricsRow extends ConsumerWidget {
  const _MetricsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(dashboardMetricsProvider);

    return metricsAsync.when(
      data: (m) => _buildGrid(_tilesFor(m)),
      loading: () => _buildGrid(_placeholders, isLoading: true),
      error: (e, _) => _ErrorState(
        message: e.toString(),
        onRetry: () => ref.invalidate(dashboardMetricsProvider),
      ),
    );
  }

  static const _placeholders = <_MetricTileData>[
    _MetricTileData(
      label: 'Portfolio Value',
      value: '—',
      icon: Icons.account_balance_wallet_outlined,
    ),
    _MetricTileData(
      label: 'Properties',
      value: '—',
      icon: Icons.apartment_outlined,
    ),
    _MetricTileData(
      label: 'Pending Dues',
      value: '—',
      icon: Icons.pending_actions_outlined,
    ),
  ];

  List<_MetricTileData> _tilesFor(DashboardMetrics m) {
    final pending = m.upcomingPaymentsCount + m.overduePaymentsCount;
    return [
      _MetricTileData(
        label: 'Portfolio Value',
        value: _formatEgpCompact(m.totalInvested),
        icon: Icons.account_balance_wallet_outlined,
        // No year-over-year data available — leave footer blank.
      ),
      _MetricTileData(
        label: 'Properties',
        value:
            '${m.totalProperties} ${m.totalProperties == 1 ? "Property" : "Properties"}',
        icon: Icons.apartment_outlined,
        footer: const _MetricFooter(text: 'Active Management'),
      ),
      _MetricTileData(
        label: 'Pending Dues',
        value: '$pending ${pending == 1 ? "Installment" : "Installments"}',
        icon: Icons.pending_actions_outlined,
        footer: m.overduePaymentsCount > 0
            ? _MetricFooter(
                text: '${m.overduePaymentsCount} requiring attention',
                icon: Icons.info_outline,
                color: _danger,
              )
            : null,
      ),
    ];
  }

  Widget _buildGrid(List<_MetricTileData> tiles, {bool isLoading = false}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 720 ? 3 : 1;
        const spacing = 24.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (crossAxisCount - 1)) /
                crossAxisCount;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final t in tiles)
              SizedBox(
                width: itemWidth,
                child: _MetricCard(data: t, isLoading: isLoading),
              ),
          ],
        );
      },
    );
  }
}

class _MetricFooter {
  const _MetricFooter({required this.text, this.icon, this.color});

  final String text;
  final IconData? icon;
  final Color? color;
}

class _MetricTileData {
  const _MetricTileData({
    required this.label,
    required this.value,
    required this.icon,
    this.footer,
  });

  final String label;
  final String value;
  final IconData icon;
  final _MetricFooter? footer;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.data, this.isLoading = false});

  final _MetricTileData data;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final valueColor =
        isLoading ? _onSurfaceVariant.withValues(alpha: 0.4) : _onBackground;

    return Container(
      decoration: BoxDecoration(
        color: _surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: _level2Shadow,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(data.icon, color: _outline, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data.label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _onSurfaceVariant,
                    letterSpacing: 0.6,
                    height: 1.33,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              data.value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: valueColor,
                letterSpacing: -0.24,
                height: 1.33,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              maxLines: 1,
            ),
          ),
          if (data.footer != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (data.footer!.icon != null) ...[
                  Icon(
                    data.footer!.icon,
                    size: 16,
                    color: data.footer!.color ?? _onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    data.footer!.text,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: data.footer!.color ?? _onSurfaceVariant,
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
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: _level2Shadow,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: const [
              Icon(Icons.error_outline, color: _danger, size: 20),
              SizedBox(width: 8),
              Text(
                'Couldn’t load summary',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _onBackground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              color: _onSurfaceVariant,
              height: 1.5,
            ),
            maxLines: 3,
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
// Account details list
// ─────────────────────────────────────────────────────────────────────────

class _AccountDetailsCard extends StatelessWidget {
  const _AccountDetailsCard();

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final fullName = user?.userMetadata?['full_name'] as String? ??
        user?.userMetadata?['name'] as String? ??
        '—';
    final email = user?.email ?? '—';
    final emailConfirmed = user?.emailConfirmedAt != null;
    final phone = (user?.phone?.isNotEmpty ?? false) ? user!.phone : null;
    final createdAt =
        user?.createdAt != null ? DateTime.tryParse(user!.createdAt) : null;
    final memberSince =
        createdAt != null ? DateFormat('MMMM y').format(createdAt) : '—';

    return Container(
      decoration: BoxDecoration(
        color: _surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: _level2Shadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: _surfaceContainerHighest, width: 1),
              ),
            ),
            child: const Text(
              'Account Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: _onBackground,
                height: 1.4,
              ),
            ),
          ),
          _DetailRow(label: 'Full Name', value: fullName),
          const _Separator(),
          _DetailRow(
            label: 'Email Address',
            value: email,
            trailing: emailConfirmed
                ? const Text(
                    'Verified',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _emerald,
                      letterSpacing: 0.6,
                    ),
                  )
                : null,
          ),
          const _Separator(),
          _DetailRow(
            label: 'Phone Number',
            value: phone ?? 'Not set',
            trailing: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.edit_outlined, size: 18),
              color: _outline,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              tooltip: 'Edit phone number',
            ),
          ),
          const _Separator(),
          _DetailRow(label: 'Member Since', value: memberSince),
        ],
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: _surfaceContainerHighest,
    );
  }
}

class _DetailRow extends StatefulWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.trailing,
  });

  final String label;
  final String value;
  final Widget? trailing;

  @override
  State<_DetailRow> createState() => _DetailRowState();
}

class _DetailRowState extends State<_DetailRow> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 1024;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Container(
        color: _hovering ? _surfaceContainerLow : Colors.transparent,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    child: Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: _onSurfaceVariant,
                        height: 1.43,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            widget.value,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: _onBackground,
                              height: 1.5,
                            ),
                          ),
                        ),
                        if (widget.trailing != null) widget.trailing!,
                      ],
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.label.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _onSurfaceVariant,
                            letterSpacing: 0.6,
                            height: 1.33,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.value,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: _onBackground,
                            height: 1.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (widget.trailing != null) ...[
                    const SizedBox(width: 12),
                    widget.trailing!,
                  ],
                ],
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Support banner
// ─────────────────────────────────────────────────────────────────────────

class _SupportBanner extends StatelessWidget {
  const _SupportBanner();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 1024;
    return Container(
      decoration: BoxDecoration(
        color: _bannerNavy,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Decorative icon (subtle)
          Positioned(
            right: -32,
            top: -32,
            child: Icon(
              Icons.support_agent,
              size: 200,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(child: _SupportText()),
                      const SizedBox(width: 24),
                      _ContactButton(onPressed: () {}),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: _emerald,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.support_agent,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(child: _SupportText()),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _ContactButton(onPressed: () {}, fullWidth: true),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _SupportText extends StatelessWidget {
  const _SupportText();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Need Assistance?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your dedicated portfolio manager is available to help with any '
          'inquiries regarding your properties or account.',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.8),
            height: 1.57,
          ),
        ),
      ],
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({required this.onPressed, this.fullWidth = false});

  final VoidCallback onPressed;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _surfaceLowest,
          foregroundColor: _bannerNavy,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          minimumSize: const Size(0, 48),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text(
          'Contact Us',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Edit profile bottom sheet
// ─────────────────────────────────────────────────────────────────────────

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.initialName});

  final String initialName;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameController;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialName == 'User' ? '' : widget.initialName,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      setState(() => _error = 'Name cannot be empty.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final response = await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'full_name': newName}),
      );
      if (!mounted) return;
      Navigator.of(context).pop(response.user);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: _onBackground,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Update your account details.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: _onSurfaceVariant,
                  height: 1.43,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'FULL NAME',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _onSurfaceVariant,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                enabled: !_saving,
                autofocus: true,
                style: const TextStyle(fontSize: 16, color: _onSurface),
                decoration: InputDecoration(
                  hintText: 'Your full name',
                  hintStyle: const TextStyle(color: _onSurfaceVariant),
                  filled: true,
                  fillColor: _surfaceLowest,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _navy, width: 1.5),
                  ),
                ),
                onSubmitted: (_) => _save(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _dangerContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 16,
                        color: _onDangerContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: _onDangerContainer,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving
                          ? null
                          : () => Navigator.of(context).pop(null),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _onBackground,
                        side: const BorderSide(color: _outlineVariant),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(0, 48),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _navy,
                        foregroundColor: _onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(0, 48),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save',
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
            ],
          ),
        ),
      ),
    );
  }
}
