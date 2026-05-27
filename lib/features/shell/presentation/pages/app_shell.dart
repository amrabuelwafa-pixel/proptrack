import 'package:flutter/material.dart';
import 'package:proptrack/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:proptrack/features/profile/presentation/pages/profile_page.dart';
import 'package:proptrack/features/properties/presentation/pages/properties_page.dart';
import 'package:proptrack/features/settings/presentation/pages/settings_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  // Design system tokens (per DESIGN_DASGBOARD.md)
  static const _surface = Color(0xFFF7F9FB);
  static const _onSurfaceVariant = Color(0xFF44474D);
  static const _navy = Color(0xFF0A1A33);

  final List<Widget> _pages = const [
    DashboardPage(),
    PropertiesPage(),
    ProfilePage(),
    SettingsPage(),
  ];

  static const List<NavItem> _navItems = [
    NavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
    ),
    NavItem(
      icon: Icons.apartment_outlined,
      activeIcon: Icons.apartment,
      label: 'Properties',
    ),
    NavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
    ),
    NavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Settings',
    ),
  ];

  void _onNavTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        if (isMobile) {
          return Scaffold(
            backgroundColor: _surface,
            body: _pages[_selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex,
              onTap: _onNavTapped,
              backgroundColor: Colors.white,
              selectedItemColor: _navy,
              unselectedItemColor: _onSurfaceVariant,
              elevation: 8,
              items: _navItems
                  .map(
                    (item) => BottomNavigationBarItem(
                      icon: Icon(item.icon),
                      activeIcon: Icon(item.activeIcon),
                      label: item.label,
                    ),
                  )
                  .toList(),
            ),
          );
        }

        return Scaffold(
          backgroundColor: _surface,
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Sidebar(
                selectedIndex: _selectedIndex,
                items: _navItems,
                onTap: _onNavTapped,
              ),
              Expanded(child: _pages[_selectedIndex]),
            ],
          ),
        );
      },
    );
  }
}

class NavItem {
  const NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

// ─────────────────────────────────────────────────────────────────────────
// Sidebar
// ─────────────────────────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.selectedIndex,
    required this.items,
    required this.onTap,
  });

  final int selectedIndex;
  final List<NavItem> items;
  final void Function(int) onTap;

  static const _navy = Color(0xFF0A1A33);
  static const _onSurfaceVariant = Color(0xFF44474D);
  static const _outlineVariant = Color(0xFFC5C6CE);

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final fullName = user?.userMetadata?['full_name'] as String? ??
        user?.userMetadata?['name'] as String? ??
        'User';
    final firstName = fullName.split(' ').first;

    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: _outlineVariant, width: 1),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header: logo + brand
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 40,
                    height: 40,
                    filterQuality: FilterQuality.high,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'PropTrack',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: _navy,
                            letterSpacing: -0.3,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Wealth Management',
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
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Nav items
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    return _NavItemWidget(
                      item: items[index],
                      isSelected: index == selectedIndex,
                      onTap: () => onTap(index),
                    );
                  },
                ),
              ),
            ),

            // Footer: user pill + logout
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // User pill (name only — avatar moved to dashboard hero)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.account_circle_outlined,
                              size: 22,
                              color: _onSurfaceVariant,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                firstName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _onSurfaceVariant,
                                  letterSpacing: 0.6,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Logout
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        await Supabase.instance.client.auth.signOut();
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.logout,
                              size: 18,
                              color: Color(0xFFBA1A1A),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFBA1A1A),
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItemWidget extends StatefulWidget {
  const _NavItemWidget({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_NavItemWidget> createState() => _NavItemWidgetState();
}

class _NavItemWidgetState extends State<_NavItemWidget> {
  static const _navy = Color(0xFF0A1A33);
  static const _onSurfaceVariant = Color(0xFF44474D);
  static const _surfaceContainer = Color(0xFFECEEF0);

  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    final color = isSelected
        ? _navy
        : (_isHovering ? _surfaceContainer : Colors.transparent);
    final fg = isSelected ? Colors.white : _onSurfaceVariant;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  isSelected ? widget.item.activeIcon : widget.item.icon,
                  size: 22,
                  color: fg,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.item.label,
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
