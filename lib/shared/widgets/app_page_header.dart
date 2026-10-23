
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme_provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../navigation/app_navigation.dart';
import 'notification_center_sheet.dart';

class AppPageHeader extends StatelessWidget {
  final String? sectionLabel;
  final String title;
  final String description;
  final VoidCallback? onThemeTap;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onAvatarTap;

  const AppPageHeader({
    super.key,
    this.sectionLabel,
    required this.title,
    required this.description,
    this.onThemeTap,
    this.onNotificationsTap,
    this.onAvatarTap,
  });

  void _openNotifications(BuildContext context) {
    if (onNotificationsTap != null) {
      onNotificationsTap!();
      return;
    }


    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) => const NotificationCenterSheet(),
    );
  }

  void _openProfile(BuildContext context) {
    if (onAvatarTap != null) {
      onAvatarTap!();
      return;
    }

    // Le profil correspond à l'onglet numéro 4 dans MainShell.
    context.read<AppNavigation>().selectTab(4);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = themeProvider.isDarkMode;

    final firstName = user?.firstName ?? '';
    final lastName = user?.lastName ?? '';

    final initials = (
      (firstName.isNotEmpty ? firstName[0] : '') +
      (lastName.isNotEmpty ? lastName[0] : '')
    ).toUpperCase();

    const navy = Color(0xFF193B7A);
    const muted = Color(0xFF8191A8);

    final background = theme.scaffoldBackgroundColor;
    final titleColor = colors.onSurface;
    final labelColor = isDark ? colors.primary : navy;
    final secondaryColor = isDark ? colors.onSurfaceVariant : muted;

    return Container(
      color: background,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Image.asset(
                  'assets/images/logo2.png',
                  height: 42,
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.contain,
                  errorBuilder: (_, error, stackTrace) => Text(
                    'AYOS\nMON ESPACE',
                    style: TextStyle(
                      color: labelColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              _HeaderIconButton(
                icon: isDark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                tooltip: isDark
                    ? 'Activer le mode clair'
                    : 'Activer le mode sombre',
                onTap: onThemeTap ??
                    () {
                      context.read<ThemeProvider>().toggleTheme();
                    },
              ),
              const SizedBox(width: 10),
              _HeaderIconButton(
                icon: Icons.notifications_none_rounded,
                tooltip: 'Notifications',
                onTap: () => _openNotifications(context),
              ),
              const SizedBox(width: 10),
              Semantics(
                button: true,
                label: 'Ouvrir mon profil',
                child: GestureDetector(
                  onTap: () => _openProfile(context),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: isDark
                        ? colors.primary
                        : navy,
                    child: Text(
                      initials.isEmpty ? 'AY' : initials,
                      style: TextStyle(
                        color: isDark
                            ? colors.onPrimary
                            : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          if (sectionLabel != null &&
              sectionLabel!.trim().isNotEmpty) ...[
            Text(
              sectionLabel!.toUpperCase(),
              style: TextStyle(
                color: labelColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 15),
          ],
          Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontSize: 20,
              fontWeight: FontWeight.w400,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            description,
            style: TextStyle(
              color: secondaryColor,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;

  const _HeaderIconButton({
    required this.icon,
    this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? colors.outline
              : const Color(0xFFDCE3EC),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(19),
      ),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        icon: Icon(
          icon,
          color: colors.onSurfaceVariant,
          size: 20,
        ),
      ),
    );
  }
}
