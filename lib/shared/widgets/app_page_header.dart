
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      backgroundColor: Colors.white,
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

    final firstName = user?.firstName ?? '';
    final lastName = user?.lastName ?? '';

    final initials = (
      (firstName.isNotEmpty ? firstName[0] : '') +
      (lastName.isNotEmpty ? lastName[0] : '')
    ).toUpperCase();

    const navy = Color(0xFF193B7A);
    const muted = Color(0xFF8191A8);
    const background = Color(0xFFF8F7F4);

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
                  errorBuilder: (_, error, stackTrace) => const Text(
                    'AYOS\nMON ESPACE',
                    style: TextStyle(
                      color: navy,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              _HeaderIconButton(
                icon: Icons.wb_sunny_outlined,
                onTap: onThemeTap,
              ),
              const SizedBox(width: 10),
              _HeaderIconButton(
                icon: Icons.notifications_none_rounded,
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
                    backgroundColor: navy,
                    child: Text(
                      initials.isEmpty ? 'AY' : initials,
                      style: const TextStyle(
                        color: Colors.white,
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
              style: const TextStyle(
                color: navy,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 15),
          ],
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF202D43),
              fontSize: 20,
              fontWeight: FontWeight.w400,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            description,
            style: const TextStyle(
              color: muted,
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

  const _HeaderIconButton({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFDCE3EC),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(19),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(
          icon,
          color: const Color(0xFF8191A8),
          size: 20,
        ),
      ),
    );
  }
}
