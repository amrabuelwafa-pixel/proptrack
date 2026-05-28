import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proptrack/core/theme/theme_notifier.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────
// Design tokens (per DESIGN_DASGBOARD.md & DESIGN_properties.md)
// ─────────────────────────────────────────────────────────────────────────

const _surface = Color(0xFFF7F9FB);
const _surfaceLowest = Colors.white;
const _surfaceContainer = Color(0xFFECEEF0);
const _surfaceContainerHigh = Color(0xFFE6E8EA);
const _outlineVariant = Color(0xFFC5C6CE);
const _onSurface = Color(0xFF191C1E);
const _onSurfaceVariant = Color(0xFF44474D);
const _onBackground = Color(0xFF191C1E);
const _primaryContainer = Color(0xFF0C1B34);
const _onPrimary = Colors.white;
const _emerald = Color(0xFF006C49);
const _primaryFixedDim = Color(0xFFB8C7E8);
const _danger = Color(0xFFBA1A1A);
const _dangerContainer = Color(0xFFFFDAD6);

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

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _pushNotifications = true;
  String _currency = 'SAR';
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 1024;
          return isWide ? _buildDesktop() : _buildMobile();
        },
      ),
    );
  }

  // ─────────────────────── Desktop layout ───────────────────────

  Widget _buildDesktop() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1024),
          child: Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPageHeader(isWide: true),
                const SizedBox(height: 40),
                const _SectionLabel(text: 'ACCOUNT'),
                const SizedBox(height: 12),
                _accountCard(),
                const SizedBox(height: 32),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _SectionLabel(text: 'PREFERENCES'),
                            const SizedBox(height: 12),
                            Expanded(child: _preferencesCard()),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _SectionLabel(text: 'APPEARANCE'),
                            const SizedBox(height: 12),
                            Expanded(child: _appearanceCard()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const _SectionLabel(text: 'SYSTEM'),
                const SizedBox(height: 12),
                _systemCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────── Mobile layout ───────────────────────

  Widget _buildMobile() {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPageHeader(isWide: false),
              const SizedBox(height: 24),
              const _SectionLabel(text: 'ACCOUNT'),
              const SizedBox(height: 12),
              _accountCard(),
              const SizedBox(height: 24),
              const _SectionLabel(text: 'PREFERENCES'),
              const SizedBox(height: 12),
              _preferencesCard(),
              const SizedBox(height: 24),
              const _SectionLabel(text: 'APPEARANCE'),
              const SizedBox(height: 12),
              _appearanceCard(),
              const SizedBox(height: 24),
              const _SectionLabel(text: 'SYSTEM'),
              const SizedBox(height: 12),
              _systemCard(),
              const SizedBox(height: 24),
              _logoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────── Header ───────────────────────

  Widget _buildPageHeader({required bool isWide}) {
    if (isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Settings',
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
            'Manage your account preferences and application settings.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: _onSurfaceVariant,
              height: 1.55,
            ),
          ),
        ],
      );
    }
    return Column(
      children: const [
        Text(
          'Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: _primaryContainer,
            letterSpacing: -0.24,
            height: 1.33,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Manage your account and app preferences',
          style: TextStyle(
            fontSize: 16,
            color: _onSurfaceVariant,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ─────────────────────── Account card ───────────────────────

  Widget _accountCard() {
    return _SettingsCard(
      child: Column(
        children: [
          _SettingsRow(
            iconBg: _primaryFixedDim.withValues(alpha: 0.2),
            iconColor: _primaryContainer,
            icon: Icons.person_outline,
            title: 'Edit Profile',
            subtitle: 'Update your personal information',
            trailing: const Icon(Icons.chevron_right, color: _onSurfaceVariant),
            onTap: () {},
          ),
          const _RowDivider(),
          _SettingsRow(
            iconBg: _primaryFixedDim.withValues(alpha: 0.2),
            iconColor: _primaryContainer,
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Secure your account',
            trailing: const Icon(Icons.chevron_right, color: _onSurfaceVariant),
            onTap: () {},
          ),
          const _RowDivider(),
          _SettingsRow(
            iconBg: _primaryFixedDim.withValues(alpha: 0.2),
            iconColor: _primaryContainer,
            icon: Icons.shield_outlined,
            title: 'Two-Factor Authentication',
            subtitle: 'Add an extra layer of security',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                _PillBadge(
                  label: 'Off',
                  bg: _surfaceContainerHigh,
                  fg: _onSurfaceVariant,
                ),
                SizedBox(width: 8),
                Icon(Icons.chevron_right, color: _onSurfaceVariant),
              ],
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // ─────────────────────── Preferences card ───────────────────────

  Widget _preferencesCard() {
    return _SettingsCard(
      child: Column(
        children: [
          _SettingsRow(
            iconBg: _surfaceContainerHigh,
            iconColor: _onSurfaceVariant,
            icon: Icons.notifications_active_outlined,
            title: 'Push Notifications',
            subtitle: 'Receive alerts on market updates',
            trailing: Switch(
              value: _pushNotifications,
              onChanged: (v) => setState(() => _pushNotifications = v),
              activeColor: _onPrimary,
              activeTrackColor: _primaryContainer,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: _outlineVariant,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onTap: () =>
                setState(() => _pushNotifications = !_pushNotifications),
          ),
          const _RowDivider(),
          _SettingsRow(
            iconBg: _surfaceContainerHigh,
            iconColor: _onSurfaceVariant,
            icon: Icons.payments_outlined,
            title: 'Default Currency',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _currency,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _onPrimary,
                      height: 1.43,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.expand_more, color: _onSurfaceVariant),
              ],
            ),
            onTap: _pickCurrency,
          ),
          const _RowDivider(),
          _SettingsRow(
            iconBg: _surfaceContainerHigh,
            iconColor: _onSurfaceVariant,
            icon: Icons.language_outlined,
            title: 'Language',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _language,
                  style: const TextStyle(
                    fontSize: 14,
                    color: _onSurface,
                    height: 1.43,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.expand_more, color: _onSurfaceVariant),
              ],
            ),
            onTap: _pickLanguage,
          ),
        ],
      ),
    );
  }

  // ─────────────────────── Appearance card ───────────────────────

  Widget _appearanceCard() {
    final mode = ref.watch(themeModeProvider);
    final isDark = mode == ThemeMode.dark;

    return _SettingsCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: _surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.palette_outlined,
                    size: 22,
                    color: _onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Theme',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _onSurface,
                    height: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _themeSegmentedControl(isDark),
          ],
        ),
      ),
    );
  }

  Widget _themeSegmentedControl(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: _themeSegment(
              label: 'Light',
              icon: Icons.light_mode_outlined,
              selected: !isDark,
              onTap: () => _setTheme(false),
            ),
          ),
          Expanded(
            child: _themeSegment(
              label: 'Dark',
              icon: Icons.dark_mode_outlined,
              selected: isDark,
              onTap: () => _setTheme(true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _themeSegment({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? _primaryContainer : _onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: selected ? _primaryContainer : _onSurfaceVariant,
                height: 1.43,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setTheme(bool dark) {
    final notifier = ref.read(themeModeProvider.notifier);
    final currentDark = ref.read(themeModeProvider) == ThemeMode.dark;
    if (currentDark != dark) notifier.toggle();
  }

  // ─────────────────────── System card ───────────────────────

  Widget _systemCard() {
    return _SettingsCard(
      child: Column(
        children: [
          _SettingsRow(
            iconBg: _surfaceContainerHigh,
            iconColor: _onSurfaceVariant,
            icon: Icons.info_outline,
            title: 'About PropTrack',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'v2.4.1',
                  style: TextStyle(
                    fontSize: 14,
                    color: _onSurfaceVariant,
                    height: 1.43,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.chevron_right, color: _onSurfaceVariant),
              ],
            ),
            onTap: () {},
          ),
          const _RowDivider(),
          _SettingsRow(
            iconBg: _surfaceContainerHigh,
            iconColor: _onSurfaceVariant,
            icon: Icons.support_agent_outlined,
            title: 'Help & Support',
            trailing: const Icon(Icons.open_in_new, color: _onSurfaceVariant),
            onTap: () {},
          ),
          const _RowDivider(),
          InkWell(
            onTap: _logout,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.logout, color: _danger, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Log Out',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _danger,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Mobile-only outlined logout button (matches mobile mockup)
  Widget _logoutButton() {
    return InkWell(
      onTap: _logout,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _dangerContainer.withValues(alpha: 0.1),
          border: Border.all(color: _danger.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout, color: _danger, size: 20),
            SizedBox(width: 8),
            Text(
              'Log Out',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _danger,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────── Actions ───────────────────────

  Future<void> _pickCurrency() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: _surfaceLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _OptionSheet(
        title: 'Default Currency',
        options: const ['SAR', 'USD', 'EUR', 'EGP', 'AED', 'GBP'],
        selected: _currency,
      ),
    );
    if (picked != null) setState(() => _currency = picked);
  }

  Future<void> _pickLanguage() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: _surfaceLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _OptionSheet(
        title: 'Language',
        options: const ['English', 'العربية'],
        selected: _language,
      ),
    );
    if (picked != null) setState(() => _language = picked);
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surfaceLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Log Out',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: _primaryContainer,
          ),
        ),
        content: const Text(
          'Are you sure you want to log out of PropTrack?',
          style: TextStyle(fontSize: 14, color: _onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: _onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Log Out',
              style: TextStyle(color: _danger, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    if (confirm ?? false) {
      await Supabase.instance.client.auth.signOut();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Building blocks
// ─────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _onSurfaceVariant,
          letterSpacing: 0.6,
          height: 1.33,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _outlineVariant.withValues(alpha: 0.3)),
        boxShadow: _level2Shadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: _surfaceContainer,
      height: 1,
      thickness: 1,
    );
  }
}

class _PillBadge extends StatelessWidget {
  const _PillBadge({
    required this.label,
    required this.bg,
    required this.fg,
  });

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.trailing,
    required this.onTap,
    this.subtitle,
  });

  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 22, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _onSurface,
                        height: 1.5,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: _onSurfaceVariant,
                          height: 1.43,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Option picker (currency / language)
// ─────────────────────────────────────────────────────────────────────────

class _OptionSheet extends StatelessWidget {
  const _OptionSheet({
    required this.title,
    required this.options,
    required this.selected,
  });

  final String title;
  final List<String> options;
  final String selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: _primaryContainer,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 8),
            for (final option in options)
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => Navigator.pop(context, option),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          option,
                          style: const TextStyle(
                            fontSize: 16,
                            color: _onSurface,
                            height: 1.5,
                          ),
                        ),
                      ),
                      if (option == selected)
                        const Icon(Icons.check, color: _emerald, size: 22)
                      else
                        const SizedBox(width: 22),
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
